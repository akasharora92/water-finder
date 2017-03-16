import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
import caffe
import caffe.draw
from os import listdir
import cPickle

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



def get_feature_vec(img,net,transformer):
    in_val = transform_img(img,img_width=227,img_height=227) # hard coded for image net

    net.blobs['data'].data[...] = transformer.preprocess('data',in_val)
    out = net.forward()
    print 'out shape: ', net.blobs['fc6'].data.shape
    return net.blobs['fc6'].data[0,:]
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
### end create_network


if __name__=='__main__':
    net = create_network()
    
    transformer = caffe.io.Transformer({'data':net.blobs['data'].data.shape})
    transformer.set_transpose('data',(2,0,1))
    
#     img_file = full_path(sys.argv[1])
#     out_file = full_path(sys.argv[2])

    img_in1='~/data/mvp/GroundCam/20141018/GroundCam0-1413657866.030639.jpg'
    img_in2='~/data/mvp/GroundCam/20141018/GroundCam0-1413657614.037181.jpg'

    img_out1='~/data/out/feat1.txt'
    img_out2='~/data/out/feat2.txt'

    img = cv2.imread(full_path(img_in1))
#     mean_img = cv2.imread(full_path('~/data/out/mean-img-20141018.jpg'))
    feature_vecs = get_feature_vec(img,net,transformer)
    np.savetxt(full_path(img_out1),feature_vecs)
# 	feature_vecs = get_feature_vec(img-mean_img,net,transformer)
    img = cv2.imread(full_path(img_in2))
    feature_vecs = get_feature_vec(img,net,transformer)
    np.savetxt(full_path(img_out2),feature_vecs)



