import csv
import numpy as np
import os.path
import sys
import cPickle as pickle
import re 

print 'Loading data'
# nss_data = pickle.load(open('/home/pfurlong/data/out/nss-w-probs.pkl','rb'))
nss_data = pickle.load(open('/home/pfurlong/data/out/nss-restricted-w-probs.pkl','rb'))
image_data = pickle.load(open('/home/pfurlong/data/out/all-days.pkl','rb'))

print 'Extracting time values'
times = []
for d in nss_data:
    times.append(d[0])
### end for

times = np.array(times)

img_files = image_data[0]
img_vec = image_data[1]

def get_epoch(filename):
    pat = re.compile('[0-9]+')
    nums = pat.findall(filename)
    assert(len(nums) == 4)
    return float(nums[2]) + float(nums[3])*1e-6
### end get_epoch


out_data = []
out_vecs = []
out_water_probs = []

print 'Processing images'
num_images = len(img_files)
for (idx,img_file) in enumerate(img_files):
    time = get_epoch(img_file)
    # find nearest timestep.
    time_idx = np.argmin(np.fabs(times - time))

#     print time,time_idx,times[time_idx]

    # If the timestep is valid, add it to the output.
    if idx % 1000 == 0:
        print 'processing %d of %d'%(idx,num_images)
    ### end if
#     print time_idx, nss_data[time_idx]
    if nss_data[time_idx][4] == True:
        out_data.append([img_files[idx]]+nss_data[time_idx])
        out_vecs.append(img_vec[idx])
        out_water_probs.append(nss_data[time_idx][-1])
    # else the timestep is not valid, skip it.
    ### end if
### end for

# pickle.dump((out_data,out_vecs),open('/home/pfurlong/data/out/good-data-all.pkl','wb'))
# pickle.dump(out_water_probs,open('/home/pfurlong/data/out/gmm/water-probs.pkl','wb'))
pickle.dump((out_data,out_vecs),open('/home/pfurlong/data/out/good-data-restricted.pkl','wb'))
pickle.dump(out_water_probs,open('/home/pfurlong/data/out/gmm/water-probs.pkl','wb'))

