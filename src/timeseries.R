# ---- 時系列モデル ----

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

df_sale <- read.csv(
  here("data","raw","5-7-1-sales-ts-5.csv")
)

head(df_sale, n = 3)
tail(df_sale, n = 3)

summary(df_sale)

autoplot(
  ts(df_sale$sales)
)


# ---- mcmc ----
# これが自己回帰モデル（AR）だとすると
# 期待値と分散はいくつになりますか？
# というのをmcmcで推定する

d_list <- list(
  T = nrow(df_sale),
  y = df_sale$sales
)

ar_stan <- stan(
  file = here("src", "timeseries_ar.stan"),
  data = d_list,
  seed = 28,
  chains = 4,
  iter = 6000,
  warmup = 1000,
)

print(
  ar_stan
)
# 自己回帰係数が絶対値1を下回るので弱定常といえる
# だからこれはAR(1)といえる
