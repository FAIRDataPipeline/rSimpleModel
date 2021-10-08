#' plot_SEIRS
#'
#' @param results SEIRS_model output
#'
#' @export
#'
plot_SEIRS <- function(results) {

  # Convert time to years and other columns to percentage
  tmp <- results %>%
    dplyr::mutate(S = S * 100,
                  E = E * 100,
                  I = I * 100,
                  R = R * 100)

  # Prepare to plot
  plot_this <- tmp %>%
    tidyr::pivot_longer(cols = c(S, E, I, R)) %>%
    dplyr::mutate(value = value,
                  name = factor(name, levels = c("S", "E", "I", "R")),
                  plot = "left")

  cols <- c("black", "#aceb4e", "red", "#28cce8")
  title <- expression(atop("SEIRS model trajectories",
                           paste(R[0] == 3, ", ",
                                 1 / gamma == 14, " days, ",
                                 1 / sigma == 7, " days, ",
                                 1 / omega == 1, " year")))

  # Generate plot
  ggplot2::ggplot(plot_this) + ggplot2::theme_bw() +
    facet_wrap(~plot, scales = "free") +
    ggplot2::geom_line(ggplot2::aes(x = time, y = value,
                                    group = name, colour = name)) +
    ggplot2::scale_colour_manual(values = cols) +
    ggplot2::labs(title = title, x = "Years", y = "Relative group size (%)") +
    ggplot2::theme(strip.background = element_blank(),
                   strip.text.x = element_blank(),
                   panel.grid.major = element_blank(),
                   panel.grid.minor = element_blank(),
                   plot.title = element_text(hjust = 0.5))
  }
