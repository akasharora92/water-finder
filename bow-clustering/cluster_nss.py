import numpy as np
import sklearn
import cPickle as pickle
import os.path, sys
from scipy.stats import norm

import matplotlib.pyplot as plt

from sklearn import mixture

sys.path.insert(0,'/home/pfurlong/installed/local_root/lib/python2.7/dist-packages/')
import cv2

# data = pickle.load(open('/home/pfurlong/data/out/nss-vals.pkl','rb'))
data = pickle.load(open('/home/pfurlong/data/out/nss-restricted-vals.pkl','rb'))

nss_counts = []
for d in data:
    if d[4]:
        nss_counts.append(d[5])
    ### end if
### end for

num_counts = len(nss_counts)
nss_counts = np.array(nss_counts,dtype=np.float32).reshape((num_counts,1))

# print np.max(nss_counts)
# print np.min(nss_counts)
# print np.median(nss_counts)
# exit()

# plt.hist(nss_counts,100)
# plt.show()
# exit()
 
# init_means = np.array([[40],[60],[80]])
# gmm = mixture.GaussianMixture(n_components=3,covariance_type='full',max_iter=1000,n_init=10,means_init=init_means)
# gmm.fit(nss_counts)

# low= norm(loc=30,scale=5)
# med= norm(loc=45,scale=5)
# high= norm(loc=64,scale=2)

low= norm(loc=34.73898252,scale=4.36971614191)
med= norm(loc=45.69468184,scale=3.07952627702)
high= norm(loc=57.72973061,scale=8.60761121244)
# prediction = gmm.predict_proba(nss_counts)

out_data = []
for (idx,d) in enumerate(data):
    if idx % 1000 == 0:
        print 'Processing %d of %d'%(idx,num_counts)
#     pred = gmm.predict_proba(np.array([[d[5]]]))
    probs = [low.pdf(d[5]),med.pdf(d[5]),high.pdf(d[5])]
#     print d[5],probs
    pred = np.array(probs)/np.sum(probs)
    out_data.append(d + [pred])
    ### end if
### end for

pickle.dump(([34.73898252, 45.69468184, 57.72973061],[4.36971614191, 3.07952627702,8.60761121244]),open('/home/pfurlong/data/out/nss-restricted-centres.pkl','wb'))

pickle.dump(out_data,open('/home/pfurlong/data/out/nss-restricted-w-probs.pkl','wb'))
