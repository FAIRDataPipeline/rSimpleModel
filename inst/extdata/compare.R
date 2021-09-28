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
julia <- read.csv(link_read(handle, "SEIRS_model/results/model_output/julia"))

# Largest difference between implementations across timesteps
results <- max(R - julia)

# Plot results
g <- plot_compare(R, julia)

# Save outputs to data store
results %>% write_estimate(handle = handle,
                           data_product = "output",
                           component = "difference",
                           description = "Maximum difference between values")

path <- link_write(handle, "figure")
ggsave(path, g)

# Register code run in local registry
finalise(handle)
