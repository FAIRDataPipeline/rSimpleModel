#' initialise_model
#'
#' @param rts_params rts_params
#' @param efoi_params efoi_params
#' @param static_params static_params
#'
#' @export
#'
initialise_model <- function(rts_params, efoi_params, static_params) {
  # Take the Rt data and fit a linear interpolation
  Rt_interp <- approxfun(x = rts_params$time, y = rts_params$Rt_value,
                         method = "constant", rule = 2)
  # Take the efoi data and fit a linear interpolation
  efoi_interp <- approxfun(x = efoi_params$time, y = efoi_params$efoi,
                           method = "constant", rule = 2)

  # Set the initial time, max time, and time step for the solver
  time_length <- seq(0, 530, by = 0.1)

  # Define the parameters from static_params
  pars <- static_params$value
  names(pars) <- static_params$param

  # Define the initial state of the system
  S <- static_params %>% dplyr::filter(param == "Npop")
  init_state <- c(S = S$value - 1,
                  E = 1, I = 0, N = 0, R = 0, D = 0)

  list(init_state = init_state,
       time_length = time_length,
       pars = pars)
}
