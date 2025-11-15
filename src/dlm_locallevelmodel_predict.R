# ---- local level model predict ----
# ローカルレベルモデルを使った予測と補間

# ---- library ----
library(rstan)
# library(brms) # (version 2.23.0)
library(here)
library(bayesplot)
library(ggfortify)
library(gridExtra)


rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# ---- Functions ----
source(
  here("R","plotSSM.R"),
  encoding = "utf-8"
)


# ---- import data ----
df_sale <- read.csv(
  here("data","raw","5-2-1-sales-ts-1.csv")
)

head(df_sale, n = 3)

summary(df_sale)


# ---- mcmc ----
## ---- prepare data list ----
d_list <- list(
  T = nrow(df_sale),  # 既知の区間長さ
  y = df_sale$sales,  # 既知の観測値
  pred_term = 20  # 既知の区間より先の未知の区間長さ
)

## ---- run ----
local_level_pred <- stan(
  file = here("src","dlm_locallevelmodel_predict.stan"),
  data = d_list,
  seed = 28,
  chains = 4,
  iter = 2000,
  warmup = 500
)

## ---- 収束の確認 ----
mcmc_rhat(
  rhat(local_level_pred)
)

# ---- visualization ----

## ---- 予測分も含めた日付長さを準備 ----
date_plot <- seq(
  from = as.POSIXct("2010-01-01"),
  by = "days",
  len = 120
)

## ---- mcmcの乱数結果を引数に渡す ----
mcmc_sample <- rstan::extract(local_level_pred)

## ---- plot ssm ----
plotSSM(
  mcmc_sample = mcmc_sample,
  time_vec = date_plot,
  state_name = "mu_pred",
  graph_title = "Result of Prediction",
  y_label = "sales"
)
# この予測では、最後の値からランダムウォークに基づいて
# 将来が推定されている
# ランダムウォークは期待値0、分散σの正規分布に従うので
# 最後の期待値から期待値は変化していない
# その代わり推定先が遠くなるにつれて、ランダムウォークの
# 推定範囲が広がっているのが図示できている




# ---- 欠損があるデータ ----
df_sale_na <- read.csv(
  here("data","raw","5-3-1-sales-ts-1-NA.csv")
)

## ---- 欠損データの処理方法 ----
# 欠損数
df_sale_dropna <- na.omit(df_sale_na)
nrow(df_sale_na)
nrow(df_sale_dropna)

# 欠損位置
# 長さが100だからこの確認でもよいが...
which(!is.na(df_sale_na$sales))


# ---- mcmc 欠損含む ----
## prepare data list ----
d_list_na <- list(
  T = nrow(df_sale_na),
  len_obs = nrow(df_sale_dropna),
  y = df_sale_dropna$sales,
  obs_no = which(!is.na(df_sale_na$sales))
)

## ---- run mcmc ----
local_level_pred_na <- stan(
  file = here("src","dlm_locallevelmodel_interpolation.stan"),
  data = d_list_na,
  seed = 28,
  chains = 4,
  iter = 2000,
  warmup = 500
)

## ---- 収束の確認 ----
mcmc_rhat(
  rhat(local_level_pred_na)
)

# ---- visualization na ----
## ---- mcmcの乱数結果を引数に渡す ----
mcmc_sample_na <- rstan::extract(local_level_pred_na)

## ---- plotSSM ----
plotSSM(
  mcmc_sample = mcmc_sample_na,
  time_vec = df_sale$date,
  obs_vec = df_sale$sales,
  state_name = "mu",
  graph_title = "Result of interpolation",
  y_label = "sales"
)
# データがないところは、無いなりの推論値になっている
# データがないのでlocal level modelだとそのまま期待値を
# 結んだ線の様になっている