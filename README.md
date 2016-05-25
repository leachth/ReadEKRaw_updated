# ReadEKRaw_updated
1. ReadEKRaw
Description: parse the binary .raw files obtained from a Simrad Ex60 transceiver. 

Input: file path name to a .raw file from a Simrad Ex60 transceiver 

Output: list containing three lists: 
    (1) header 	contains the header information for the file, and transceiver(s) including transceiver configuration and settings.
    (2) pings 		contains data from each ping as a list 
    (3) GPS 		GPS data for each ping in .raw file containing the following parameters:
            time 	time of ping in POSIXct format, times are correct but the date will show the date the function was run,       not the date the data were collected (the header date is correct). No current work around.
            lat			latitude in decimal degrees
            long 			longitude in decimal degrees
            fixquality 		fix quality of reading, 1 = fix, 0 = no fix
            numsatellites 	number of satellites tracking
            altitude 		measured as meters above sea level


Dependencies:
 ReadEKraw_Header
 ReadEKraw_DgHeader
 ConvertInttoUInt
 ReadEKraw_Configheader
 ReadEKraw_TransceiverConfig
 ReadEKraw_ReadSampledata
 ParseGPGGAstring

2. ReadEKRaw_ConvertPower
Description: Converts power measurements obtained in the ReadEKRaw into Sv (dB re 1 m-1) is defined as the (Mean) Volume backscattering strength (MVBS) using the following formulas:

Sv                = power + TVG + (2*alpha*rangeCorrected) – CSv - Sac
TVG               = (20*log10 (rangeCorrected))
CSv               = 10 * log10 (pt* 10G/10) 2 * lambda2 * cv * tau * (10phi/10) / 32* pi2
G 				        = gain
phi			          = equivalent beam angle
cv 			          = sound velocity; called c in the original Matlab code
t 				        = sample interval 
alpha 			      = absorption coefficient 	
pt 				        = transmit power
tau 			        = pulse length
dR 			          = cv * t / 2; calculate sample thickness (in range)
lambda 		      	= cv / f; calculate wavelength
Sac 			        = Sa correction
rangecorrected 		= power * dR

Input:  data structure from ReadEKRaw  (i.e. ReadEKRaw must be run first)

Output: data structure from ReadEKRaw with an additional vector of Sv and rangeCorrected (which is essentially depth) for each ping. This also add the gain and equivalent beam angel for the header to each ping element, this ensures that each ping element contains all of the information necessary to convert power to Sv.

3. FindBottom_updated
Description: Finds the bottom depth for each ping in a ReadEKRaw_ConvertPower data object (i.e., you must run ReadEKRaw and then ConvertPower first). Adds a vector named bot.depth to each object in data$pings. Also generates an invisible vector called bottom.line where each element is the bottom depth at all indexed value in 1:length(data$pings), this vector is created for ease of plotting or other analyses.

Input: data structure from the ReadEKRaw_ConvertPower

Output: data$ping$bot.depth 	data structure from ReadEKRaw_ConvertPower with an additional vector of bot.depth for each ping. 

data$bottom.line		adds new list to data that is a vector that contains all of the bot.depth values for every ping in the file for ease of plotting 
nf 	= near field range in meters, user specified, defines the depth range from 0 - nf to exclude; defaults is 1 m
d 	= discrimination level in dB, pixels below this value are not considered when finding the bottom; default is -30 dB  


4. SubsetData_updated
Description: function to subset data based on user specified start and end time or by GPS lat/longs; intended to subset data files into the individual transects from each lake that can then be plotted or further analyzed. Remember, that plotting function only works if the first ping in the data set is the start of the transect.

Input: data structure from ReadEKRaw_Convert Power as well as FindBottom2, although the FindBottom2 is not necessary.
start 	time at start of transect or sampling period as character in format "YYYY-MM-DD HH:MM:SS GMT" or decimal degrees as a number with form c(lat, long)
end	same as above but for end time. 
method	specified by user as either "time" or "latlong", must match units in start and end

Output: A data object with all elements as input data but from start to end only. 

5. CreateMatrix 
Description: creates data matrix for pings and depth intervals for sampling input, to be used for plotting or further data analysis. Echogram.pixel usesd CreateMatrix.

Input: 

data              		data object from that comes out of ReadEKRaw(fname) & ReadEKRaw_ConvertPower(data). If matrix is to be constrained above the lake bottom then the data object must have also been processed by the FindBottom2(data). Currently handles data objects with 710 kHz frequency.
nf  		= nearfield distance, offset below surface in meters to be excluded from matrix; default is 0 
use.bottom.line   	= Use the lake bottom as bottom depth of the matrix; default is FALSE

bottom.line.offset 	value to specify depth offset in meters below (positive values) or above (negative values) the bottom line that are to be plotted; default is 0 m.
threshold         		data with backscatter (dB) stronger than this value are turned to NA's  in data matrix. Use this to remove possible scatter from fish. Default is -30 dB.


Output: data matrix of backscatter for each ping at each depth interval.

6. Echogram.pixel
Description: writes and echogram with key to a .png file

Input: data object from ReadEKRaw, ConvertPower and FindBottom
filename 	file name in the form “filename.png”; must be specified so the file can be written
height 	value in inches that specifies the height of the image; default is 5.
width 	value in inches that specifies the width of the image; default is 7.

ppi 	resolution of image; default is 300, make smaller for smaller image files                   
nlevels 			number of levels for color scale; default is 15
                            
                    plot.title 			character vector in quotes to label plot; default is “”
                    
key.title 	character vector in quotes of title of color key; default is “Sv"

xlab 	character vector in quotes of title of color key; default is  “Index"

nf  	nearfield distance, offset below surface in meters to be excluded from plot; default is 1 

use.bottom.line  	default is TRUE, when set to default only backscatter from the bottom line offset to the nf range are plotted. 

bottom.line.offset 	value to specify depth offset in meters below (positive values) or above (negative values) the bottom line that are to be plotted; default is 1 m.

threshold         	data with backscatter (dB) stronger than this value are excluded. Use this to remove possible scatter from fish; default is -30 dB.
  							
x 	vector of values to be used for the x-axis. Must be the same length as number of pings; default is a vector 1:length(pings).
zstart 			lowest value of z (backscatter); default is -70 dB
                          
zend 			highest value of z (backscatter); default is -30 dB

y 	vector of depth intervals form sample data; default is data$pings[[2]]$rangeCorrected. THIS SHOULD NOT BE CHANGED.
                 
ylim 	range of y values; default is rev(c(0, max(data$bottom.line + bottom.line.offset))), THIS SHOUKD NOT BE CHANGED.
                         

levels	pretty separations for colors of z and scale bare. THIS SHOULD NOT BE CHANGED 
xlim 	range of x values; default is range(x, finite=TRUE). THIS SHOULD NOT BE CHANGED.
                    
zlim  	range of z values base on zstart and zend, THIS SHOULD NOT BE CHANGED.
 
Output:  .png file of echogram with legend.







7. DistTransect 
Description: for each ping in data file estimates distance along transenct. Note that this is different as distance from shore. The start of the transect needs to be the first point in the data for this to work, so SubsetData must have already been used.
Input: 

data              		data object from that comes out of ReadEKRaw(fname) & ReadEKRaw_ConvertPower(data) and SubsetData. The start of the transect needs to be the first point in the data for this to work, so SubsetData must have already been used.

Output: 	creates a new vector to data list named data$dist.alongtrans that contains distance from beginning of transect for each ping. Within each ping an element called GPS$dist.alongtrans is also created that indicated the distance along the transect for that specific ping. 



