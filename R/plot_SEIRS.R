#' plot_SEIRS
#'
#' @param results results
#'
#' @export
#'
plot_SEIRS <- function(results) {

  # Convert time to years and other columns to percentage
  tmp <- results %>%
    dplyr::mutate(time = time / 365.25,
                  S = S * 100,
                  E = E * 100,
                  I = I * 100,
                  R = R * 100)

  # Create labels
  time1 <- tmp$time[round(nrow(tmp) * 0.27)]
  time2 <- tmp$time[round(nrow(tmp) * 0.90)]
  labs <- tmp %>% dplyr::filter(time %in% c(time1, time2)) %>%
    tidyr::pivot_longer(cols = c(S, E, I, R))
  labs <- labs %>% dplyr::mutate(labs = dplyr::case_when(
    name == "R" & time == time1 ~ "R",
    name == "R" & time == time2 ~ paste0(round(value), "%"),
    name == "S" & time == time1 ~ "S",
    name == "S" & time == time2 ~ paste0(round(value), "%"))) %>%
    dplyr::filter(!is.na(labs)) %>%
    dplyr::mutate(value = case_when(name == "S" & time == time1 ~ value - 5,
                                    TRUE ~ value + 5))

  plot_this <- tmp %>%
    tidyr::pivot_longer(cols = c(S, E, I, R)) %>%
    dplyr::mutate(value = value,
                  name = factor(name, levels = c("S", "E", "I", "R")))

  cols <- c("black", "#aceb4e", "red", "#28cce8")

  ggplot2::ggplot(plot_this) + ggplot2::theme_bw() +
    ggplot2::geom_line(ggplot2::aes(x = time, y = value,
                                    group = name, colour = name)) +
    ggplot2::geom_text(aes(x = time, y = value, label = labs), labs) +
    ggplot2::scale_colour_manual(values = cols) +
    ggplot2::labs(x = "Years", y = "Relative group size (%)") +
    ggplot2::theme(legend.position = "none")
}
