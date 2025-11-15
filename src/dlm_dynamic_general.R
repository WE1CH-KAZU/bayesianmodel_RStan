# ---- 動的線形モデル dynamic linear model ----
# 説明変数の係数が時間に応じて変化することを想定したモデル
# "かつては影響力が強かったが、今ではそうではない"をモデルに落とし込む

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
  here("data","raw","5-4-1-sales-ts-2.csv")
)

head(df_sale, n = 3)

summary(df_sale)

# ----- data EDA ----
autoplot(
  ts(df_sale[, -1]) # 1列目以外
)


# ---- あえて間違いの単回帰ベイズモデル適用 ----
## ---- 期間全体 ----
formula_glm <- formula(sales ~ publicity)
get_prior(
  formula = formula_glm,
  family = gaussian(link = "identity"),
  data = df_sale
)

mod_glm <- brm(
  formula = formula_glm,
  family = gaussian(link = "identity"),
  data = df_sale,
  chains = 4,
  iter = 2000,
  warmup = 500,
  seed = 28
)

print(mod_glm)

## ---- 前半50区間 ----
df_sale_head <- head(df_sale, n = 50)
df_sale_tail <- tail(df_sale, n = 50)

mod_glm_head <- brm(
  formula = formula_glm,
  family = gaussian(link = "identity"),
  data = df_sale_head,
  chains = 4,
  iter = 2000,
  warmup = 500,
  seed = 28
)

print(mod_glm_head)
# publicity, Estimate = 11


## ---- 後半50区間 ----
mod_glm_tail <- brm(
  formula = formula_glm,
  family = gaussian(link = "identity"),
  data = df_sale_tail,
  chains = 4,
  iter = 2000,
  warmup = 500,
  seed = 28
)

print(mod_glm_tail)
# publicity, Estimate = 5


# ---- 時変係数モデル ----
# 最も簡単な形は、説明変数の回帰係数がランダムウォークに従って変化する。
# "ランダムウォークする切片"に加えて"ランダムウォークする回帰係数"という
# モデルが一番簡単なモデル

# mu_t = mu_t-1 + w_t, w_t ~ Normal(0, σ^2_w)
# β_t = β_t-1 + tau_t, tau_t ~ Normal(0, σ^2_tau)

# α_t = mu_t + β_t * x_t
# y_t = α_t + v_t, v_t ~ Normal(0, σ^2_v)

# yはαとランダムウォークするvで表現でき
# αはmuを切片にもつ単回帰係数モデルであり
# muは過去のmuを平均とする分散σ^2_wの正規分布で表現でき
# βは過去のβを平均とする分散σ^2_tauの正規分布で表現できる
# という構造

## ---- mcmc setting ----
d_list <- list(
  T = nrow(df_sale),
  ex = df_sale$publicity,
  y = df_sale$sales
)

## ---- mcmc by stan ----
mcmc_timeseries <- stan(
  file = here("src","dlm_dynamic_general.stan"),
  data = d_list,
  seed = 28,
  chains = 4,
  iter = 6000,
  warmup = 1000,
  control = list(
    adapt_delta = 0.98
  )
)

print(
  mcmc_timeseries,
  pars = c("sigma_w","sigma_tau","sigma_v", "mu[100]", "b[100]"),
  probs = c(0.025, 0.5, 0.975)
)

# ---- 可視化 ----
mcmc_sample <- rstan::extract(
  mcmc_timeseries
)

df_sale$date <- as.POSIXct(df_sale$date)

p_all <- plotSSM(
  mcmc_sample = mcmc_sample,
  time_vec = df_sale$date,
  obs_vec = df_sale$sales,
  state_name = "alpha",
  graph_title = "Result of Estimate (観測方程式(y_hat = α + v))",
  y_label = "sales"
)

p_mu <- plotSSM(
  mcmc_sample = mcmc_sample,
  time_vec = df_sale$date,
  obs_vec = df_sale$sales,
  state_name = "mu",
  graph_title = "Result of Estimate (mu: α内の切片)",
  y_label = "sales"
)

p_b <- plotSSM(
  mcmc_sample = mcmc_sample,
  time_vec = df_sale$date,
  # obs_vec = df_sale$sales,
  state_name = "b",
  graph_title = "Result of Estimate (b: α内のpublisityにかかる回帰係数)",
  y_label = "coef"
)


grid.arrange(
  p_all,p_mu,p_b
)
