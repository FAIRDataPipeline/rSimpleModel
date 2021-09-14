library(rSimpleModel)
library(rDataPipeline)
library(ggplot2)
library(dplyr)

# Initialise code run
config <- file.path(Sys.getenv("FDP_CONFIG_DIR"), "config.yaml")
script <- file.path(Sys.getenv("FDP_CONFIG_DIR"), "script.sh")
handle <- initialise(config, script)


dat <- c(alpha = 0, beta = 0.21, inv_gamma = 14,  inv_omega = 1,
         inv_mu = 76, inv_sigma = 7, R0 = 3)
dat <- data.frame(param = names(dat), value = dat)
row.names(dat) <- NULL
write.csv(dat, "static_params_SEIRS.csv", row.names = F)
# Read code run inputs
static_params <- read.csv(link_read(handle, "disease/sars_cov2/SEIRS_model/parameters/static_params"))
static_params
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
