#' @title ReadEKRaw
#'
#' @description parse the binary .raw files obtained from a Simrad Ex60 transceiver
#'
#' @param fname character path to a .raw file from Simrad Ex60 transceiver
#'
#' @return list containing 3 elements:
#'
#' \tabular{ll}{
#' header \tab contains the header information for the file, and transceiver(s) including transceiver configuration and settings. \cr
#' pings \tab contains data from each ping as a list \cr
#' GPS \tab GPS data for each ping in .raw file (see
#' }
#'
#' @export
ReadEKRaw = function(fname){
  fid = file(fname, open = "rb")
  HEADER_LEN = 12
  # create empty lists to store pings and GPS data
  #datatypes = c()
  pings = list()
  GPS = list()

  # read header
  header = ReadHeader(fid)

  # pull out correct date from header
  date.real = header$header$time

  while(TRUE){
    datagram.length = readBin(
      con      = fid,
      what 	= 'integer',
      n    	= 1,
      size 	= 4,
      signed  = TRUE,
      endian 	= "little")

    if(length(datagram.length) == 0){
      warning('End of file...\n')
      break;
    }
    #read the datagram header
    nextHeader = ReadDgHeader(fid)
    #dtype = nextHeader$dgType
    #datatypes =  c(datatypes, dtype)

    # read NME0 datagram type
    if (nextHeader$dgType == "NME0") {
      nchar = datagram.length-HEADER_LEN
      GPSdata = readChar(fid,nchar)
      if(substr(GPSdata, 1,6) == "$GPGGA"){
        x = parseGPGGAstring(GPSdata, date.real) # function to parse the GPSdata string, output is a list
        #x = parseGPGGAstring(GPSdata)
        #GPS[[length(GPS)+1]] = GPSdata
        GPS[[length(GPS)+1]] = x
      }
      # read RAW0 datagram type
    }else if(nextHeader$dgType == "RAW0"){
      samples = ReadSampledata(fid)
      pings[[length(pings)+1]] =  samples

    } else {
      seek(fid, datagram.length-HEADER_LEN, origin="current")
    }
    datagram.length2 = readBin(
      con      = fid,
      what     = 'integer',
      n    	= 1,
      size 	= 4,
      signed  = TRUE,
      endian 	= "little")
  } # end of while loop
  data = list(header = header, pings = pings, GPS = GPS)
  close(fid)
  data
} # end of function
