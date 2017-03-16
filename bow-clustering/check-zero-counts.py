import cPickle

a = cPickle.load(open('/home/pfurlong/data/out/nss-vals.pkl','rb'))

date_count = {}
zero_count = {}

total = len(a)
for (idx,r) in enumerate(a):
    date = r[1].split(' ')[0]
    if idx % 100 == 0:
        print 'processing %d of %d' %(idx,total)
    if date not in date_count.keys():
        date_count[date] = 0
        zero_count[date] = 0
    ### end if
    date_count[date] += 1
    if r[5] == 0:
        zero_count[date] += 1


for k in date_count.keys():
    print k,date_count[k],zero_count[k]
