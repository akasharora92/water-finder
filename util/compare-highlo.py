import csv
import sys, os.path
import matplotlib.pyplot as plt
import numpy as np

def make_lo_hi_fields(prefix):
    low_fields = [prefix+'_'+str(i) for i in [0, 1, 2,3,4,5,6]]
    high_fields = [prefix+'_'+str(i) for i in range(10,27)]
    return (low_fields,high_fields)
### end make_lo_hi_fields

def extract_data(row,low_fields,high_fields):
    low_counts = sum([int(row[x]) for x in low_fields])
    high_counts = sum([int(row[x]) for x in high_fields])
    return (low_counts,high_counts)
### end extract_data

def smooth(x,window):
    y = x
    if not (window == None):
        window_len = len(window)
        s = np.r_[x[window_len-1:0:-1],x,x[-1:-window_len:-1]]
        y = np.convolve(window/window.sum(),s,mode='valid')
    ### end if
    return y
### end smooth

def main(filename):
    #cd_fields = ['cd_'+str(i) for i in range(32)]
#     sn_fields = ['sn_'+str(i) for i in range(32)]
    cd_low_fields,cd_high_fields = make_lo_hi_fields('cd')
    sn_low_fields,sn_high_fields = make_lo_hi_fields('sn')

    with open(filename,'r') as csvfile:
        datareader = csv.DictReader(csvfile)#,delimiter=',',quotechar='\"')
        cd_data = []
        sn_data = []
        for (idx,row) in enumerate(datareader):
            #cd_counts = sum([int(row[x]) for x in cd_fields])
#             sn_counts = sum([int(row[x]) for x in sn_fields])
            sn_low_counts,sn_high_counts = extract_data(row,sn_low_fields,sn_high_fields)
            cd_low_counts,cd_high_counts = extract_data(row,cd_low_fields,cd_high_fields)
            
            good_data = ((sn_low_counts/float(len(sn_low_fields))) <= 10.) and (sn_high_counts > 20) and (sn_high_counts < 150)
            if (good_data):
                sn_data.append([sn_low_counts, sn_high_counts])
                cd_data.append([cd_low_counts, cd_high_counts])
            ### end if
        ### end for
        sn_data = np.array(sn_data)
        cd_data = np.array(cd_data)

        plt.figure(1)
        plt.plot(sn_data[:,0],sn_data[:,1],'x')
        plt.xlabel('Sn low field counts')
        plt.ylabel('Sn high field counts')
        plt.title('Low vs high Sn counts')

        plt.figure(2)
        plt.plot(cd_data[:,0],cd_data[:,1],'x')
        plt.xlabel('Cd low field counts')
        plt.ylabel('Cd high field counts')
        plt.title('Low vs high Cd counts')


#         smoothing_kernel = np.hanning(11)
        smoothing_kernel = np.ones(11,'d')
#         smoothing_kernel = None
        
        sn_smoothed = smooth(sn_data[:,1].T,smoothing_kernel)
        cd_smoothed = smooth(cd_data[:,1].T,smoothing_kernel)

        plt.figure(3)
        plt.subplot(2,1,1)
        plt.plot(range(len(sn_smoothed)),sn_smoothed)
        plt.ylabel('Sn high counts')
        plt.subplot(2,1,2)
        plt.plot(range(len(cd_smoothed)),cd_smoothed)
        plt.xlabel('Time (arbitrary units)')
        plt.ylabel('Cd high counts')


        plt.show()
    ### end with
### end main



if __name__=='__main__':
    filename = os.path.abspath(os.path.expanduser(sys.argv[1]))
#     prefix = sys.argv[2]
    main(filename)
