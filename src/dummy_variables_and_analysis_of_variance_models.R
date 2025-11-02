# ---- Dummy variables and analysis of variance model ----
# ダミー変数と分散分析モデル
# 説明変数にダミー変数（質的データ）を用いたモデリングを学習する

# ---- library ----
library(rstan)
library(brms) # (version 2.23.0)
library(here)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# ---- import data ----
sales_weather <- read.csv(
  here("data", "raw", "3-6-1-beer-sales-3.csv")
)

summary(sales_weather)
head(sales_weather, n = 3)

## ---- data visualization ----
ggplot(
  data = sales_weather,
  mapping = aes(
    x = weather,
    y = sales
  )
) +
  geom_violin() +
  geom_point(
    aes(color = weather)
  ) +
  labs(
    title = "ビールの売上と天候の関係"
  )

# ---- prediction variance model using brms ----
## ---- 事前分布の確認 ----
get_prior(
  formula = sales ~ weather,
  family = gaussian(),
  data = sales_weather
)

## ---- モデルの作成 ----
anova_brms <- brm(
  formula = sales ~ weather,
  family = gaussian(),
  data = sales_weather,
  seed = 28,
  chains = 4,
  iter = 2000,
  warmup = 1000
)

print(anova_brms)

## ---- 推定された係数を使って可視化 ----
## 平均値の95%信用区間のグラフ化
eff <- conditional_effects(anova_brms)
plot(
  eff,
  anova_brms
)
