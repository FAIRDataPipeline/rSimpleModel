library(rSimpleModel)
library(rDataPipeline)
library(ggplot2)
library(dplyr)
library(magrittr)

# Initialise code run
conf.dir <- Sys.getenv("FDP_CONFIG_DIR")
config <- file.path(conf.dir, "config.yaml")
script <- file.path(conf.dir, "script.sh")
handle <- initialise(config, script)

# Read model results
R <- read.csv(link_read(handle, "SEIRS_model/results/model_output/R"))
python <- read.csv(link_read(handle, "SEIRS_model/results/model_output/python"))
julia <- read.csv(link_read(handle, "SEIRS_model/results/model_output/julia"))
java <- read.csv(link_read(handle, "SEIRS_model/results/model_output/java"))

results <- list(R = R, python = python, julia = julia, java = java)

result_names <- names(results)
bad_names <- c()
good_names <- c()

# Check start and end times and lengths
starts <- c()
ends <- c()
lengths <- c()
for (name in result_names) {
  times <- results[[name]]$time
  starts[name] <- times[1]
  ends[name] <- times[length(times)]
  lengths[name] <- nrow(results[[name]])
}

if (min(starts) != max(starts)) {
  warning("Start times of outputs don't match")
  start.table <- table(starts)
  if (start.table[1] != 3) {
    stop("No way of telling which start time is right")
  } else {
    target <- as.numeric(names(start.table)[2])
    bad_name <- result_names[which(starts == target)]
    raise_issue(handle = handle,
                data_product = paste0("SEIRS_model/results/model_output/",
                                      bad_name),
                issue = "Model has wrong start time",
                severity = 2)
    bad_names <- unique(c(bad_names, bad_name))
  }
}

if (min(ends) != max(ends)) {
  warning("End times of outputs don't match")
  end.table <- table(ends)
  if (end.table[1] != 3) {
    stop("No way of telling which end time is right")
  } else {
    target <- as.numeric(names(end.table)[2])
    bad_name <- result_names[which(ends == target)]
    raise_issue(handle = handle,
                data_product = paste0("SEIRS_model/results/model_output/",
                                      bad_name),
                issue = "Model has wrong end time",
                severity = 2)
    bad_names <- unique(c(bad_names, bad_name))
  }
}

if (min(lengths) != max(lengths)) {
  warning("Lengths of outputs don't match")
  length.table <- table(lengths)
  if (length.table[1] != 3) {
    stop("No way of telling which length is right")
  } else {
    target <- as.numeric(names(length.table)[2])
    bad_name <- result_names[which(lengths == target)]
    raise_issue(handle = handle,
                data_product = paste0("SEIRS_model/results/model_output/",
                                      bad_name),
                issue = paste0("Model has wrong length (", target,
                               " instead of ", names(length.table)[1], ")"),
                severity = 3)
    bad_names <- unique(c(bad_names, bad_name))
  }
}

good_names <- setdiff(result_names, bad_names)

problems <- c()
max.diff <- 0
too.big <- 1e-4

# Largest difference between implementations across timesteps
for (name.1 in good_names)
  problems[name.1] <- 0

for (name.1 in good_names) {
  for (name.2 in good_names) {
    d12 <- max(abs(results[[name.1]] - results[[name.2]]))
    if (d12 > max.diff)
      max.diff <- d12
    if (d12 > too.big) {
      problems[name.1] <- problems[name.1] + 1
      problems[name.2] <- problems[name.2] + 1
    }
  }
}

if (max.diff > too.big) {
  name <- names(which.max(problems))
  raise_issue(handle = handle,
              data_product = paste0("SEIRS_model/results/model_output/",
                                    name),
              issue = paste0("Model produces different result to others"),
              severity = 5)
}
one <- max(R - python)
two <- max(R - julia)
results <- max(one, two)

# Plot results
g <- plot_compare(R, python, julia, java)

# Save outputs to data store
max.diff %>% write_estimate(handle = handle,
                            data_product = "output",
                            component = "difference",
                            description = "Maximum difference between values")

path <- link_write(handle, "figure")
ggsave(path, g, width = 20, height = 10, units = "cm")

# Register code run in local registry
finalise(handle)
