# ---- GLMM 一般化線形混合モデルと階層ベイズ ----
# 階層ベイズはその名の通り、階層構造をもつモデル
# 上位の層の確率変数の実現値は、下位の層の確率分布の母数となる
# これが基本概念だが、適用方法は様々ある
# このファイルは、”あるカテゴリー変数毎に偏りがある”ことを前提としたモデル

# ---- library ----
library(rstan)
library(brms) # (version 2.23.0)
library(here)
library(bayesplot)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# ---- import data ----
df_fish <- read.csv(
  here("data","raw","4-2-1-fish-num-3.csv")
)

head(df_fish, n = 3)

summary(df_fish)

print(
  table(df_fish$human)
)


# ---- ランダム切片効果モデル ----
# r_k ~ Normal(0, σ^2)
# log(λ) = Xβ + r_k
# Y ~ poisson(λ)

# 今回の場合humanの種類が10個あって、それぞれがn=10である
# つまり、10人分のばらつき傾向があると考え、
# それをrで"切片"を10種類分ずらしてシミュレーションしてみる
# というイメージ

# 要点は、個別の効果を把握したいという目的ではなく
# 個別のずれを把握しつつ全体はどうなっているのか？を把握したいという点


# ---- mcmc by brms ----
formula <- formula(fish_num ~ weather + temperature + (1|human))

get_prior(
  formula = formula,
  family = poisson(),
  data = df_fish
)

glmm_pois_brms_human <- brm(
  formula = formula,
  family = poisson(),
  data = df_fish,
  seed = 28,
  chains = 4,
  iter = 2000,
  warmup = 1000,
)

## ---- results ----
print(
  glmm_pois_brms_human
)

plot(
  glmm_pois_brms_human
)

stanplot(
  glmm_pois_brms_human,
  type = "rhat"
)

ranef(
  glmm_pois_brms_human
)


# ---- visualization ----
conditions <- data.frame(
  human = c("A","B","C","D","E","F","G","H","I","J")
)

eff_glmm_human <- conditional_effects(
  glmm_pois_brms_human,
  effects = "temperature:weather",
  re_formula = NULL,
  conditions = conditions
)

plot(eff_glmm_human, points = T)
