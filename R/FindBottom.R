#' @title FindBottom
#'
#' @description Find bottom in backscatter matrix.
#'
#' @param data A ReadEKRaw_ConvertPower data object (i.e., you must run ReadEKRaw and then ConvertPower first). A list of three objects called data, (1) File header, (2) pings, (3) GPS data. These three objects are themselves lists.
#'
#' @param nf near field range in meters, user specified, defines the depth range from 0 - nf to exclude; defaults is 1 m
#'
#' @param d discrimination level in dB, pixels below this value are not considered when finding the bottom; default is -30 dB. Echoview default is -50 dB
#'
#' @param smooth defaults to TRUE
#'
#' @return adds a vector named bot.depth to each object in data$pings. Also generates a new element to data called bottom.line  that is a vector of the bottom depths at all indexed value in 1:length(data$pings), this vector is created for ease when plotting or other analyses.
#'
#' @import zoo
#' @export
FindBottom = function(data, nf = 1, d = -30, smooth = TRUE){

  # create empty bottom.line vector
        bottom.vec = c()

  # estimate bottom depth based on maximum Sv above discrimination level
        for (i in 1:(length(data$pings))){
              # define depths of interest, excluding nf
                  tmp.nf = (data$ping[[i]]$rangeCorrected <= nf)
                  idx = which(tmp.nf == FALSE)  # finds all indices for rangeCorrected that are within the nf range
                  end = length(data$pings[[i]]$Sv)
              # define the data to use excluding nearfield.
                  tmp = data$pings[[i]]$Sv[idx[1]:end]
              # turn any value with Sv that is smaller than the discrimination level to an NA
                  tmp[tmp < d] <- NA
              # within this data, find the index value of the max Sv value
                  max.value  = which.max(tmp)
              # find the max. depth from rangeCorrected
                  # if there is not pixel within a ping that is above discrimination level - and therefore no bottom the length of max.value = 0
                      if (length(max.value) == 0 ) {
                        bot.depth = NA
                        }
                      if(length(max.value)!= 0){
                        # use the index specified by max.value to find the max depth
                        idx.to.add = idx[1]-2 # this corrects for the index value offset
                        bot.depth = data$pings[[i]]$rangeCorrected[max.value + idx.to.add]
                        #bot.depth = data$pings[[i]]$rangeCorrected[max.value]

                        }

              # add bot.depth to bottom.line vector for smoothing and easy plotting
                  bottom.vec = c(bottom.vec, bot.depth)
        }


  # now deal with the NA's in bottom line and smooth the bottom line
      # fill in NA's with linear interpolation
          bottom.vec = na.fill(na.approx(bottom.vec, na.rm = FALSE), "extend")

      # smooth the bottom line, user can skip the smooth of the bottom line
        if(smooth == TRUE){
          bottom.vec = smooth(bottom.vec)
        }

      # at some point will need to be able to deal with cases when the depth of the lake is over the instrument range...

      # add bottom line to data as new, 4th list
              data$bottom.line = bottom.vec

    ## now add smoothed bottom depth at each ping
     # for loop
              for (i in 1:(length(data$pings))){
                # add a new list to data that contains the bottom depth at each ping
                data$pings[[i]]$bot.depth = data$bottom.line[i]
              }

            return(data)
}


