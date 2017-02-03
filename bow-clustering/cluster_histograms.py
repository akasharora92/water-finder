import numpy as np
import cv2
import cPickle
import sys, os.path

import matplotlib.pyplot as plt

def mixture(labels):
    unique_vals = np.unique(labels)
    print unique_vals
    (rows,cols) = labels.shape

    mix = [0 for x in unique_vals]
    for (idx,val) in enumerate(unique_vals):
        mix[idx] = np.sum(labels == val)/float(rows)
    ### end for
    return mix
### end mixture


if __name__=='__main__':
    histogram_filename = os.path.abspath(os.path.expanduser(sys.argv[1]))

    histograms = None
    source_imgs = []
    with open(histogram_filename,'rb') as fp:
        data = cPickle.load(fp)
        for key in data.keys():
            source_imgs.append(key)
            if histograms == None:
                histograms = data[key]
            else:
                histograms = np.vstack((histograms,data[key]))
            ### end if
        ### end for
#         histograms = np.array(histograms,dtype=np.float32)
        print histograms.shape
        term_crit = (cv2.TERM_CRITERIA_EPS, 30,0.1)
        cluster_n = 5
        num_iters = 15 
        ret,labels,centers = cv2.kmeans(histograms,cluster_n,None,term_crit,num_iters,cv2.KMEANS_RANDOM_CENTERS)

        print histograms.shape
        print labels.shape
        print mixture(labels)
    ### end with
### end if



