# ---- GLMM 一般化線形混合モデルと階層ベイズ ----
# 階層ベイズはその名の通り、階層構造をもつモデル
# 上位の層の確率変数の実現値は、下位の層の確率分布の母数となる
# これが基本概念だが、適用方法は様々ある
# このファイルは、”固定効果ではなくランダム効果に階層を持たせる”ことを前提としたモデル

# ---- library ----
library(rstan)
library(brms) # (version 2.23.0)
library(here)
library(bayesplot)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# ---- import data ----
# 今回のデータは10人分のデータだが、Jさんは4回しかデータがない
df_fish <- read.csv(
  here("data","raw","4-3-1-fish-num-4.csv")
)

head(df_fish, n = 3)

summary(df_fish)

table(df_fish$human)

# ---- ランダム係数モデル ----
# ランダム効果が加わる事で、他の説明変数の固定効果の強さが増減するモデル
# つまり、モデルの係数がランダム効果によって増減する

# ---- mcmc by brms ----
formula <- formula(fish_num ~ temperature * human)

get_prior(
  formula = formula,
  family = poisson(),
  data = df_fish
)
# 事前分布をみてもわかるように交互作用の効果により
# temp. とhumanの全部の組み合わせが入っている

## ---- glm model ----
glm_fish_brm_interaction <- brm(
  formula = formula,
  family = poisson(),
  data = df_fish,
  seed = 28,
  chains = 4,
  iter = 2000,
  warmup = 1000
)

## ---- glm 可視化 ----
# この可視化の結果、Ｊさんだけが温度に対してfish_numが下がっている。
# たまたまＪさんが4回しか結果がなくて、たまたま温度が低い時に
# fish_numが多かった可能性がある。
conditions <- data.frame(
  human = c("A","B","C","D","E","F","G","H","I","J")
)

eff_glm_brm <- conditional_effects(
  glm_fish_brm_interaction,
  effects = "temperature",
  conditions = conditions
)

plot(eff_glm_brm, points = T)


# ---- glmm model ----
# Jさんだけおかしい。温度が上がると活発になってfish_numは増えるはずだ
# この仮説が正しいとおいたとき、どのようにＪさんの回帰を調整するか
# これがランダム効果の発揮するポイント
#
# ランダム効果を用いて釣り人固有の能力をモデルに組み込んだ時は
# 交互作用(上記のglm model)を用いたときと比べて、「全体的に似たような傾向」を示すようになる
# これを”全体から説得力を借用している”という概念として縮約（shrinkage）とよぶ

# ただし、縮約の効果はランダム係数モデルだけに訪れるものではなく
# ランダム切片モデルでも起こり得る
# このランダム係数モデルはあくまでその仮説
# 「温度が上がると活発になってfish_numは増えるはずだ」という事が成立する場合のみ適用可能

# これが薬のケースに置き換える場合
# Ｊさんだけ特異体質だったのかもしれない。


####
# モデル構造

# r ~ Normal(0, σ^2_r)
# tau ~ Normal(0, σ^2_tau)
# log(λ) = β_0 + (β_1 + tau)x + r
# y ~ poisson(λ)

# ---- mcmc ----

## ---- モデル作成 ----
formula_keisu <- formula(
  fish_num ~ temperature + (temperature||human)
)
# この"temperature||human"は"temperature|human"と明確に異なる
# どちらも「ランダム切片とランダム係数の効果を与える」ことは同じ
# "|"はランダム切片とランダム係数に相関があるということを表現している
# つまり、ランダム切片は人それぞれの切片を表現していて
# ランダム係数は交互作用にランダム係数を与えているので
# "|"は切片が大きくなれば（釣りが上手い人ほど）、ランダム係数もおおきくなる
# (天気の効果も得られやすい)ということになる。
# モデルとしてそれは考えにくいので"||"を使って無相関を表現している

## ---- 事前分布確認 ----
get_prior(
  formula = formula_keisu,
  family = poisson(),
  data = df_fish
)

## ---- mcmc by brms ----
glmm_fish_brms_randomkeisu <- brm(
  formula = formula_keisu,
  family = poisson(),
  data = df_fish,
  seed = 28,
  chains = 4,
  iter = 6000,
  warmup = 5000,
  control = list(
    adapt_delta = 0.98,
    max_treedepth = 15
  ),
  save_warmup = T  # これを入れるとwarmupも記録してくれる
)

print(glmm_fish_brms_randomkeisu)
# adapt_delta = 0.97 だとdivergentが3回出ている
# もう少し上げて調整する


# brmsはデフォでstanfitも入っている
# warmupも可視化したい場合はbrmsからstanfitを取り出す必要がある
# 取り出してrstan::traceplotで可視化
rstan::traceplot(
  glmm_fish_brms_randomkeisu$fit,
  inc_warmup = T,
)

glmm_fish_brms_randomkeisu_099 <- brm(
  formula = formula_keisu,
  family = poisson(),
  data = df_fish,
  seed = 28,
  chains = 4,
  iter = 6000,
  warmup = 5000,
  control = list(
    adapt_delta = 0.99,
    max_treedepth = 15
  ),
  save_warmup = T  # これを入れるとwarmupも記録してくれる
)

rstan::traceplot(
  glmm_fish_brms_randomkeisu_099$fit,
  inc_warmup = T,
)

mcmc_plot(
  glmm_fish_brms_randomkeisu_099,
  type = "trace"
)


## ---- visualization ----
eff_glmm_brm <- conditional_effects(
  glmm_fish_brms_randomkeisu_099,
  re_formula = NULL,
  effects = "temperature",
  conditions = conditions
)

plot(
  eff_glmm_brm,
  points = T
)
