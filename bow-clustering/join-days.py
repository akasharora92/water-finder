import cPickle
import numpy as np
import re

import sys,os.path

days = ['GROUNDCAM-20141019.pkl','GROUNDCAM-20141020.pkl','GROUNDCAM-20141021.pkl','GROUNDCAM-20141022.pkl','GROUNDCAM-20141023.pkl','GROUNDCAM-20141024.pkl','GROUNDCAM-20141025.pkl']
filenames = []
data = []
for d in days:
    a = cPickle.load(open(os.path.join('/home/pfurlong/data/out/',d),'rb'))
    print 'reading ', d
    print 'files,data', (len(a[0]),len(a[1]))
    filenames = filenames + a[0]
    data = data + a[1]
### end for

print 'num filenames: ', len(filenames)
print 'num data: ', len(data)

cPickle.dump((filenames,data),open('/home/pfurlong/data/out/all-days.pkl','wb'))

# Get all the files to merge.
# Load them
# merge them
