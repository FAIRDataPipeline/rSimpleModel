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
python <- read.csv("/Users/Soniam/.fair/data/ryan/SEIRS_model/results/model_output/python/56d139c3b3d70eb7e25b0d424087e965cc3cdd2a.csv")
# python <- read.csv(link_read(handle, "SEIRS_model/results/model_output/python"))
colnames(python)[1] <- "time"
python$time <- python$time / 365.25
julia <- read.csv(link_read(handle, "SEIRS_model/results/model_output/julia"))
java <- read.csv(link_read(handle, "SEIRS_model/results/model_output/java"))
colnames(java) <- colnames(R)

raise_issue(handle = handle,
            data_product = "SEIRS_model/results/model_output/java",
            version = "0.0.1",
            namespace = "bram",
            issue = "Model has been run over 3649 timesteps rather than 1000",
            severity = 3)
raise_issue(handle = handle,
            data_product = "SEIRS_model/results/model_output/java",
            version = "0.0.1",
            namespace = "bram",
            issue = "Model has assumed there to be 365 days in a year rather than 365.25",
            severity = 5)

# Largest difference between implementations across timesteps
results <- max(R - python)
two <- max(R - julia)
three <- max(R - java)

# Plot results
g <- plot_compare(R, python, julia, java)

# Save outputs to data store
results %>% write_estimate(handle = handle,
                           data_product = "output",
                           component = "difference",
                           description = "Maximum difference between values")

path <- link_write(handle, "figure")
ggsave(path, g)

# Register code run in local registry
finalise(handle)
