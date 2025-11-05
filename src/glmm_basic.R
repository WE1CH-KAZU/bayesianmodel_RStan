# ---- GLMM 一般化線形混合モデルと階層ベイズ ----
# 階層ベイズはその名の通り、階層構造をもつモデル
# 上位の層の確率変数の実現値は、下位の層の確率分布の母数となる
# これが基本概念だが、適用方法は様々ある
# このファイルは、”すべての行に対してランダムな効果を与える”ことを前提としたモデル

# ---- library ----
library(rstan)
library(brms) # (version 2.23.0)
library(here)
library(bayesplot)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())


# ---- import data ----
df_fish <- read.csv(
  here("data","raw","4-1-1-fish-num-2.csv")
)

head(df_fish, n = 3)

summary(df_fish)

# ---- (Basical) mcmc poisson by brms ----
glm_pois_brms <- brm(
  formula = fish_num ~ weather + temperature,
  family = poisson(),
  data = df_fish,
  seed = 28,
  chains = 4,
  iter = 2000,
  warmup = 1000
)


# ---- visualization ----
# この可視化の結果、推定はできているものの、観測値のプロットが
# 99%信用区間から外れた位置になっている
# つまり、ポワソン分布では期待値と分散が等しい特殊な分布だが、
# このポワソン分布に従わないプロットがあるという事
# これが「過分散」
set.seed(28)
eff_glm_pre <- conditional_effects(
  glm_pois_brms,
  method = "predict",
  effects = "temperature:weather",
  ci_level = 0.99
)

plot(
  eff_glm_pre,
  points = T
)

# ---- 過分散の対処のためにGLMMを考える ----
# GLM
# log(λ) = Xβ
# Y ~ poisson(λ)

# GLMM
# ε ~ Normal(0,σ^2)
# log(λ) = Xβ + ε
# Y ~ poisson(λ)

# という平均ゼロ、分散σ二乗に従う正規分布が誤差項として含まれているポアソン分布
# を考えるというのが新しい発想

# この時βを固定効果、εをランダム効果あるいは変量効果という

# ---- GLMM by brms ----
# 数式
formula_glmm_pois <- formula(fish_num ~ weather + temperature)

# デザイン行列
design_mat <- model.matrix(
  formula_glmm_pois,
  df_fish
)

sunny_dummy <- as.numeric(
  design_mat[, "weathersunny"]
)

# mcmc用のデータ作成
d_list <- list(
  N = nrow(df_fish),
  fish_num = df_fish$fish_num,
  temp = df_fish$temperature,
  sunny = sunny_dummy
)

## ---- run mcmc ----
glmm_pois_stan <- stan(
  file = here("src","glmm_basic.stan"),
  data = d_list,
  seed = 28,
  chains = 4,
  iter = 2000,
  warmup = 1000
)


print(glmm_pois_stan)
# この結果を見ると、誤差項εは行数分の数が準備されている
# つまり、階層ベイズだと単なる誤差項ではなく
# 一つ一つの行に対して特定の誤差を含ませつつ
# 全体をmcmcでシミュレーションすることが可能になっている

mcmc_rhat(rhat(glmm_pois_stan))


# 特定のデータのみ表示
print(
  glmm_pois_stan,
  pars = c("Intercept","b_temp","b_sunny","sigma_r"),
  probs = c(0.03,0.5,0.97)
)
# この結果を見ると、sigma_rは平均1.1となっている
# つまりε_mean ~ N(0,1.1)という風にイメージとしてとらえることができた


# ---- 補足 ----
# brmsでもGLMMは計算可能
get_prior(
  formula = fish_num ~ weather + temperature + (1|id),
  familiy = poisson(),
  data = df_fish
)

glmm_pois_brms <- brm(
  formula = fish_num ~ weather + temperature + (1|id),
  family = poisson(),
  data = df_fish,
  seed = 28,
  chains = 4,
  iter = 2000,
  warmup = 1000
)

print(glmm_pois_brms)
