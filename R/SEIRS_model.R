#' SEIRS_model
#'
#' @param initial.state Number of individuals in different disease states
#' (S, E, I and R) at time, t = 0
#' @param timesteps timesteps
#' @param years years
#' @param alpha Death rate
#' @param beta Contact rate (per day)
#' @param inv_gamma Infectious period (days)
#' @param inv_omega Average protected period (years)
#' @param inv_mu inverse mu (years)
#' @param inv_sigma Latency period (days)
#'
#' @export
#'
SEIRS_model <- function(initial.state, timesteps, years, alpha, beta,
                        inv_gamma, inv_omega, inv_mu, inv_sigma) {

  S <- initial.state$S
  E <- initial.state$E
  I <- initial.state$I
  R <- initial.state$R
  time_unit_years <- years / timesteps
  time_unit_days <- time_unit_years * 365.25

  # Convert parameters to timesteps
  a <- alpha * time_unit_days
  b <- beta * time_unit_days
  g <- time_unit_days / inv_gamma
  o <- time_unit_days / (inv_omega * 365.25)
  m <- time_unit_days / (inv_mu * 365.25)
  s <- time_unit_days / inv_sigma

  results <- as.data.frame(matrix(NA, nrow = timesteps + 1, ncol = 5))
  colnames(results) <- c("time", "S", "E", "I", "R")
  results[1, ] <- c(0, S, E, I, R)
  results <- results %>%
    dplyr::mutate(time = 0:timesteps) %>%
    dplyr::mutate(time = time * time_unit_days)

  for (t in seq_len(timesteps)) {
    N <- results$S[t] + results$E[t] + results$I[t] + results$R[t]
    birth <- m * N

    infection <- (b * results$I[t] * results$S[t]) / N
    lost_immunity <- o * results$R[t]
    death_S <- m * results$S[t]
    death_E <- m * results$E[t]
    death_I <- (m + a) * results$I[t]
    death_R <- m * results$R[t]
    latency <- s * results$E[t]
    recovery <- g * results$I[t]

    S_rate <- birth - infection + lost_immunity - death_S
    E_rate <- infection - latency - death_E
    I_rate <- latency - recovery - death_I
    R_rate <- recovery - lost_immunity - death_R

    now <- t + 1
    results$S[now] <- results$S[t] + S_rate
    results$E[now] <- results$E[t] + E_rate
    results$I[now] <- results$I[t] + I_rate
    results$R[now] <- results$R[t] + R_rate
  }

  results %>% dplyr::mutate(time = time / 365.25)
}
