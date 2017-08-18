#' @title ConvertPower
#'
#' @description Convert raw power to Sv
#'
#' @param data from ReadEKRaw function (must run \code{\link{ReadEKRaw}} first). A list of three objects called data,
#' (1) File header, (2) pings, (3) GPS data. These three objects are themselves lists.
#'
#' @param tvgCFac Time Varied Gain correction factor; default = 2; specify based upon application for the ES/K 60 the recommended values to apply are as follows:
#' for Sv data for echo integration = 2
#' TS data for use with method 1 single target detection operators (see Notes at URL) = 2
#' TS data for use with method 2 single target detection operators (see Notes at URL) = 0
#' http://support.echoview.com/WebHelp/Reference/Algorithms/Echosounder/Simrad/Simrad_Time_Varied_Gain_Range_Correction.htm
#'
#' @return adds a vector named Sv to each object in \code{data$pings} in (db re. 1 m^-1). This can then be used for further analysis such as with \code{\link{Echogram}}
#' @export
ConvertPower = function(data, tvgCFac = 2) {
        # adds in gain and equivalentebeam angle to every ping, matched by frequency.
    for (i in 1:length(data$pings)) {
        x = data$pings[[i]]
        for( b in 1:length(data$header$transceiver)){
            y = data$header$transceiver[[b]]
            if (y$frequency == x$frequency){
                x$gain = y$gain
                x$equivalentbeamangle = y$equivalentbeamangle
            }
        }
        data$pings[[i]] = x
    }

    # define needed parameters for each data ping and calculate Sv
    for (i in 1:(length(data$pings))){
        f = data$pings[[i]]$frequency
        G =  data$pings[[i]]$gain
        phi = data$pings[[i]]$equivalentbeamangle
        cv = data$pings[[i]]$soundvelocity # this was called c in the original Matlab code
        t = data$pings[[i]]$sampleinterval
        alpha = data$pings[[i]]$absorptioncoefficient
        pt = data$pings[[i]]$transmitpower
        tau = data$pings[[i]]$pulselength
        dR = cv * t / 2 # calculate sample thickness (in range)
        lambda =  cv / f # calculate wavelength
        # calculate Sa correction
        idx = match(tau, data$pings[[i]]$pulselengthtable)
        Sac = c()
        if (!is.na(idx) == TRUE ) {
            Sac = 2*(data$pings[[i]]$sacorrectiontable[idx])
        } else {
            Sac = 0
            warning("Sa correction table empty - Sa correction not applied....\n")
        }
        tvgCFac = tvgCFac # user specified, see notes above for guidance, default = 2.
        rangeCorrected = 1:length(data$pings[[i]]$power) * dR
        data$pings[[i]]$rangeCorrected =  rangeCorrected
        TVG = (20 * log10(rangeCorrected)) # changed from 40 to 20 on March 17, 2016 based on:http://support.echoview.com/WebHelp/Echoview.htm using "Ex60 Power to Sv and TS"
        CSv = 10 * log10((pt * (10^(G/10))^2 * lambda^2 * cv * tau * 10^(phi/10)) /  (32 * pi^2))
        data$pings[[i]]$Sv = data$pings[[i]]$power + TVG + (2 * alpha * rangeCorrected) - CSv - (2*Sac)
    }

    return(data)
} # end function


