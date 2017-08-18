# Echogram.pixel creates an echogram with a scale bar.
# z is the data matrix of backscatter values created from the CreateMatrix object
# data must be specified within the global environment as the data object from ReadEKRaw/ConvertPower/FindBottom2
#' @title Echogram
#' @description creates an echogram with a scale bar
#'
#'
#' @param data object from \code{\link{ConvertPower}} or \code{\link{FindBottom}}
#' @param nf nearfield distance, offset below surface in meters to be excluded from plot; default is 1
#' @param use.bottom.line default is TRUE, when set to default only backscatter from the bottom line offset to the nf range are plotted.
#' @param bottom.line.offset value to specify depth offset in meters below (positive values) or above (negative values) the bottom line that are to be plotted; default is 1 m.
#' @param threshold data with backscatter (dB) stronger than this value are excluded. Use this to remove possible scatter from fish; default is -30 dB.
#' @param x vector of values to be used for the x-axis. Must be the same length as number of pings; default is a vector 1:length(pings).
#' @param y vector of depth intervals form sample data; default is data$pings[[2]]$rangeCorrected. THIS SHOULD NOT BE CHANGED.
#' @param ylim range of y values; default is rev(c(0, max(data$bottom.line + bottom.line.offset))), THIS SHOUKD NOT BE CHANGED.
#' @param zstart lowest value of z (backscatter); default is -70 dB
#' @param zend highest value of z (backscatter); default is -30 dB
#' @param xlim range of x values; default is range(x, finite=TRUE). THIS SHOULD NOT BE CHANGED.
#' @param zlim range of z values base on zstart and zend, THIS SHOULD NOT BE CHANGED.
#' @param filename file name in the form “filename.png”; must be specified so the file can be written
#' @param height value in inches that specifies the height of the image; default is 5
#' @param width value in inches that specifies the width of the image; default is 7
#' @param ppi resolution of image; default is 300, make smaller for smaller image files
#' @param nlevels number of levels for color scale; default is 15
#' @param levels pretty separations for colors of z and scale bare. THIS SHOULD NOT BE CHANGED
#' @param plot.title character vector in quotes to label plot; default is “”
#' @param key.title character vector in quotes of title of color key; default is “Sv"
#' @param xlab character vector in quotes of title of color key; default is  “Index"
#' @param asp aspect ratio y/x, default NA. See \code{\link[graphics]{plot.window}} for more information.
#' @param xaxs x axis interval calculation style. Default "i", see \code{\link[graphics]{par}} for more information.
#' @param yaxs x axis interval calculation style. Default "i", see \code{\link[graphics]{par}} for more information.
#' @param las axis label style. See \code{\link[graphics]{par}}
#'
#' @export
#'
#' @examples
#' Echogram.pixel(data, filename = "RPpixelfunction.png",plot.title = "Rock Pond", threshold = -45, use.bottom.line = TRUE)
Echogram = function(data
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
