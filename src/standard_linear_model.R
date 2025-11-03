# ---- 正規線形モデル ----
# 説明変数にカテゴリーと連続値(質的、量的)両方入っているモデル

# ---- library ----
library(rstan)
library(brms) # (version 2.23.0)
library(here)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# ---- import data ----
df_sales <- read.csv(
  here("data", "raw", "3-7-1-beer-sales-4.csv")
)

head(df_sales, n = 3)

summary(df_sales)

# ---- data visualization ----
ggplot(
  data = df_sales,
  mapping = aes(
    x = temperature,
    y = sales
  )
) +
  geom_point(
    aes(
      colour = weather
    )
  ) +
  labs(
    title = "天候の違いによるtemp.とsalesの関係性"
  )


# ---- model by brms ----
# 正規線形モデルの作成

## ---- get_prior ----
get_prior(
  formula = sales ~ temperature + weather,
  family = gaussian(),
  data = df_sales
)

lm_brms <- brm(
  formula = sales ~ temperature + weather,
  family = gaussian(),
  data = df_sales,
  seed = 28,
  chains = 4,
  iter = 2000,
  warmup = 1000,
)

print(lm_brms)

# ---- graph ----
# 線形回帰を可視化
eff <- conditional_effects(
  lm_brms,
  effects = "temperature:weather"
)
plot(eff,
  points = TRUE
)
