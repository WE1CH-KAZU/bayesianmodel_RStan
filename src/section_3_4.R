################
# 事後予測のチェックについて
# 事象から近似できる確率分布を間違えたパターン
# 正規分布とポアソン分布
################

# ---- library ----
library(here)
library(rstan)
library(bayesplot)

options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

# ---- import ----
# 動物の観測数
# 草原全体を10m四方で区切った時に各セルに何匹いるか
# モデルはポアソン分布になる
animal_num <- read.csv(here("data", "raw", "2-5-1-animal-num.csv"))
head(animal_num, n = 3)


# ---- prepare data ----
ssize <- nrow(animal_num)
d_list <- list(
  animal_num = animal_num$animal_num,
  N = ssize
)

# ---- MCMC ----
normal_model <- here("src", "normal-dist.stan")
poisson_model <- here("src", "poisson-dist.stan")

mcmc_normal <- stan(
  file = normal_model,
  data = d_list,
  seed = 28
)

mcmc_poisson <- stan(
  file = poisson_model,
  data = d_list,
  seed = 28
)


# ---- check result ----
## ---- sample extraction ----
y_rep_normal <- rstan::extract(mcmc_normal)$pred
y_rep_poisson <- rstan::extract(mcmc_poisson)$pred

y_rep_normal[1,]
y_rep_poisson[1,]

## ---- compare ----
ppc_hist(
  y = animal_num$animal_num,
  yrep = y_rep_normal[1:5, ]  # 1:5までのMCMCデータ
)

ppc_hist(
  y = animal_num$animal_num,
  yrep = y_rep_poisson[1:5, ]  # 1:5までのMCMCデータ
)
