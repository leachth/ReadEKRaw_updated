# Echogram.pixel creates an echogram with a scale bar.
# z is the data matrix of backscatter values created from the CreateMatrix object
# data must be specified within the global environment as the data object from ReadEKRaw/ConvertPower/FindBottom2
Echogram.pixel = function(data 
                            , nf = 1
                            , use.bottom.line = TRUE 
                            , bottom.line.offset = 1
                            , threshold = -30 
                            , x = seq(1, length(data$pings), by = 1)
                            #x = data$dist.alongtrans
                            , y = data$pings[[2]]$rangeCorrected
                            , ylim = rev(c(0, max(data$bottom.line + bottom.line.offset)))
                            , zstart = -70
                            , zend = -30
                            , xlim = range(x, finite=TRUE)
                            , zlim = c(zstart, zend) # redefine these by zstart and zend
                            , filename # this must be specified to the file can be written
                            , height = 5 # of image file
                            , width = 7 # of image file
                            , ppi = 300 # resolution of image
                            , nlevels = 15
                            , levels = pretty(zlim, nlevels) # redefine this by zstart and zend
                            , plot.title = ""
                            , key.title = "Sv"
                            , xlab = " Index"
                            , asp = NA 
                            , xaxs = "i" 
                            , yaxs = "i"
                            , las = 1)
                        {
  
  col = colorRampPalette(c("white", "gray70", "gray40", "dodgerblue1","dodgerblue4", 
                           "springgreen4","springgreen2" ,"yellow", "orange", 
                           "deeppink", "red", "red3")
                                   , bias = 1
                                   , space = "rgb")(length(levels) - 1)

  # create the data matrix for plotting by calling the CreateMatrix function internally
  z = CreateMatrix(data
                   , nf = nf
                   , use.bottom.line = use.bottom.line
                   , bottom.line.offset = bottom.line.offset
                   , threshold = threshold)
  
  # define the plot destination, filename and size
      png(file = filename, width = width*ppi, height = height*ppi, res = ppi)
  
  # define the plot margins and layout
    mar.orig <- (par.orig <- par(c("mar","las","mfrow")))$mar
    on.exit(par(par.orig))
    w <- (3 + mar.orig[2L]) * par("csi") * 2.54
    layout(matrix(c(2, 1), ncol = 2L), widths = c(1, lcm(w)))
    par(las = las)
  
  ## Plot the 'plot key' (scale bar):
      mar <- mar.orig
      mar[4L] <- mar[2L]
      mar[2L] <- 1
      par(mar = mar)
      plot.new()
      plot.window(xlim = c(0,1), ylim = range(levels), xaxs = "i", yaxs = "i")
      rect(0, levels[-length(levels)], 1, levels[-1L], col = col)
      axis(4)
      box()
      mtext(key.title, side = 3)
  
      
      unik <- !duplicated(x)  ## logical vector of unique values
      seq_along(x)[unik]  ## indices
      z = z[,unik] ## the values
      x = x[unik]
      
  ## Plot contour-image::
      mar <- mar.orig
      mar[4L] <- 1
      par(mar = mar)
      #plot.new()
      #ylim = rev(c(0, max(data$bottom.line + bottom.line.offset))
      plot.window(xlim, ylim = ylim, "", xaxs = xaxs, yaxs = yaxs, asp = asp)
      image(x = x
            , y = y
            , z = t(z)
            , zlim=c(zstart , zend)
            , ylim = rev(c(0, max(data$bottom.line + bottom.line.offset)))
            #, ylim=rev(range(y))
            , col = col
            , ylab="Depth (m)"
            , xlab = xlab
            , xaxt="n"
            , yaxt="n"
            #, breaks = breaks
            , main = plot.title
      )
      axis(side = 2)
      axis(side = 1, pos = max(data$bottom.line + bottom.line.offset), tck = -0.025)
      lines(x = x, y = data$bottom.line[unik], col="black", lwd = 1)
  
  dev.off()
}

# example
#Echogram.pixel(data, filename = "RPpixelfunction.png",plot.title = "Rock Pond", threshold = -45, use.bottom.line = TRUE)
