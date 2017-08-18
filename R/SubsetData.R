# SubsetData: function to subset data based on user specified start and end time or by GPS lat/longs;
# intended to subset data files into the individual transects from each lake
# that can then be plotted or further analyzed. Remember, that plotting function
# only works if the first ping in the data set is the start of the transect.

# input is a data object from ReadEraw, ConvertPower or FindBottom
# 		start 				time as character in format:"YYYY-MM-DD HH:MM:SS GMT"
# 		end				  	or decimal degrees as a number with the form c(lat,long)
#
#		method 				specified by user as either "time" or "latlong", must match units in start and end

#' @title SubsetData
#' @description function to subset data based on user specified start and end time or by GPS lat/longs
#'
#'
#' @param data a data object from ReadEKRaw, ConvertPower or FindBottom
#' @param start time as character in format:"YYYY-MM-DD HH:MM:SS GMT" or decimal degrees as a number with the form c(lat,long)
#' @param end see start
#' @param method specified by user as either "time" or "latlong", must match units in start and end
#'
#' @return individual transects from each lake that can then be plotted or further analyzed. Remember, that plotting function only works if the first ping in the data set is the start of the transect.
#' @export
#'
SubsetData = function(data, start, end, method){

  	idx.select = c() # empty vector to store the index values in.

  	# assess method time, then find appropriate index values accordingly
    	# TIME
    	if(method == "time"){
        	# turn start and end times into as.POSIXct and then as.numeric
            	s.time.num  = as.numeric(as.POSIXct(strptime(start, "%Y-%m-%d %H:%M:%S"), tz = "GMT"))
            	e.time.num  = as.numeric(as.POSIXct(strptime(end, "%Y-%m-%d %H:%M:%S"), tz = "GMT"))
            # for loop to check if [i] is between start and end times
                for (i in 1:(length(data$GPS))){
                  # pull out time from data$GPS
                  		t = as.numeric(data$GPS[[i]]$time)
                  # compare t to start and end time (must be between)
                  		if((t >= s.time.num & t <= e.time.num) == TRUE ){
                    			idx = i
                  		} else {
                  		  idx = NA
                  		  }
                  # add idx to vector
						idx.select = c(idx.select, idx)
                }
        }

    	# LATLONG
    	if(method == "latlong"){
    		# re-write the start and end lat/longs into lats and longs
				lats = c(start[1], end[1])
				longs = c(start[2], end [2])
  			# for loop to seach for inclusion in subset based on lat, long
  				for (i in 1:(length(data$GPS))){
    				# pull out time from data$GPS
    					lat = as.numeric(data$GPS[[i]]$lat) # needs to be as numeric to keep all of the decimal places
    					long = as.numeric(data$GPS[[i]]$long)

    				# check if each i fall within the range of lat/longs specified by user
    					if((lat >= min(lats) & lat <= max(lats) & long >= min(longs) & long <= max(longs)) == TRUE ){
      						idx = i
    					} else {
    					  idx = NA
    					}
    			# add idx to vector
						idx.select = c(idx.select, idx)
  				}
    	}

  ## generate new data object that is only the subset specified by user
  		# idx values
    		idx.min  = min(idx.select, na.rm = TRUE) #  start index value
    		idx.max  = max(idx.select, na.rm = TRUE) #  stop index value

  	# check if FindBottom has been run already - this makes it so data is subset regardless of whether user has run FindBottom on data yet

  			if(is.null(data$bottom.line) == TRUE) {
                      			  data.new  = list(header = data$header # this keeps the entire header with the data
                      			                   , pings = data$pings[idx.min:idx.max]
                      			                   , GPS = data$GPS[idx.min:idx.max]
                      			                   #, bottom.line = data$bottom.line[idx.min: idx.max]
                     									        )

  			} else {
  			  										data.new  = list(header = data$header # this keeps the entire header with the data
                     									        , pings = data$pings[idx.min:idx.max]
                     									        , GPS = data$GPS[idx.min:idx.max]
                     									        , bottom.line = data$bottom.line[idx.min:idx.max]
                     									        )
  			}

  data.new # return the subset of the data
}
