#' SEIRS_model
#'
#' @param S Susceptible individuals at time, t = 0
#' @param E Exposed individuals at time, t = 0
#' @param I Infectious individuals at time, t = 0
#' @param R Recovered individuals at time, t = 0
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
SEIRS_model <- function(S, E, I, R, timesteps, years, alpha, beta,
                        inv_gamma, inv_omega, inv_mu, inv_sigma) {

  time_unit_years <- years / timesteps
  time_unit_days <- time_unit_years * 365.25

  # Convert parameters to days
  alpha <- alpha * time_unit_days
  beta <- beta * time_unit_days
  gamma <- time_unit_days / inv_gamma
  omega <- time_unit_days / (inv_omega * 365.25)
  mu <- time_unit_days / (inv_mu * 365.25)
  sigma <- 1 / inv_sigma

  N <- S + E + I + R
  birth <- mu * N

  results <- as.data.frame(matrix(NA, nrow = timesteps + 1, ncol = 5))
  colnames(results) <- c("time", "S", "E", "I", "R")
  results[1,] <- c(0, S, E, I, R)
  results <- results %>%
    dplyr::mutate(time = 0:timesteps) %>%
    dplyr::mutate(time = time * time_unit_days)

  for (t in seq_len(timesteps)) {

    infection <- (beta * results$I[t] * results$S[t]) / N
    lost_immunity <- omega * results$R[t]
    death_S <- mu * results$S[t]
    death_E <- mu * results$E[t]
    death_I <- (mu * alpha) * results$I[t]
    death_R <- mu * results$R[t]
    latency <- sigma * results$E[t]
    recovery <- gamma * results$I[t]

    S_rate <- birth - infection + lost_immunity - death_S
    E_rate <- infection - latency - death_E
    I_rate <- latency - recovery - death_I
    R_rate <- recovery - lost_immunity - death_R

    now <- t + 1
    results$S[now] <- results$S[t] + S_rate
    results$E[now] <- results$E[t] + E_rate
    results$I[now] <- results$I[t] + I_rate
    results$R[now] <- results$R[t] + R_rate

    # infectious_period <- 1 / (gamma + mu + alpha)
    # # probability of the index case becoming infectious rather than dying while in E
    # prob <- sigma / (sigma * mu)
    # R0 <- prob * (beta * infectious_period)
  }

  results
}
