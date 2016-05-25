#function configXcvr = readEKRaw_ReadTransceiverConfig(fid)
#readEKRaw_ReadTransceiverConfig  Read EK/ES transceiver configuration data
#   configXcvr = readEKRaw_ReadTransceiverConfig(fid) returns a
#       structure containing the transceiver configuration from a EK/ES raw
#       data file.
#
#   REQUIRED INPUT:
#               fid:    file handle id
#
#   OPTIONAL PARAMETERS:    None
#       
#   OUTPUT:
#       Output is a data structure containing the transceiver configuration
#
#   REQUIRES:   None
#

#   Rick Towler
#   NOAA Alaska Fisheries Science Center
#   Midwater Assesment and Conservation Engineering Group
#   rick.towler@noaa.gov
#
#   Based on code by Lars Nonboe Andersen, Simrad.

#-

#configXcvr.channelid = char(fread(fid,128,'uchar', 'l')');
#configXcvr.beamtype = fread(fid,1,'int32', 'l');
#configXcvr.frequency = fread(fid,1,'float32', 'l');
#configXcvr.gain = fread(fid,1,'float32', 'l');
#configXcvr.equivalentbeamangle = fread(fid,1,'float32', 'l');
#configXcvr.beamwidthalongship = fread(fid,1,'float32', 'l');
#configXcvr.beamwidthathwartship = fread(fid,1,'float32', 'l');
#configXcvr.anglesensitivityalongship = fread(fid,1,'float32', 'l');
#configXcvr.anglesensitivityathwartship = fread(fid,1,'float32', 'l');
#configXcvr.anglesoffsetalongship = fread(fid,1,'float32', 'l');
#configXcvr.angleoffsetathwartship = fread(fid,1,'float32', 'l');
#configXcvr.posx = fread(fid,1,'float32', 'l');
#configXcvr.posy = fread(fid,1,'float32', 'l');
#configXcvr.posz = fread(fid,1,'float32', 'l');
#configXcvr.dirx = fread(fid,1,'float32', 'l');
#configXcvr.diry = fread(fid,1,'float32', 'l');
#configXcvr.dirz = fread(fid,1,'float32', 'l');
#configXcvr.pulselengthtable = fread(fid,5,'float32', 'l');
#configXcvr.spare2 = char(fread(fid,8,'uchar', 'l')');
#configXcvr.gaintable = fread(fid,5,'float32', 'l');
#configXcvr.spare3 = char(fread(fid,8,'uchar', 'l')');
#configXcvr.sacorrectiontable = fread(fid,5,'float32', 'l');
#configXcvr.spare4 = char(fread(fid,52,'uchar', 'l')');

# R code
readEKRaw_ReadTransceiverConfig = function(fid){
	configXcvr = list()
	
		configXcvr$channelid 					= readChar(fid, 128)
		configXcvr$beamtype 					= readBin(con = fid, what = 'integer', n = 1, size = 4, signed = TRUE, endian = "little")			
		configXcvr$frequency 					= readBin(con = fid, what = 'double', n = 1, size = 4, endian = "little")								
		configXcvr$gain 						= readBin(con = fid, what = 'double', n = 1, size = 4, endian = "little")
		configXcvr$equivalentbeamangle 			= readBin(con = fid, what = 'double', n = 1, size = 4, endian = "little") 
		configXcvr$beamwidthalongship 			= readBin(con = fid, what = 'double', n = 1, size = 4, endian = "little") 
		configXcvr$beamwidthathwartship 		= readBin(con = fid, what = 'double', n = 1, size = 4, endian = "little")
		configXcvr$anglesensitivityalongship 	= readBin(con = fid, what = 'double', n = 1, size = 4, endian = "little")
		configXcvr$anglesensitivityathwartship 	= readBin(con = fid, what = 'double', n = 1, size = 4, endian = "little")
		configXcvr$anglesoffsetalongship 		= readBin(con = fid, what = 'double', n = 1, size = 4, endian = "little")
		configXcvr$angleoffsetathwartship 		= readBin(con = fid, what = 'double', n = 1, size = 4, endian = "little")
		configXcvr$posx 						= readBin(con = fid, what = 'double', n = 1, size = 4, endian = "little")
		configXcvr$posy 						= readBin(con = fid, what = 'double', n = 1, size = 4, endian = "little")
		configXcvr$posz 						= readBin(con = fid, what = 'double', n = 1, size = 4, endian = "little")
		configXcvr$dirx 						= readBin(con = fid, what = 'double', n = 1, size = 4, endian = "little")
		configXcvr$diry 						= readBin(con = fid, what = 'double', n = 1, size = 4, endian = "little")
		configXcvr$dirz 						= readBin(con = fid, what = 'double', n = 1, size = 4, endian = "little")
		configXcvr$pulselengthtable 			= readBin(con = fid, what = 'double', n = 5, size = 4, endian = "little")
		configXcvr$spare2 						= readChar(fid, 8)
		configXcvr$gaintable 					= readBin(con = fid, what = 'double', n = 5, size = 4, endian = "little")
		configXcvr$spare3 						= readChar(fid, 8)
		configXcvr$sacorrectiontable 			= readBin(con = fid, what = 'double', n = 5, size = 4, endian = "little")
		configXcvr$spare4 						= readChar(fid, 52)
		
	return(configXcvr)
}