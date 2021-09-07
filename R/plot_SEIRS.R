#' plot_SEIRS
#'
#' @param results results
#'
#' @export
#'
plot_SEIRS <- function(results) {
  ggplot2::ggplot(results) +
    ggplot2::geom_line(ggplot2::aes(x = time, y = S, color = "darkgreen")) +
    ggplot2::geom_line(ggplot2::aes(x = time, y = E, color = "yellow")) +
    ggplot2::geom_line(ggplot2::aes(x = time, y = I, color = "red")) +
    ggplot2::geom_line(ggplot2::aes(x = time, y = R, color = "blue")) +
    ggplot2::geom_vline(xintercept = 82, linetype = "dashed") +
    ggplot2::geom_vline(xintercept = 340, linetype = "dashed") +
    ggplot2::scale_color_identity(breaks = c("darkgreen", "yellow","red","blue","black"),
                                  labels = c("S","E","I","R","D"), guide = "legend") +
    ggplot2::labs(color = ggplot2::element_blank()) +
    ggplot2::xlab("Time") +
    ggplot2::ylab("Number") +
    ggplot2::theme(axis.title = ggplot2::element_text(size = 15),
                   axis.text = ggplot2::element_text(size = 13),
                   legend.text = ggplot2::element_text(size = 15))
}
