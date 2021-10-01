#' plot_SEINRD
#'
#' @param results results
#'
#' @export
#'
plot_SEINRD <- function(results) {
  cols <- c("black", "#aceb4e", "red", "#28cce8", "purple", "yellow")

  left <- results %>%
    as.data.frame() %>%
    tidyr::pivot_longer(cols = c(S, E, I, N, R, D)) %>%
    dplyr::mutate(name = factor(name,
                                levels = c("S", "E", "I", "N", "R", "D")),
                  plot = "left")

  right <- left %>%
    dplyr::filter(name %in% c("E", "I", "N", "D")) %>%
    dplyr::mutate(plot = "right")

  rbind.data.frame(left, right) %>%
    ggplot2::ggplot() + ggplot2::theme_bw() +
    ggplot2::geom_line(ggplot2::aes(x = time, y = value,
                                    group = name, color = name)) +
    ggplot2::facet_wrap(~plot, scales = "free") +
    ggplot2::scale_colour_manual(values = cols) +
    ggplot2::labs(title = "SEINRD model trajectories",
                  x = "Time", y = "Number") +
    ggplot2::scale_y_continuous(labels = function(x)
      format(x, scientific = TRUE)) +
    ggplot2::theme(strip.background = ggplot2::element_blank(),
                   strip.text.x = ggplot2::element_blank(),
                   plot.title = ggplot2::element_text(hjust = 0.5))
}
