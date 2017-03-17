import numpy as np

import cPickle
import sys, os.path
sys.path.insert(0,'/home/pfurlong/installed/local_root/lib/python2.7/dist-packages/')

import cv2

import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
from scipy.spatial.distance import pdist, squareform
from sklearn import mixture

def label_mixture(labels):
    unique_vals = np.unique(labels)
    print unique_vals
    (rows,cols) = labels.shape

    mix = [0 for x in unique_vals]
    for (idx,val) in enumerate(unique_vals):
        mix[idx] = np.sum(labels == val)#/float(rows)
    ### end for
    return mix
### end mixture


if __name__=='__main__':
    print 'Loading data'
    histogram_filename = os.path.abspath(os.path.expanduser(sys.argv[1]))

    source_imgs = []
    with open(histogram_filename,'rb') as fp:
        data = cPickle.load(fp)
        source_imgs = data[0]
        histograms = np.array(data[1],dtype=np.float32)
        print histograms.shape

        print 'Generating Clusters'
#         term_crit = (cv2.TERM_CRITERIA_EPS, 30,0.01)
#         cluster_n = 5
#         num_iters=10
#         ret,labels,centers = cv2.kmeans(histograms,cluster_n,None,term_crit,num_iters,cv2.KMEANS_PP_CENTERS)

        gmm = mixture.GaussianMixture(n_components=5,covariance_type='full')#,max_iter=100,n_init=10)
        gmm.fit(histograms)
        print 'Coverged = ',gmm.converged_
        labels = gmm.predict(histograms)
        centers = (gmm.means_,gmm.covariances_)
        cPickle.dump(centers,open('/home/pfurlong/data/out/gmm/mvp-all-days-good-data-centers.pkl','wb'))

        
#         print label_mixture(labels)
        print 'Saving videos'
        water_probs = []

        terrain_probs = gmm.predict_proba(histograms)
        for u in np.unique(labels):
            u_imgs = (labels == u)
            print 'label: ',u
            fourcc  = cv2.VideoWriter_fourcc(*'XVID')
            out = cv2.VideoWriter('/home/pfurlong/data/out/gmm/good-data-label-%d-frames.avi'%(u,),fourcc,20.0,(1388,1038))
            for (img_name,inc_img) in zip(source_imgs,u_imgs):
                water_probs.append(img_name[-1])
                if inc_img:
                    img = cv2.imread(img_name[0])
                    out.write(img)
                ### end if
            ### end for
            out.release()
        ### end for
        cPickle.dump((terrain_probs,water_probs),open('/home/pfurlong/data/out/gmm/terrain_and_water_probs.pkl','wb'))
    ### end with
### end if



