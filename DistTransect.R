# GPS data
library(sp)
library(geosphere)

## **the start of the transect needs to be the first point in the data for this to work!
# write a function that allows the used to specify the approx. GPS of the start of the transect
# and subset the data based on that. 


DistTransect = function(data){

    # create empty 'distance along transect' vector
          dist.alongtrans = c()
    # create empty dataframe for lat, long of transect for plotting
          lat.long.df = data.frame()
    # specify lat long of start point #this  must be the first point in the data frame
          lat.start = data$GPS[[1]]$lat
          long.start = data$GPS[[1]]$long 
    # calculate distances from GPS data for each point in the data
          for (i in 1:(length(data$GPS))){
            # pull out lat, long of the point
                lat = data$GPS[[i]]$lat
                long = data$GPS[[i]]$long
            # pull out lat,long of previous pt. 
            # if this is the first point of the transect then lat, long from previous pt is equal to lat, long at that point
                if (i == 1){
                  lat.prev = data$GPS[[i]]$lat
                  long.prev = data$GPS[[i]]$long
                } else {
                  # pull out lat, long of previous point
                      lat.prev = data$GPS[[i-1]]$lat
                      long.prev = data$GPS[[i-1]]$long
                  }
            # calculate distance from start point in meters (this assumes transect is a straight line)
                  dist.start = distGeo(c(lat.start,long.start),c(lat,long))
            # calculate distance from previous point (use this to estimate distance along transect when the transect is not straight)
                  dist.prev = distGeo(c(lat.prev,long.prev),c(lat,long))
            # calculate distance along transect, assign distance along transect as zero for first point in data
                  if (i == 1){
                              dist.on.trans = 0
                      } else {
                              dist.on.trans = data$GPS[[i-1]]$dist.on.trans + dist.prev 
                      }

            # create object within data$GPS[[i]] that contains distance from start point
                data$GPS[[i]]$dist.from.start = dist.start
            # create object within the data$GPS that contains the distance from the previous point
                data$GPS[[i]]$dist.from.prev = dist.prev 
            # create object within the data$GPS that contains the distance along the transect not assuming a straight line
                data$GPS[[i]]$dist.on.trans = dist.on.trans
  
          # add distance along transect for point i to a vector    
                dist.alongtrans = c(dist.alongtrans, dist.on.trans)
          
          # add lat and long to data 
                tmp = data.frame(lat = lat, long = long)
                lat.long.df = rbind(lat.long.df, tmp) 
                
          }
          
          # add distance along transect to data as new list for ease of plotting
              data$dist.alongtrans = dist.alongtrans
          # add lat, long of data as new element for ease of plotting
              data$lat.long.df = lat.long.df
              
          return(data)
    }
          