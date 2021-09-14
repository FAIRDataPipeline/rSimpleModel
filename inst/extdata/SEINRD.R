library(rSimpleModel)
library(rDataPipeline)
library(dplyr)
library(RCurl)
library(deSolve)
library(ggplot2)

data_static <- "disease/sars_cov2/SEINRD_model/parameters/static_params"
data_rts <- "disease/sars_cov2/SEINRD_model/parameters/rts"
data_efoi <- "disease/sars_cov2/SEINRD_model/parameters/efoi"
results_dp <- "disease/sars_cov2/SEINRD_model/results/model_output"
figure_dp <- "disease/sars_cov2/SEINRD_model/results/figure"

# Initialise code run
config <- file.path(Sys.getenv("FDP_CONFIG_DIR"), "config.yaml")
script <- file.path(Sys.getenv("FDP_CONFIG_DIR"), "script.sh")
handle <- initialise(config, script)

# Read code run inputs
static_params <- read.csv(link_read(handle, "disease/sars_cov2/SEINRD_model/parameters/static_params"))
rts_params <- read.csv(link_read(handle, "disease/sars_cov2/SEINRD_model/parameters/rts"))
efoi_params <- read.csv(link_read(handle, "disease/sars_cov2/SEINRD_model/parameters/efoi"))

# Run the model
data <- initialise_SEINRD(rts_params, efoi_params, static_params)
results <- ode(y = data$init_state,
               times = data$time_length,
               func = rSimpleModel::SEINRD_model,
               parms = data$pars)
g <- plot_SEINRD(results)

# Save outputs to data store
path <- link_write(handle, "disease/sars_cov2/SEINRD_model/results/model_output")
write.csv(results, path)

path <- link_write(handle, "disease/sars_cov2/SEINRD_model/results/figure")
ggsave(path, g)

# Register code run in local registry
finalise(handle)
