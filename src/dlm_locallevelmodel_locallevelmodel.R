# ---- local level model ----
# DLMのもっとも基本的なモデル

# local level model
# 状態方程式: μ_t = μ_t-1 + ω_t, ω_t ~ Normal(0, σ^2_ω)
# 観測方程式: y_t = μ_t + v_t, v_t ~ Normal(0, σ^2_v)

# 状態方程式μは過去の自分とホワイトノイズの和
# 観測方程式はμとホワイトノイズの和

# ω：過程誤差
# v: 観測誤差


# ---- library ----
library(rstan)
# library(brms) # (version 2.23.0)
library(here)
library(bayesplot)
library(ggfortify)
library(gridExtra)


rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())


# ---- import data ----
df_sale <- read.csv(
  here("data","raw", "5-2-1-sales-ts-1.csv")
)

head(df_sale, n = 3)

summary(df_sale)


# ---- POSIXctの補足 ----
# 1970年1月1日0時0分0秒を規準に数値計算が可能になる関数
POSIXct_time <- as.POSIXct(
  "1970-01-01 00:00:09",
  tz = "UTC"  # timezone
)
as.numeric(POSIXct_time)

# ---- prepare data for mcmc ----
list_sale <- list(
  T = nrow(df_sale),
  y = df_sale$sales
)

# mcmc
locallevelstan <- stan(
  file = here("src","dlm_locallevelmodel_locallevelmodel.stan"),
  data = list_sale,
  seed = 28,
  chains = 4,
  iter = 2000,
  warmup = 500
)

# 収束の確認
mcmc_rhat(
  rhat(
    locallevelstan
  )
)

# 結果の表示
# 状態方程式の推定値はすべてシミュレーションで出しているので
# そのままprintすると状態方程式の推定値がすべてprintされる点に注意
print(
  locallevelstan,
  pars = c("sigma_w", "sigma_v", "lp__"),
  probs = c(0.025, 0.05, 0.5, 0.95, 0.975)
)

# sigma_w < sigma_v になっている
# つまり、観測誤差のほうが大きい
# この結果からどんなアクションが考えられるかは次のセクションから


## ---- 可視化 ----
mcmc_sample <- rstan::extract(
  locallevelstan
)

# 95% ベイズ信用区間と中央値
# これを時点の数（今回は100）繰り返すことになる
quantile(
  mcmc_sample$mu[,1],
  probs = c(0.025, 0.5, 0.975)
)


# 時点100回分の繰り返し
# テーブルの構造は[category, number = chains * iteration, row]
# つまりmuというデータは、row(100)毎に4*2000 = 6000データ入っている
# これをrow毎に6000データから信用区間を計算する
result_df <- data.frame(
  t(apply(
    X = mcmc_sample$mu,  # 対象とするデータ
    MARGIN = 2,  # 対象列：2列目
    FUN = quantile,  # 実行する関数
    probs = c(0.025, 0.5, 0.975)
  ))
)

# 列名の変更
colnames(result_df) <- c("0.025", "0.5", "0.975")
# 時間軸の追加
result_df$time <- df_sale$date
# 観測値の追加
result_df$observed_value <- df_sale$sales
# 型の変更
result_df$time <- as.POSIXct(result_df$time)

# 可視化
ggplot(
  data = result_df,
  mapping = aes(
    x = time,
    y = observed_value
  )
) + 
  geom_point(alpha = 0.5, size = 0.8) +
  geom_line(
    aes(y = `0.5`),
    linewidth = 1
  ) +
  geom_ribbon(
    aes(ymin = `0.025`, ymax = `0.975`),
    alpha = 0.3
    ) +
  labs(title = "Result estimation of LocalLevelmodel") +
  ylab("sales") +
  scale_x_date(date_labels = "%Y年%m月")

# ---- この可視化によりわかること ----
# ■ モデル推論と結果のレビュー
# モデル適合性（全体傾向）
# 　推定された状態（黒線）は全体として観測値の動向をよく捉えており、滑らかなトレンド構造が正しく再現されている。
# 　1〜4月の期間で「下降 → 上昇 → 再下降」という非定常的な構造が自然に表現されており、**ローカルレベルモデルの特性（ゆるやかに変動する潜在平均）**がうまく機能している。

# 信用区間（95% CI）の幅
# 　全期間で信用区間が一定ではなく、外挿領域や急激な変化部分で幅が広がる傾向が見られる。
# 　これは、状態ノイズ σ_w が一定でも、カルマンフィルタの更新ステップで不確実性が蓄積・減衰していく自然な結果であり、推定としては妥当。

# 一部観測値が区間外に出ている理由
# 　局所的に外れる点は、観測誤差σ_vが一様と仮定していることの限界を示唆。
# 　特に外れ値周辺では、外生的イベント（販促・気候・供給制約など）による一時的な変動をモデルが吸収しきれていない。
# 　ローカルレベルモデルは「ランダムウォーク＋観測ノイズ」という最小構造なので、短期的な急変には追従が遅れるのが特徴。

# σ_w < σ_v の推定結果との整合
# 　状態ノイズより観測ノイズが大きい → 「真の売上トレンドは滑らか、観測値のばらつきは観測誤差由来」。
# 　よって、多少の外れ点はむしろ**“現場データの計測変動をモデルが正しく区別している証拠”**であり、モデルの構造自体は健全。

# 改善・次のステップ
# 　外れが集中している期間（たとえばトレンド転換直後）に注目し、
# 　**ローカル線形トレンドモデル（Local Linear Trend Model）**へ拡張することで、加速度的変化を追いやすくなる。
# 　季節変動が明確なら ローカルレベル＋季節成分（DLM with seasonal） に拡張。
# 　観測誤差が時期により変動していそうなら、時変分散σ_v(t) を導入した階層構造も有効。

# 実務上の示唆
# 　観測ノイズ優勢（σ_w < σ_v）なデータでは、短期変動を重視する意思決定（販促効果判定など）には不向き。
# 　代わりに、中期的トレンドや構造変化の把握に用いると効果的。
# 　モデルの出力をダッシュボード化する場合は、状態推定値μ_tを“真の売上トレンド”として提示し、観測値の上下振れは参考情報に留めるのが望ましい。

# ■ 総評
# モデル整合性：◎（非定常トレンドを適切に表現）
# 信頼区間：妥当（一部外れは観測ノイズ説明可能）
# 今後の改善方向： トレンド変化や季節性の導入を検討
# 意思決定上の解釈： 売上変動の多くは計測・短期ノイズによる可能性が高く、
# 経営判断はトレンド（μ_t）ベースで行うべき。
  

# ---- 可視化関数 ----
source(here("R","plotSSM.R"))

p <- plotSSM(
  mcmc_sample = mcmc_sample,
  time_vec = df_sale$date,
  obs_vec = df_sale$sales,
  state_name = "mu",
  graph_title = "Estimation Result",
  y_label = "sales",
)

p  
  
  
  
  