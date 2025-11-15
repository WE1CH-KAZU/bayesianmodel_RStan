# ---- 動的一般化線形モデル、ポアソン分布 ----
# リンク関数は対数になる

# ---- library ----
library(rstan)
library(brms) # (version 2.23.0)
library(here)
library(bayesplot)
library(ggfortify)
library(gridExtra)
library(KFAS)  # 論文データ. 二項分布のGDLMの分析例として使う

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# ---- module install ----
source(
  here("R","plotSSM.R")
)

# データの読み込み
fish_ts <- read.csv(
  here("data","raw","5-9-1-fish-num-ts.csv")
)
fish_ts$date <- as.POSIXct(fish_ts$date)
head(fish_ts, n = 3)

# 図示
autoplot(ts(fish_ts[, -1]))

d_list <- list(
  y = fish_ts$fish_num,
  ex = fish_ts$temperature,
  T = nrow(fish_ts)
)

dglm_poisson <- stan(
  file = here("src","dglm-poisson.stan"),
  data = d_list,
  seed = 28,
  chains = 4,
  iter = 6000,
  warmup = 1000,
  control = list(
    adapt_delta = 0.98,
    max_treedepth = 12
  )
)


# 推定されたパラメタ
print(dglm_poisson, 
      par =  c("s_z", "s_r", "b", "lp__"),
      probs = c(0.025, 0.5, 0.975))


# 参考：収束の確認
mcmc_rhat(rhat(dglm_poisson))
check_hmc_diagnostics(dglm_poisson)

# 参考:トレースプロット
mcmc_sample <- rstan::extract(dglm_poisson, permuted = FALSE)
mcmc_trace(mcmc_sample, pars = c("s_z", "s_r", "lp__"))

# 参考：推定結果一覧
options(max.print=100000)
print(dglm_poisson, probs = c(0.025, 0.5, 0.975))

# 推定結果の図示 -----------------------------------------------------------------

# MCMCサンプルの取得
mcmc_sample <- rstan::extract(dglm_poisson)

# 個別のグラフの作成
p_all <- plotSSM(mcmc_sample = mcmc_sample, 
                 time_vec = fish_ts$date,
                 obs_vec = fish_ts$fish_num,
                 state_name = "lambda_exp", 
                 graph_title = "状態推定値", 
                 y_label = "釣獲尾数",
                 date_labels = "%Y年%m月%d日") 

p_smooth <- plotSSM(mcmc_sample = mcmc_sample, 
                    time_vec = fish_ts$date,
                    obs_vec = fish_ts$fish_num,
                    state_name = "lambda_smooth", 
                    graph_title = "ランダム効果を除いた状態推定値", 
                    y_label = "釣獲尾数",
                    date_labels = "%Y年%m月%d日") 

p_fix <- plotSSM(mcmc_sample = mcmc_sample, 
                 time_vec = fish_ts$date,
                 obs_vec = fish_ts$fish_num,
                 state_name = "lambda_smooth_fix", 
                 graph_title = "気温を固定した状態推定値", 
                 y_label = "釣獲尾数",
                 date_labels = "%Y年%m月%d日") 

# まとめて図示
grid.arrange(p_all, p_smooth, p_fix)