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
  here("data", "raw", "3-10-1-interaction-1.csv")
)

head(df_inter, n = 3)

summary(df_inter)

# ---- data visualization ----
## ---- publicity ----
ggplot(
  df_inter,
  aes(
    x = sales,
    fill = publicity
  )
) +
  geom_histogram(
    position = "identity", alpha = 0.6, bins = 30
  ) +
  labs(x = "Sales", y = "Count", title = "Distribution of sales") +
  theme_minimal()


## ---- bargen ----
ggplot(
  df_inter,
  aes(
    x = sales,
    fill = bargen
  )
) +
  geom_histogram(
    position = "identity", alpha = 0.6, bins = 30
  ) +
  labs(x = "Sales", y = "Count", title = "Distribution of sales") +
  theme_minimal()


# ---- mcmc by brms ----
# この式でsales ~ publicity + bargen + publicity * bargenの意味になる
formula <- sales ~ publicity * bargen

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


# ---- visualization ----
eff <- conditional_effects(
  inter_brms,
  effects = "publicity:bargen"
)
plot(eff, points = TRUE)
