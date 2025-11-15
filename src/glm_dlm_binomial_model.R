# ---- 動的一般化線形モデル：二項分布モデル ----

# ---- library ----
library(rstan)
library(brms) # (version 2.23.0)
library(here)
library(bayesplot)
library(ggfortify)
library(gridExtra)
library(KFAS)  # 論文データ. 二項分布のGDLMの分析例として使う

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# ---- module install ----
source(
  here("R","plotSSM.R")
)

# ---- import data ----
data("boat")

head(boat, n = 3)
tail(boat, n = 3)

summary(boat)

print(boat)

boat_omit_na <- na.omit(as.numeric(boat))

# 欠損値が入っているので、欠損値を推定した状態でtimeseriesをmcmcで推定する
d_list <- list(
  T = length(boat),
  len_obs = length(boat_omit_na),
  y = boat_omit_na,
  obs_no = which(!is.na(boat))
)

# ---- mcmc ----
gdlm_binom <- stan(
  file = here("src","dglm-binom.stan"),
  data = d_list,
  seed = 28,
  chains = 4,
  iter = 8000,
  warmup = 1000,
  control = list(
    adapt_delta = 0.98,
    max_treedepth = 12
  )
)

mcmc_sample <- rstan::extract(gdlm_binom)

years <- seq(
  from = as.POSIXct("1829-01-01"),
  by = "1 year",
  len = length(boat)
)

head(years, n = 3)

plotSSM(
  mcmc_sample = mcmc_sample,
  time_vec = years,
  obs_vec = as.numeric(boat),
  state_name = "probs",
  graph_title = "win rate of kenbridge Univ.",
  y_label = "win ratio",
  date_labels = "%Y年"
)
