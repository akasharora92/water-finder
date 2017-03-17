import csv
import sys, os.path
import numpy as np
import cPickle
import datetime

def make_lo_hi_fields(prefix):
    low_fields = [prefix+'_'+str(i) for i in [0, 1, 2,3,4,5,6]]
    high_fields = [prefix+'_'+str(i) for i in range(10,27)]
    return (low_fields,high_fields)
### end make_lo_hi_fields

def extract_data(row,high_fields):
    high_counts = sum([int(row[x]) for x in high_fields])
    return high_counts
### end extract_data

def date_str_to_epoch(val):
	date = datetime.datetime.strptime(val,'%Y-%m-%d %H:%M:%S')
	return (date-datetime.datetime(1970,1,1)).total_seconds()
### end date_str_to_epoch


def main(filename,outfile):
	# for each image
	# find the nearest timestep and take that gps location and nss count.
	# store in csv with [filename,nn-histogram,soft-cluster,lat,long,nss]
    sn_low_fields,sn_high_fields = make_lo_hi_fields('sn')
    date_field = 'Time'
    lat_field = 'Latitude'
    lon_field = 'Longitude'
    with open(filename,'r') as csvfile:
        datareader = csv.DictReader(csvfile)#,delimiter=',',quotechar='\"')
        sn_data = []
        for (idx,row) in enumerate(datareader):
            sn_high_counts = extract_data(row,sn_high_fields)
            date_val = row[date_field]
            time_val = date_str_to_epoch(date_val)
            lat = row[lat_field]
            lon = row[lon_field]
            try:
                lat = float(lat)
                lon = float(lon)
            except ValueError:
                lat = float('nan')
                lon = float('nan')
#                 print 'row ',idx,'\n',row
#                 exit()
            ### end try
            good_data = ((sn_high_counts > 20) and (sn_high_counts < 150))
#             good_data = ((sn_high_counts > 20) and (sn_high_counts < 90))
            sn_data.append([time_val,date_val,lat,lon,good_data,sn_high_counts])
        ### end for
	cPickle.dump(sn_data,open(outfile,'wb'))	
    ### end with
### end main

if __name__=='__main__':
    infile = os.path.abspath(os.path.expanduser(sys.argv[1]))
    outfile = os.path.abspath(os.path.expanduser(sys.argv[2]))
    
    main(infile,outfile)
