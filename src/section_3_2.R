# ---- load packages ----
library(rstan)
library(here)

# ---- 高速化処理 ----
# Stanは内部でC++を使っている。
# C++を実行する際にコンパイルすることになるが、毎回コンパイルすると時間がかかる
# 次のコードでRDSファイルを作成し再度コンパイルしなくて済むように処理をする
rstan_options(auto_write = TRUE)

# さらにCPUの並列処理を許可し高速化する
options(mc.cores = parallel::detectCores())


# ---- import data ----
file_beer_sales_1 <- read.csv(here("data","raw","2-4-1-beer-sales-1.csv"))
dim(file_beer_sales_1)
head(file_beer_sales_1, n = 3)

# ---- MCMC に向けての前処理 ----
### ---- list型へ変更 ----
# Stan を使ってMCMCを行う場合、list型で渡す必要がある

# sample size
s_size <- nrow(file_beer_sales_1)

# to list
data_list <- list(
  sales = file_beer_sales_1$sales,  # 明示的に列を指定する必要がある
  N = s_size
)
print(data_list)
dim(data_list)


# ---- Stanと連携してMCMCを実行する ----
SEED <- 28

mcmc_result <- stan(
  file = "src/section3_calc-normal-mean-variance.stan",  # stanのファイル. working directryから記述する必要あり
  model_name = "normal_model",  # model name
  data = data_list,  # data
  seed = SEED,  # シード値
  chains = 4,  # チェーン数（セット数）
  iter = 4000,  # iteration
  warmup = 1000,  # バーンイン 数（初回の乱数生成からどれだけ捨てるか）
  thin = 1  # 間引き数（iterationからどれだけ間引くか。1は間引かない）
)


# ---- 結果を確認する ----
## ---- 全体概要 ----
# print関数を使って表示させるのが最も簡単

print(
  mcmc_result,
  probs = c(0.03, 0.5, 0.97) # 中央値と94%信用区間を表示
)
# この結果で出てくる"lp__"は対数事後確率と呼ばれるもの。
# 事前分布と尤度を掛け合わせた時に得られる確率密度のlog値
# stanのサンプリング(NUTS)ではこの値が最大化されるように内部で計算されている


## ---- trace plot ----
traceplot(mcmc_result)

# 意図的にバーンインを含めたtraceplotも記述できる
traceplot(mcmc_result, inc_warmup = TRUE)



# ---- (option)ベイズモデル構造を可視化する ----
# python, arvizのようなライブラリは存在しないので、以下のコードで自作するしかない。
# 可視化してみたが、arvizが優秀過ぎる。コードをコピペして生成AIに書き直してもらったものを
# arvizで可視化するほうがぜったい良い。

# install.packages(c("dagitty", "ggdag", "ggplot2"))
# library(dagitty)
# library(ggdag)
# library(ggplot2)

# DAG（プレートの中身は sales[i] としておく）
g <- dagitty("dag {
  mu -> sales
  sigma -> sales
}")

# レイアウト座標（見やすい配置を明示）
coordinates(g) <- list(
  mu    = c(0, 1),
  sigma = c(2, 1),
  sales = c(1, 0)
)

p <- ggdag(g, text = FALSE, use_labels = "name") +
  geom_dag_point() +
  geom_dag_text(size = 5, vjust = -1/2) +
  geom_dag_edges(arrow_directed = grid::arrow(length = unit(6, "pt"))) +
  # プレート（i=1..N）を注釈で描く：sales の周りを囲う
  annotate("rect",
           xmin = 0.6, xmax = 1.4, ymin = -0.4, ymax = 0.4,
           linetype = "dashed", fill = NA) +
  annotate("text", x = 1.4, y = 0.42, label = "i = 1..N", hjust = 1, size = 4) +
  theme_void()

p

