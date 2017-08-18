ConvertIntToUInt<-function(x,adjustment=2^32){
    x=as.numeric(x)
    signs=sign(x)
    x[signs<0]=x[signs<0]+adjustment
    x
}
