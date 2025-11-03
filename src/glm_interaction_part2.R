# ---- GLMの交互作用モデル ----
# 質的と量的それぞれで交互作用を考えることができる
# 質的x質的, 量的x量的, 質的x量的


# ---- library ----
library(rstan)
library(brms) # (version 2.23.0)
library(here)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# ---- import data ----
df_inter <- read.csv(
  here("data", "raw", "3-10-2-interaction-2.csv")
)

head(df_inter, n = 3)

summary(df_inter)
# publicity : category
# temperatture : numeric

# ---- data visualization ----
ggplot(
  df_inter,
  aes(
    x = temperature,
    y = sales,
    colour = publicity
  )
) +
  geom_point() +
  labs(x = "temperature", y = "Sales", title = "Distribution of sales") +
  theme_minimal()


# ---- mcmc by brms ----
# この式でsales ~ publicity + temperature + publicity * temperatureの意味になる
formula <- sales ~ publicity * temperature

## ---- 事前分布の確認 ----
get_prior(
  formula = formula,
  family = gaussian(link = "identity"),
  data = df_inter
)

set.seed(28)
SEED <- 28

inter_brms <- brm(
  formula = formula,
  family = gaussian(link = "identity"),
  data = df_inter,
  seed = SEED,
  chains = 4,
  iter = 2000,
  warmup = 1000,
)

print(inter_brms)
# 交互作用を含めたリンク関数は
# Intercept + publicityto_implement + temp * (temperature + publicityto_implement:temperature)


# ---- visualization ----
eff <- conditional_effects(
  inter_brms,
  effects = "temperature:publicity" # ここを逆に書き換えると違う可視化になる
)
plot(eff, points = TRUE)
