# ---- Prediction GLM using design matrix ----
# デザイン行列のなにが便利なのか
# 説明変数が増減しても行列でstanを記述しているので
# 個別の変数の命名が必要ない
# よってstanファイルの書き換えが必要ない
# モデルが変わる場合はもちろん編集の必要あり


# ---- library ----
library(rstan)
library(bayesplot)
library(here)
library(ggplot2)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# ---- import data ----
beer_sales <- read.csv(
  here("data", "raw", "3-2-1-beer-sales-2.csv")
)

n_size <- nrow(beer_sales)


# ---- design matrix ----
# 記述のお作法

# formula の作成
formula_lm <- formula(
  sales ~ temperature
)

# デザイン行列の作成
X <- model.matrix(
  formula_lm,
  beer_sales
)


# ---- mcmc ----
# 引数に必要なものを渡す
N <- nrow(X)
K <- ncol(X)
Y <- beer_sales$sales
d_list <- list(
  N = N,
  K = K,
  Y = Y,
  X = X
)

# execute mcmc
filepath <- here("src", "prediction_glm_using_designmatrix.stan")
mcmc_result <- stan(
  file = filepath,
  data = d_list,
  seed = 28
)

print(
  mcmc_result
)
