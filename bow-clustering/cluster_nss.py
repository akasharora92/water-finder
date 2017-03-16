import numpy as np
import sklearn
import cPickle as pickle
import os.path, sys

import matplotlib.pyplot as plt

from sklearn import mixture

sys.path.insert(0,'/home/pfurlong/installed/local_root/lib/python2.7/dist-packages/')
import cv2


import cv2

data = pickle.load(open('/home/pfurlong/data/out/nss-vals.pkl','rb'))

nss_counts = []
for d in data:
    if d[4]:
        nss_counts.append(d[5])
    ### end if
### end for

num_counts = len(nss_counts)
nss_counts = np.array(nss_counts,dtype=np.float32).reshape((num_counts,1))


# plt.hist(nss_counts,100)
# plt.show()
# exit()
 
init_means = np.array([[40],[60],[80]])
gmm = mixture.GaussianMixture(n_components=3,covariance_type='full',max_iter=1000,n_init=10,means_init=init_means)
gmm.fit(nss_counts)


# prediction = gmm.predict_proba(nss_counts)

out_data = []
for (idx,d) in enumerate(data):
    if idx % 1000 == 0:
        print 'Processing %d of %d'%(idx,num_counts)
    pred = gmm.predict_proba(np.array([[d[5]]]))
    out_data.append(d + [pred])
    ### end if
### end for

pickle.dump(out_data,open('/home/pfurlong/data/out/nss-w-probs.pkl','wb'))
