# ---- Single Linear regression Model ----

# ---- library ----
library(rstan)
library(bayesplot)
library(here)
library(ggplot2)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# ---- import data ----
beer_sales_ab <- read.csv(
  here("data", "raw", "3-2-1-beer-sales-2.csv")
)

## sample size
sample_size <- nrow(beer_sales_ab)

## image
ggplot(
  data = beer_sales_ab,
  aes(
    x = temperature,
    y = sales
  )
) +
  geom_point() +
  labs(
    title = "beer sales by a temperature"
  )

# ---- model ----
# モデル構造は単回帰モデルとする
# つまり売上の平均は正規分布で表現でき、
# そのリンク関数は恒等関数であるとします

## ---- to list ----
d_list <- list(
  sales = beer_sales_ab$sales,
  temperature = beer_sales_ab$temperature,
  N = sample_size
)

## ---- mcmc ----
filepath <- here("src", "single_linear_reg_model.stan")
mcmc_result <- stan(
  file = filepath,
  data = d_list,
  seed = 28
)

## ---- extraction ----
mcmc_sample <- rstan::extract(
  mcmc_result,
  permuted = FALSE
)

## ---- trace plot ----
mcmc_combo(
  mcmc_sample,
  pars = c("intercept", "beta", "sigma")
)

print(
  mcmc_result,
)


# ---- MCMC結果から条件に応じて推定する ----
# 気温の条件を振ったときの売上を予測する
temperature_pred <- 11:30

## ---- to list ----
d_list_pred <- list(
  sales = beer_sales_ab$sales,
  temperature = beer_sales_ab$temperature,
  N = sample_size,
  temperature_pred = temperature_pred, # 推定したい値
  N_pred = length(temperature_pred) # 推定したい値の数
)

## ---- mcmc ----
filepath_pred <- here(
  "src", "single_linear_reg_pred_model.stan"
)
mcmc_sample_pred <- stan(
  file = filepath_pred,
  data = d_list_pred,
  seed = 28
)

print(
  mcmc_sample_pred,
  probs = c(0.03, 0.50, 0.97)
)
# 単純にサンプルから4000回シミュレーションして得た期待値
# の95%よりも
# generated quantitiesで4000回計算した時の分布の方が
# より正確に実体を表している
# mu_predは売上の平均の94％信用区間
# sales_pred は正規分布に従う売上の94%信用区間


## ---- extraction ----
mcmc_result_pred <- rstan::extract(
  mcmc_sample_pred,
  permuted = FALSE
)

## ---- intervals ----
# sales_pred の区間範囲を可視化
mcmc_intervals(
  mcmc_result_pred,
  regex_pars = c("sales_pred."),
  prob =  0.80, # 太線範囲
  prob_outer = 0.94 # 細線範囲
)

# m_pred, sales_pred の区間範囲の比較
mcmc_intervals(
  mcmc_result_pred,
  pars = c("mu_pred[1]", "sales_pred[1]"),
  prob = 0.80,
  prob_outer = 0.94
)


## ---- distributions ----
# 予測分布同士を比較
mcmc_areas(
  mcmc_sample_pred,
  pars = c("sales_pred[1]", "sales_pred[20]"), # 11度と30度
  prob = 0.6,
  prob_outer = 0.94
)
