import numpy as np
import yaml
from os import listdir
import os.path,sys
import matplotlib.pyplot as plt
import cPickle
sys.path.insert(0,'/home/pfurlong/installed/local_root/lib/python2.7/dist-packages/')
import cv2
print cv2.__version__


def opencv_matrix(loader,node):
    print type(node)
    exit()
    mapping = loader.construct_mapping(node)
    mat = np.array(mapping['data'])
    mat.resize(mapping['rows'],mapping['cols'])
    return mat
### end opencv_matrix

def main(yaml_filename,img_filename):
    y = yaml.safe_load(open(yaml_filename,'r'))
    surf_vocab = np.array(y['vocabulary']['data'],dtype=np.float32)
    surf_vocab.resize(y['vocabulary']['rows'],y['vocabulary']['cols'])

    surf2 = cv2.xfeatures2d.SURF_create(400)
    bow_ext = cv2.BOWImgDescriptorExtractor(surf2,cv2.BFMatcher(cv2.NORM_L2))
    bow_ext.setVocabulary(surf_vocab)

    img = cv2.imread(img_filename)
    surf = cv2.xfeatures2d.SURF_create(400)
    kp,des = surf.detectAndCompute(img,None)
    histogram = bow_ext.compute(img,kp,des)
    print histogram.shape
    print np.max(histogram)
    print np.min(histogram)
#     print histogram
    exit()
### end main

def yaml_vocab_to_mat(y):
    surf_vocab = np.array(y['vocabulary']['data'],dtype=np.float32)
    surf_vocab.resize(y['vocabulary']['rows'],y['vocabulary']['cols'])
    return surf_vocab
### end yaml_vocab_to_mat

def get_histogram(img_name,bow_ext,surf):
    img = cv2.imread(img_name)
    kp,des = surf.detectAndCompute(img,None)
    return bow_ext.compute(img,kp,des)
### end get_histogram

def iter_files(yaml_filename,img_filenames,out_filename):
    y = yaml.safe_load(open(yaml_filename,'r'))
    surf_vocab = yaml_vocab_to_mat(y)

    surf2 = cv2.xfeatures2d.SURF_create(400)
    surf = cv2.xfeatures2d.SURF_create(400)
    bow_ext = cv2.BOWImgDescriptorExtractor(surf2,cv2.BFMatcher(cv2.NORM_L2))
    bow_ext.setVocabulary(surf_vocab)

    histograms = {}
    num_imgs = len(img_filenames)
    for (idx,img_name) in enumerate(img_filenames):
        print 'Processing image %d of %d'%(idx,num_imgs)
        histogram = get_histogram(img_name,bow_ext,surf)
        histograms[img_name] = histogram
        ### end if
    ### end for
    
    print 'saving histogram to ' + out_filename
    with file(out_filename,'wb') as fp:
        cPickle.dump(histograms,fp)
    ### end with

    pass
### end iter_files

if __name__=='__main__':
    if len(sys.argv) < 5:
        print 'Usage python clust_images.py [yaml_filename] [img_file_dir] [img_suffix] [destination_filename]' 
    ### end 
    yaml_filename = os.path.abspath(os.path.expanduser(sys.argv[1]))
#     img_filename = os.path.abspath(os.path.expanduser(sys.argv[2]))
    file_dir = os.path.abspath(os.path.expanduser(sys.argv[2]))
    suffix = sys.argv[3]
    out_filename = sys.argv[4]


    img_filenames = [os.path.join(file_dir,f) for f in listdir(file_dir) if suffix in f and os.path.isfile(os.path.join(file_dir,f))]

    iter_files(yaml_filename,img_filenames,out_filename)
