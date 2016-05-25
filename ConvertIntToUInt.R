#'#Stolen from package bmp
#' Fix a 32 bit unsigned integer that has been read as signed
#' 
#' This is really just to fix a limitation of readBin/R's 32 bit signed ints  
#' @param x Number to be fixed 
#' @param adjustment number to be added to convert to uint32 (2^32 by default)
#' @return numeric value of uint32
#' @author jefferis
#' @seealso \code{\link{readBin}}

ConvertIntToUInt<-function(x,adjustment=2^32){
    x=as.numeric(x)
    signs=sign(x)
    x[signs<0]=x[signs<0]+adjustment
    x
}
