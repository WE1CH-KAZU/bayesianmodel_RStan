# ----- 周期性モデル ----
# ---- library ----
library(rstan)
library(brms) # (version 2.23.0)
library(here)
library(bayesplot)
library(ggfortify)
library(gridExtra)


rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# ---- module install ----
source(
  here("R","plotSSM.R")
)

# ---- import data ----
df_sale <- read.csv(
  here("data","raw","5-6-1-sales-ts-4.csv")
)
df_sale$date <- as.POSIXct(df_sale$date)

head(df_sale, n = 3)

tail(df_sale, n = 3)

summary(df_sale)

# 徐々に増加が緩やかになり、周期性幅も大きくなっている
autoplot(
  ts(df_sale$sales)
)

# ---- ACF 自己相関 ----
acf(
  ts(df_sale$sales),
  lag.max = 60,
  plot = TRUE
)


# ---- PACF 偏自己相関 ----
pacf(
  ts(df_sale$sales),
  lag.max = 60,
  plot = TRUE
)

# ---- mcmc ----
d_list <- list(
  T = nrow(df_sale),
  y = df_sale$sales
)

basic_structual <- stan(
  file = here("src","dlm_bsts.stan"),
  data = d_list,
  seed = 28,
  chains = 4,
  iter = 6000,
  warmup = 1000,
  control = list(
    adapt_delta = 0.97,
    max_treedepth = 12
  )
)

print(
  basic_structual,
  pars = c("mu[25]","gamma[25]"),
  probs = c(0.025, 0.5, 0.975)
)

mcmc_combo(
  basic_structual,
  pars = c("mu[25]","gamma[25]")
)

# ---- visualization ----
mcmc_sample <- rstan::extract(basic_structual)

p_all <- plotSSM(
  mcmc_sample = mcmc_sample,
  time_vec = df_sale$date,
  obs_vec = df_sale$sales,
  state_name = "alpha",  # 観測方程式の期待値
  graph_title = "すべての成分を含んだ推定値（観測方程式の期待値α）",
  y_label = "sales"
)

p_mu <- plotSSM(
  mcmc_sample = mcmc_sample,
  time_vec = df_sale$date,
  obs_vec = df_sale$sales,
  state_name = "mu",  # 平滑化モデルの期待値
  graph_title = "周期成分を除いた推定値（平滑化モデルの期待値mu）",
  y_label = "sales"
)

p_gamma <- plotSSM(
  mcmc_sample = mcmc_sample,
  time_vec = df_sale$date,
  # obs_vec = df_sale$sales,
  state_name = "gamma",  # 周期成分の推定値
  graph_title = "周期成分(lag=7)",
  y_label = "sales"
)

grid.arrange(p_all,p_mu,p_gamma)
