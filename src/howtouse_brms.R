# ---- How to use brms ----
# brmsを使えばstanを書かなくてもベイズ推定ができる

# ---- library ----
library(rstan)
library(brms) # (version 2.23.0)
library(here)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# ---- import data ----
beer_sales <- read.csv(
  here("data", "raw", "3-2-1-beer-sales-2.csv")
)

# ---- prediction of mcmc by brms ----

## ---- get_prior ----
# どんな事前分布が自動設定されるのかあらかじめ確認できる
get_prior(
  formula = sales ~ temperature,
  family = gaussian(),
  data = beer_sales
)

# 単回帰モデルをこの数行で処理する
single_glm_brms <- brm(
  formula = sales ~ temperature,
  family = gaussian(
    link = "identity"
  ),
  data = beer_sales,
  seed = 28,
  chains = 4,
  iter = 2000,
  warmup = 1000,
)

single_glm_brms

# 裏で実行されたstancodeを目視で確認できる
stancode(
  single_glm_brms
)

## ---- prior estimation ----
prior_summary(single_glm_brms)

# ---- visualization ----
as.mcmc(
  single_glm_brms,
  combine_chains = TRUE
)

plot(
  single_glm_brms
)

mcmc_plot(
  single_glm_brms,
  pars = "^b_", # 頭がb_から始まるパラメータ正規表現
  prob = 0.8,
  prob_outer = 0.94
)

# ---- prediction ----
# brmsによる予測
# 予測したいデータをデータフレームとして渡す
new_data <- data.frame(
  temperature = 20
)

set.seed(28)
predict(
  single_glm_brms,
  new_data,
  pars = c(0.3, 0.97)
)

# ---- visualization of lenear graph ----
## ---- 回帰直線の95％信用区間付きグラフの生成 ----

# 描かれるグラフは「回帰直線の事後平均（E[y|x]）」と
# その事後分布の95％信用区間（credible interval, CI）です。

# 灰色の帯は「この温度のとき、平均的な売上（母集団平均）はこの範囲にあるだろう」という不確実性の範囲。
# 実際の観測値は、この帯の外に普通に出てもおかしくありません。
# 数式的には、mu = Xβを可視化している
eff <- conditional_effects(single_glm_brms)
plot(
  eff,
  points = TRUE
)

## ---- 予測区間付きグラフ ----
# 回帰直線＋ノイズ（σ）込みの「新しい観測データが出る範囲」です。
# 灰色の帯は「この温度で実際に観測される個々の売上がプロットされるであろう範囲」。
# 数式的には y ~ normal(mu, sigma)の範囲を示している
eff_pre <- conditional_effects(
  single_glm_brms,
  method = "predict"
)
plot(
  eff_pre,
  points = TRUE
)


# ---- Options:事前分布を指定してbrmsを実行する ----
# tips: 裾広な正規分布を指定する場合
# set_prior("normal(0,10000000), class = "b", coef = "temperature")
# version 2.23では一様分布は空情報で指定できない
# uniform(0,100)といった範囲を指定する必要がある

single_glm_brms_2 <- brm(
  formula = sales ~ temperature,
  family = gaussian(),
  data = beer_sales,
  seed = 28,
  prior = c(
    set_prior("uniform(-100, 100)", class = "Intercept"), # 一様分布を明示的に指定
    set_prior("uniform(0, 100)", class = "sigma") # 一様分布を明示的に指定
  ),
  chains = 4,
  iter = 2000,
  warmup = 1000
)
