# Parse GPGGA string

parseGPGGAstring_updated = function(y, date.real) {
    #parse time and get correct date out of header 
        yy = substr(y, 8, 17) # time in hhmmss.sss from string
        dd = date.real # get correct date out of header - saved in workspace of function
        ddd = substr(dd,1,10) # get just the date
        zz = paste(ddd,yy, sep = " ") # paste the date and time together
    time = as.POSIXct(strptime(zz, "%Y-%m-%d %H%M%S"), tz = "GMT") # turn into POSIXct object with GMT as timezone
    #time = as.POSIXct(strptime(substr(y, 8, 17), "%H%M%S", tz = "GMT")) # need to figure out how to add in correct date
    latdeg = as.numeric(substr(y, 19,20))
    latmin = as.numeric(substr(y, 21, 27))/60
    lathemi = substr(y, 29, 29)
    if (lathemi == "N") {
        lat = latdeg + latmin # decimal degrees
    } else {
        lat = -(latdeg + latmin) # decimal degrees
    }
    longdeg = as.numeric(substr(y, 31, 33))
    longmin = as.numeric(substr(y, 34, 40))/60
    longhemi = substr(y, 42, 42)
    if (longhemi == "E"){
        long = longdeg + longmin  # decimal degrees
    } else {
        long = -(longdeg + longmin)
    } 
    fixquality = as.numeric(substr(y, 44, 44))
    numsatellites = as.numeric(substr(y, 46, 47))
    altitude = as.numeric(substr(y, 53,57)) # meters
GPSdata = list(time=time, 
               lat=lat, 
               long=long, 
               fixquality = fixquality, 
               numsatellites = numsatellites, 
               altitude = altitude
               )
GPSdata
}

#parseGPGGAstring(y)
#y = "$GPGGA,194530.000,3051.8007,N,10035.9989,W,1,4,2.18,746.4,M,-22.2,M,,*6B"
#time = (strptime(substr(y, 8, 17), "%H%M%S", tz = "GMT")) # need to figure out how to add in correct date


#test  = "$GPGGA,194530.000,3051.8007,N,10035.9989,W,1,4,2.18,746.4,M,-22.2,M,,*6B"
#yy = substr(test, 8, 17) # time in hhmmss.sss
#dd = as.character(data$header[[1]]$time) # get correct date out of header
#ddd = substr(dd,1,10) # get just the date
#zz = paste(ddd,yy, sep = " ") # paste the date and time together
#xx = as.POSIXct(strptime(zz, "%Y-%m-%d %H%M%S"), tz = "GMT") # turn into POSIXct object with GMT as timezone

