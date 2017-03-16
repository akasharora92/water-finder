import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
import caffe
import caffe.draw
from os import listdir
import cPickle
import copy

import sys, os.path
sys.path.insert(0,'/home/pfurlong/installed/local_root/lib/python2.7/dist-packages/')

import cv2

def transform_img(img,img_width=None,img_height=None):

    (rows,cols,chans) = img.shape
    out_img = np.zeros(img.shape)

    if img_width is None:
        img_width = cols
    ### end if
    if img_height is None:
        img_height = rows
    ### end if

    out_img[:,:,0] = cv2.equalizeHist(img[:,:,0])
    out_img[:,:,1] = cv2.equalizeHist(img[:,:,1])
    out_img[:,:,2] = cv2.equalizeHist(img[:,:,2])

    out_img = cv2.resize(img,(img_width,img_height),interpolation=cv2.INTER_CUBIC)
    return out_img
### end transform_img

def make_datum(img,label):
    (rows,cols,chans) = img.shape
    return caffe.proto.caffe_pb2.Datum(channels=chans,width=cols,height=rows,label=label,data=np.rollaxis(img,2).tostring())
### end make_datum

def get_feature_vec(img,net,transformer):
    in_val = transform_img(img,img_width=227,img_height=227) # hard coded for image net

    net.blobs['data'].data[...] = transformer.preprocess('data',in_val)
    out = net.forward()
    print 'out shape: ', net.blobs['fc7'].data.shape

#     plt.figure()
#     d = net.blobs['data'].data
#     print d.shape
#     exit()
#     plt.imshow(img)

    return net.blobs['fc7'].data[0,:]
### end get_feature_vec

def full_path(x):
    return os.path.abspath(os.path.expanduser(x))
### end full_path

def create_network():
    caffe_path = '/home/pfurlong/installed/caffe/models/bvlc_reference_caffenet'
    model_path  = os.path.join(caffe_path,'deploy.prototxt')
    weight_path = os.path.join(caffe_path,'bvlc_reference_caffenet.caffemodel')
    
    net = caffe.Net(model_path,weight_path,caffe.TEST)
    
    data_shapes = net.blobs['data'].shape
    out_shapes = net.blobs['prob'].shape
    net.blobs['data'].reshape(1,data_shapes[1],data_shapes[2],data_shapes[3])
    net.blobs['prob'].reshape(1,out_shapes[1])
    net.reshape()
	
    return net


def iter_files(image_names,out_filename):

    net = create_network()

    transformer = caffe.io.Transformer({'data':net.blobs['data'].data.shape})
    #transformer.set_mean('data',mean_array)
    transformer.set_transpose('data',(2,0,1))
	
# 	net.blobs['data'].data[...] = transformer.preprocess('data',b)
# 	print net.blobs['prob'].data
# 	out = net.forward()
	
    feature_vecs = []
    for (idx,img_name) in enumerate(image_names):
	print 'processing file ',idx,' of ',len(image_names)
        print img_name
	img = cv2.imread(img_name)
        fv = get_feature_vec(img,net,transformer)
	feature_vecs.append(copy.deepcopy(fv))
#         out_name = full_path('~/data/out/feat%d.txt'%(idx,))
#         np.savetxt(out_name,fv)

    ### end for
	
    with file(out_filename,'wb') as fp:
        cPickle.dump((image_names,feature_vecs),fp)
    ### end with
### end iter_files

if __name__=='__main__':
	if len(sys.argv) < 4:
		print 'Usage python test-load-nn.py [img_file_dir] [img_suffix] [destination_filename]' 
	### end if

	file_dir = os.path.abspath(os.path.expanduser(sys.argv[1]))
	suffix = sys.argv[2]
	out_filename = sys.argv[3]


	img_filenames = [os.path.join(file_dir,f) for f in listdir(file_dir) if suffix in f and os.path.isfile(os.path.join(file_dir,f))]

	iter_files(img_filenames,out_filename)

