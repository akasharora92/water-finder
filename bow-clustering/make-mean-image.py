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

if __name__=='__main__':

    file_dir = os.path.abspath(os.path.expanduser(sys.argv[1]))
    suffix = sys.argv[2]
    out_filename = sys.argv[3]
    
    
    img_filenames = [os.path.join(file_dir,f) for f in listdir(file_dir) if suffix in f and os.path.isfile(os.path.join(file_dir,f))]

    num_images = float(len(img_filenames))
    mean_image = cv2.imread(img_filenames[0])/num_images
    for img_idx in range(len(img_filenames)-1):
        img = cv2.imread(img_filenames[img_idx+1])
        mean_image += img/num_images
    ### end for

    cv2.imwrite(out_filename,mean_image)
