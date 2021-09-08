#' plot_SEIRS
#'
#' @param results SEIRS_model output
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

  left_labs <- tmp %>% dplyr::filter(time %in% c(time1, time2)) %>%
    tidyr::pivot_longer(cols = c(S, E, I, R)) %>%
    dplyr::mutate(labs = dplyr::case_when(
      name == "R" & time == time1 ~ "R",
      name == "R" & time == time2 ~ paste0(round(value), "%"),
      name == "S" & time == time1 ~ "S",
      name == "S" & time == time2 ~ paste0(round(value), "%"))) %>%
    dplyr::filter(!is.na(labs)) %>%
    dplyr::mutate(value = case_when(name == "S" & time == time1 ~ value - 5,
                                    TRUE ~ value + 5),
                  plot = "left")

  time1 <- tmp$time[round(nrow(tmp) * 0.34)]
  time2 <- tmp$time[round(nrow(tmp) * 0.90)]

  right_labs <- tmp %>% dplyr::filter(time %in% c(time1, time2)) %>%
    tidyr::pivot_longer(cols = c(S, E, I, R)) %>%
    dplyr::filter(name %in% c("E", "I")) %>%
    dplyr::mutate(labs = dplyr::case_when(
      name == "I" & time == time1 ~ "I",
      name == "I" & time == time2 ~ paste0(round(value, 1), "%"),
      name == "E" & time == time1 ~ "E",
      name == "E" & time == time2 ~ paste0(round(value, 1), "%"))) %>%
    dplyr::filter(!is.na(labs)) %>%
    dplyr::mutate(value = case_when(name == "E" ~ value - 1,
                                    TRUE ~ value + 1),
                  plot = "right")

  labs <- rbind.data.frame(left_labs, right_labs)

  # Prepare to plot
  left_plot <- tmp %>%
    tidyr::pivot_longer(cols = c(S, E, I, R)) %>%
    dplyr::mutate(value = value,
                  name = factor(name, levels = c("S", "E", "I", "R")),
                  plot = "left")

  right_plot <- left_plot %>%
    dplyr::filter(name %in% c("E", "I")) %>%
    dplyr::mutate(plot = "right")

  plot_this <- left_plot %>%
    rbind.data.frame(right_plot)

  cols <- c("black", "#aceb4e", "red", "#28cce8")
  title <- expression(atop("SEIRS model trajectories",
                           paste(R[0]==3, ", ",
                                 1/gamma==14, " days, ",
                                 1/sigma==7, " days, ",
                                 1/omega==1, " year")))

  # Generate plot
  ggplot2::ggplot(plot_this) + ggplot2::theme_bw() +
    facet_wrap(~plot, scales = "free") +
    ggplot2::geom_line(ggplot2::aes(x = time, y = value,
                                    group = name, colour = name)) +
    ggplot2::geom_text(aes(x = time, y = value, label = labs), labs) +
    ggplot2::scale_colour_manual(values = cols) +
    ggplot2::labs(title = title, x = "Years", y = "Relative group size (%)") +
    ggplot2::theme(legend.position = "none",
                   strip.background = element_blank(),
                   strip.text.x = element_blank(),
                   panel.grid.major = element_blank(),
                   panel.grid.minor = element_blank(),
                   plot.title = element_text(hjust = 0.5))
  }
