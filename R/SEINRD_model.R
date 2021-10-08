#' SEINRD_model
#'
#' @param time time
#' @param state state
#' @param parms parms
#'
#' @export
#'
SEINRD_model <- function(time, state, parms) {

  # Take Rt data and fit a linear interpolation
  Rt_interp <- approxfun(x = rts_params$time, y = rts_params$Rt_value,
                         method = "constant", rule = 2)
  # Take efoi data and fit a linear interpolation
  efoi_interp <- approxfun(x = efoi_params$time, y = efoi_params$efoi,
                           method = "constant", rule = 2)

  with(as.list(c(state, parms)), {
    Rt <- Rt_interp(time) #gives value of Rt at given time
    efoi <- efoi_interp(time) #gives value of efoi at given time

    #system eqns
    dS <- -(r_t * Rt * I * S / Npop + efoi)
    dE <- -dS - (EI_trans_rate * E)
    dI <- (EI_trans_rate * E) - (IN_trans_rate * I)
    dN <- (IN_trans_rate * I) - (NR_trans_rate + ND_trans_rate) * N
    dR <- NR_trans_rate * N
    dD <- ND_trans_rate * N

    return(list(c(dS, dE, dI, dN, dR, dD)))
  })
}
