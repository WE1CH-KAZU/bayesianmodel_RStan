# ---- ポアソン回帰モデル ----

# ---- library ----
library(rstan)
library(brms) # (version 2.23.0)
library(here)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# ---- import data ----
df_fish <- read.csv(
  here("data", "raw", "3-8-1-fish-num-1.csv")
)

head(df_fish, n = 3)

summary(
  df_fish
)

# ---- data visualization ----
ggplot(
  data = df_fish,
  mapping = aes(
    x = temperature,
    y = fish_num
  )
) +
  geom_point(
    aes(color = weather)
  ) +
  labs(
    title = "天候の違いによるtemp.とfish_numの関係性"
  )


# ---- mcmc by brms ----
SEED <- 28
formula_name <- fish_num ~ temperature + weather
## 事前分布の確認
get_prior(
  formula = formula_name,
  family = poisson(),
  data = df_fish
)

glm_poisson_brms <- brm(
  formula = formula_name,
  family = poisson(),
  data = df_fish,
  seed = SEED,
  chains = 4,
  iter = 2000,
  warmup = 1000,
)

print(glm_poisson_brms)


# ---- visualization of mcmc result ----
## ---- 推定した期待値の可視化 ----
eff <- conditional_effects(
  glm_poisson_brms,
  effects = "temperature:weather"
)
plot(eff, points = TRUE)


## ---- 推定したポアソン分布（期待値と分散）の可視化 ----
set.seed(28)

eff_prob <- conditional_effects(
  glm_poisson_brms,
  method = "predict",
  effects = "temperature:weather",
  # probs = c(0.03, 0.97) この記述はversion <2.2
  # ?conditional_effectsで確認する事
  ci_level = 0.94 # 94%信用区間
)

plot(
  eff_prob,
  points = TRUE
)
