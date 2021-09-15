library(rSimpleModel)
library(rDataPipeline)
library(ggplot2)
library(dplyr)

# Initialise code run
config <- file.path(Sys.getenv("FDP_CONFIG_DIR"), "config.yaml")
script <- file.path(Sys.getenv("FDP_CONFIG_DIR"), "script.sh")
handle <- initialise(config, script)

# Read code run inputs
static_params <- read.csv(link_read(handle, "disease/sars_cov2/SEIRS_model/parameters/static_params"))

# Run the model
results <- SEIRS_model(S = 0.999,
                       E = 0.001,
                       I = 0,
                       R = 0,
                       timesteps = 1000,
                       years = 5,
                       alpha = filter(static_params, param == "alpha")$value,
                       beta = filter(static_params, param == "beta")$value,
                       inv_gamma = filter(static_params, param == "inv_gamma")$value,
                       inv_omega = filter(static_params, param == "inv_omega")$value,
                       inv_mu = filter(static_params, param == "inv_mu")$value,
                       inv_sigma = filter(static_params, param == "inv_sigma")$value)
g <- plot_SEIRS(results)

# Save outputs to data store
path <- link_write(handle, "disease/sars_cov2/SEIRS_model/results/model_output")
write.csv(results, path)

path <- link_write(handle, "disease/sars_cov2/SEIRS_model/results/figure")
ggsave(path, g)

# Register code run in local registry
finalise(handle)
