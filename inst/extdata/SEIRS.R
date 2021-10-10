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

# Read model parameters
params <- handle %>% link_read("SEIRS_model/parameters") %>% read.csv
a <- params %>% filter(param == "alpha") %$% value
b <- params %>% filter(param == "beta") %$% value
ig <- params %>% filter(param == "inv_gamma") %$% value
io <- params %>% filter(param == "inv_omega") %$% value
im <- params %>% filter(param == "inv_mu") %$% value
is <- params %>% filter(param == "inv_sigma") %$% value

# Set initial state
initial.state <- data.frame(S = 0.999, E = 0.001, I = 0, R = 0)

# Run the model
results <- SEIRS_model(initial.state, timesteps = 1000, years = 5,
                       alpha = a, beta = b, inv_gamma = ig,
                       inv_omega = io, inv_mu = im, inv_sigma = is)
g <- plot_SEIRS(results)

# Save outputs to data store
results %>% write.csv(link_write(handle, "model_output"), row.names = FALSE)

handle %>% link_write("figure") %>% ggsave(g, width=20, height=10, units="cm")

# Register code run in local registry
finalise(handle)
