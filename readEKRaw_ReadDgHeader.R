#function [dgType, dgTime] = readEKRaw_ReadDgHeader(fid, timeOffset)
#READEKRAW_READDGHEADER  Read EK/ES DG datagram header
#   dgheader = readEKRaw_ReadDgHeader(fid, timeOffset) returns the datagram type
#   and time. Time is returned in MATLAB serial time.
#
#   REQUIRED INPUT:
#               fid:    file handle id
#        timeOffset:    Offset, in hours, to add to the datagram timestamp.
#                       timeOffset can be used to syncronize pings with GPS time
#                       in datasets which were collected with a misconfigured
#                       PC clock.
#
#   OPTIONAL PARAMETERS:    None
#       
#   OUTPUT:
#       Output is two scalar variables - one containing the datagram type, the
#       other the datagram time converted to MATLAB serial time.
#
#   REQUIRES:   None
#

#   Rick Towler
#   NOAA Alaska Fisheries Science Center
#   Midwater Assesment and Conservation Engineering Group
#   rick.towler@noaa.gov


#  read datagram type
#dgType = char(fread(fid,4,'uchar', 'l')');

#  read datagram time (NT Time - number of 100-nanosecond 
#  intervals since January 1, 1601)
#lowdatetime = fread(fid,1,'uint32', 'l');
#highdatetime = fread(fid,1,'uint32', 'l');

#  convert NT time to MATLAB serial time
#ntSecs = (highdatetime * 2 ^ 32 + lowdatetime) / 10000000;
#dgTime = datenum(1601, 1, 1, timeOffset, 0, ntSecs);


# R function

readEKRaw_ReadDgHeader = function(fid) {
		# read datagram type

			dgType = readChar(fid, 4)
		# read datagram time 
			lowdatetime = readBin(
								con  	= fid,
								what 	= 'integer',
								n    	= 1,
								size 	= 4,
								signed  = TRUE,
								endian 	= "little")
            lowdatetime = ConvertIntToUInt(lowdatetime)
        
			highdatetime = readBin(
								con  	= fid,
								what 	= 'integer',
								n    	= 1,
								size 	= 4,
								signed  = TRUE,
								endian 	= "little")
		    highdatetime = ConvertIntToUInt(highdatetime)
        
		# convert NT time 
			ntSecs = (highdatetime	* 2^32 + lowdatetime)/ 10000000
			dgTime = as.POSIXct(ntSecs, origin = "1601-01-01", tz = "GMT") # time zone defaults to GMT, can set differently if needed
	
	return(list(dgType = dgType, dgTime = dgTime))
					
	}					 
