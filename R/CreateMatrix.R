#' @title CreateMatrix
#'
#' @description Create data matrix for plotting and analysis.
#'
#'
#' @param data must be a data object that comes out of ReadEKRaw(fname) & ReadEKRaw_ConvertPower(data).
#' If matrix is to be constrained above the lake bottom then the data object must have also been processed by the FindBottom2(data).
#  Currently handles data objects with 710 kHz frequency.
#' @param nf nearfield distance, offset below surface in meters
#' @param use.bottom.line Use the lake bottom to bottom depth of the matrix; default is FALSE
#' @param bottom.line.offset depth offset from bottom in meters, default is 0 (can also be a negative number)
#' @param threshold data with backscatter (dB) stronger than this value are turned to NA's. Use this to remove possible scatter from fish
#'
#' @return data matrix of backscatter for each ping at each depth interval
#' @export
#'
#' @examples
#' z = CreateMatrix(data, nf = 0.5, use.bottom.line = TRUE, bottom.line.offset = 0, threshold = -30)
CreateMatrix = function(data, nf = 0, use.bottom.line = FALSE, bottom.line.offset = 0, threshold = -30){

  # create empty matrices to store Sv: depth intervals are rows and each ping is a column
        Svoutput120 = matrix(, nrow = length(data$pings[[1]]$Sv), ncol = length(data$pings))
        Svoutput710 = matrix(, nrow = length(data$pings[[2]]$Sv), ncol = length(data$pings))

            # fill matrix from data$pings
            for (i in 1:length(data$pings)) {
              if (data$pings[[i]]$frequency == 120000){
                tmp = (data$pings[[i]]$Sv)
                Svoutput120[,i] = tmp
              } else if(data$pings[[i]]$frequency == 710000) {
                tmp = (data$pings[[i]]$Sv)
                Svoutput710[,i] = tmp
              }
            } # end of function that fills maxtrix from data$pings

  # get rid of NA columns - not sure why I need this...
        #Svoutput120 = Svoutput120[,!is.na(Svoutput120[1,])]
        #Svoutput710 = Svoutput710[,!is.na(Svoutput710[1,])]
  # turn Sv values in nf to NA's
        # find index values that include the nf range
            tmp.nf = (data$ping[[1]]$rangeCorrected <= nf)
            idx = which(tmp.nf == FALSE)  # finds all indices for rangeCorrected that are within nf range
            #end = length(data$pings[[i]]$Sv)
        # so we want turn the first idx[i]-1 number of rows in the entire matrix into NA's
            Svoutput710[1:idx[1]-1,] <- NA

  # THRESHOLD: deal with threshold dB in matrix SVoutputxxx we want to replace all values above the threshold with NA's
        Svoutput710[Svoutput710 > threshold] <- NA

  # BOTTOM.LINE: deal with the bottom.line
        if (use.bottom.line == TRUE){
          # constrain the data matrix by the bottom.line + the offset
              # estimate depth interval
                depth.interval = data$pings[[5]]$rangeCorrected[3] - data$pings[[5]]$rangeCorrected[2]
              # find number of row offset (if negative this indicates that only data above lake bottom should be included)
                num.offset.rows = round(bottom.line.offset/depth.interval, digits = 0)
              # define matrix using the bottom line
                end.no = length(data$pings[[i]]$Sv)
                for (ii in 1:(ncol(Svoutput710))){
                    # pull depth out of bottom.line
                      bot.depth = data$bottom.line[ii]
                    # find index value within rangeCorrected that corresponds to bot.depth
                      tmp.depth = (data$ping[[1]]$rangeCorrected <= bot.depth)
                      idx2 = which(tmp.depth == FALSE)
                      start.no = min(idx2[1]+num.offset.rows, end.no)
                    # for each data column cells from the idx + num.row.offset to the end need to become NA's
                      #tryCatch({
                      Svoutput710[(start.no:end.no),ii] <- NA
                      #}, error=function(e){print(ii);stop(e)})
                }# end of forloop

        }

  return(Svoutput710)
}
