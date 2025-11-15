# ---- trend structure of Timeseries ----
# 時系列分析でしばしば用いられる、トレンド推定の問題を扱う
# 確定的トレンド
# 確率的トレンド
# 状態空間モデルによるトレンド
# この3つのモデルによる表現方法がある

# ---- 確定的トレンド ----
# "売上は毎月上がり続けている"といったトレンドのこと
# y_t - y_t-1 = η

# y_t = y_0 + t * η
# で表現できるので
# y_t = y_0 + t * η + v_t, v_t ~ Normal(0, σ^2_v)
# y_t ~ Normal(y_0 + t * η, σ^2_v)
# と表現できるようになる

# 誤差項vには標準正規分布を仮定しており、ホワイトノイズを仮定している
# という点も留意する必要がある


# ---- 確率的トレンド ----
# ホワイトノイズのi.i.d.の累積和となるランダムウォークは
# 確率的トレンドとなる

# mu_t - mu_t-1 = w_t, w_t ~ Normal(0, σ^2_w)
# mu_t = mu_0 + 累積和w_t

# このモデルに観測誤差vが加わったものがローカルレベルモデルになる
# mu_t - mu_t-1 = w_t, w_t ~ Normal(0, σ^2_w)
# y_t = mu_t + v_t, v_t ~ Normal(0,σ^2_v)


# ---- 平滑化トレンドモデル ----
# 状態方程式のmuの差分の差分をホワイトノイズに従うと仮定したモデル
# (mu_t - mu_t-1) - (mu_t-1 - mu_t-2) = η_t
# 言い換えると、2回差分が平滑化トレンドモデル
# 1回差分がローカルレベルモデル

# 上の式を整理すると状態方程式が得られる
# mu_t = 2*mu_t-1 - mu_t-2 + η_t, η_t ~ Normal(0, σ^2_η)
# 観測方程式は
# y_t = mu_t + v_t, v_t ~ Normal(0, σ^2_v)


# ---- ローカル線形トレンドモデル ----
# 平滑化トレンドモデルとの比較
# mu_tを水準成分、η_tをドリフト成分(muの差分)とすると
# ドリフト成分ηはランダムウォークに従って変化するが
# 水準成分mu_tは、過程誤差が入っていなかった。
# この過程誤差を加えたものがローカル線形トレンドモデルになる

# η_t = η_t-1 + ζ_t, ζ_t ~ Normal(0, σ-2_ζ) 
# mu_t = mu_t-1 + η_t-1 + w_t, w_t ~ Normal(0, σ^2_w)
#      = mu_t-1 + mu_t-1 - mu_t-2 + w_t と同じ


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
  here("data","raw","5-5-1-sales-ts-3.csv")
)

head(df_sale, n = 3)

summary(df_sale)

# ---- EDA ----
## ---- timeline visualization ----
autoplot(
  ts(
    df_sale[,-1]
  )
)


# ---- mcmc local level model (1回差分) ----
d_list <- list(
  T = nrow(df_sale),
  y = df_sale$sales
)

local_level <- stan(
  file = here("src","dlm_locallevelmodel_locallevelmodel.stan"),
  data = d_list,
  seed = 28,
  chains = 4,
  iter = 2000,
  warmup = 500
)

print(
  local_level,
  pars = c("sigma_w","sigma_v","mu[100]"),
  probs = c(0.025, 0.5, 0.975)
  )

traceplot(
  local_level,
  pars = c("sigma_w","sigma_v","mu[100]")
  )

mcmc_combo(
  local_level,
  pars = c("sigma_w","sigma_v","mu[100]")
)

mcmc_sample <- rstan::extract(local_level)

p_mu <- plotSSM(
  mcmc_sample = mcmc_sample,
  time_vec = as.POSIXct(df_sale$date),
  obs_vec = df_sale$sales,
  state_name = "mu",
  graph_title = "local level model",
  y_label = "sales"
)

p_mu

## ---- 結果をテーブル状態で渡して中央値を引数に出す ----
ss <- summary(local_level)$summary
parameter_names <- c("sigma_w","sigma_v","mu[100]")
parameter_median <- ss[parameter_names, "50%"]

parameter_median

# ---- 平滑化モデル ----
# このモデルから観測データを標準化してから渡すと安定する
# 今回は実施しない
smooth_trend <- stan(
  file = here("src","dlm_smooth_trend.stan"),
  data = d_list,
  seed = 28,
  chains = 4,
  iter = 4000,
  warmup = 1000,
  control = list(
    adapt_delta = 0.98,
    max_treedepth = 15
  )
)

print(
  smooth_trend,
  pars = c("sigma_w","sigma_v","mu[100]"),
  probs = c(0.025, 0.5, 0.975)
)

## ---- 結果をテーブル状態で渡して中央値を引数に出す ----
ss <- summary(smooth_trend)$summary
parameter_names <- c("sigma_w","sigma_v","mu[100]")
parameter_median_smooth <- ss[parameter_names, "50%"]

parameter_median_smooth


# ---- ローカル線形トレンドモデル ----
local_linear_trend <- stan(
  file = here("src","dlm_locallineartrend.stan"),
  data = d_list,
  seed = 28,
  chains = 4,
  iter = 4000,
  warmup = 1000,
  control = list(
    adapt_delta = 0.98,
    max_treedepth = 15
  )
)

print(
  local_linear_trend,
  pars = c("sigma_w","sigma_v","sigma_z","mu[100]"),
  probs = c(0.025, 0.5, 0.975)
)


# ---- 3つを図示して比較 ----
sample_ll <- rstan::extract(local_level)  # local level model
sample_st <- rstan::extract(smooth_trend) # smooth trend model
sample_llt <- rstan::extract(local_linear_trend)  # local linear trend model

p_ll <- plotSSM(
  mcmc_sample = sample_ll,
  time_vec = as.POSIXct(df_sale$date),
  obs_vec = df_sale$sales,
  state_name = "mu",
  graph_title = "local level model",
  y_label = "sales"
)

p_st <- plotSSM(
  mcmc_sample = sample_st,
  time_vec = as.POSIXct(df_sale$date),
  obs_vec = df_sale$sales,
  state_name = "mu",
  graph_title = "smooth trend model",
  y_label = "sales"
)

p_llt <- plotSSM(
  mcmc_sample = sample_llt,
  time_vec = as.POSIXct(df_sale$date),
  obs_vec = df_sale$sales,
  state_name = "mu",
  graph_title = "local linear trend model",
  y_label = "sales"
)

grid.arrange(p_ll,p_st,p_llt)
