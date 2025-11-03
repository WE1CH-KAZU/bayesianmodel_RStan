# ---- ロジスティック回帰モデル ----
# 重要な事：応答変数は実数値にすること
# ロジスティック回帰だとついつい「何割か？」という問いを応答変数にしがち
# いくつで割るか？についてはoffset()で処理する

# 結果が0, 1の場合はベルヌーイ分布をfamilyに指定する
# 基本的な部分だが二項分布とベルヌーイ分布を使い分けること

# ---- library ----
library(rstan)
library(brms) # (version 2.23.0)
library(here)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# ---- import data ----
# 発芽数
df_germination <- read.csv(
  here("data", "raw", "3-9-1-germination.csv")
)

head(df_germination, n = 3)

summary(df_germination)
# germination : 10こ中何個発芽したか
# nutrition : 栄養素の量

# ---- data visualization ----
ggplot(
  data = df_germination,
  mapping = aes(
    x = nutrition,
    y = germination
  )
) +
  geom_point(
    aes(color = solar)
  ) +
  labs(
    title = "日照の有無に対する、栄養素の量と発芽数の関係"
  )


# ---- mcmc by brms ----
set.seed(28)
formula_name <- germination | trials(size) ~ nutrition + solar
## ---- 事前分布の確認 ----
get_prior(
  formula = formula_name,
  family = binomial(), # ロジスティックの確率分布は二項分布
  data = df_germination
)


glm_logistic_brms <- brm(
  formula = formula_name,
  family = binomial(),
  data = df_germination,
  chains = 4,
  iter = 2000,
  warmup = 1000,
  seed = 28
)

print(glm_logistic_brms)


## ---- モデルの解釈 ----
# ロジスティック回帰モデルは、シグモイド関数を使っているので
# 対数オッズ比で処理する必要がある

# デモ用の説明変数を作成する
df_germ_result <- data.frame(
  solar = c("shade", "sunshine", "sunshine"),
  nutrition = c(2, 2, 3),
  size = c(10, 10, 10)
)


# 線形予測子の予測値
# 1 / (1 + exp(-x)) のxの予測値
linear_fit <- fitted(
  glm_logistic_brms,
  df_germ_result,
  scale = "linear"
)[, 1]

# シグモイド関数に代入
fit <- 1 / (1 + exp(-linear_fit))

print(fit) # この結果が二項分布の確率

print(fit[1])


# オッズ比の結果
odds_1 <- fit[1] / (1 - fit[1])
odds_2 <- fit[2] / (1 - fit[2])
odds_3 <- fit[3] / (1 - fit[3])

# 対数オッズ比の計算（完全手動）
odds_2 / odds_1

# 対数オッズ比の計算（係数から計算）
coef <- fixef(glm_logistic_brms)[, 1]
exp(coef["solarsunshine"])


# ---- visualization of mcmc result ----
eff <- conditional_effects(
  glm_logistic_brms,
  effects = "nutrition:solar",
  method = "fitted",
  ci_level = 0.94,
  conditions = data.frame(size = 10) # 元のデータフレームにsize = 10を入れる
)
plot(
  eff,
  points = TRUE
)
