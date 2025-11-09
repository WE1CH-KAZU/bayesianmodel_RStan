# ---- local level model White-noise and Random-walk ----
# DLMのもっとも基本的なモデル
# Random walkの大事なこと：前の時点の値を期待値とする正規分布」なので
# 前の時点の期待値をもとに次の時点の期待が得られていくので
# 一度でも突飛な値が出ると、その影響が残ったままになる

# ---- library ----
library(rstan)
# library(brms) # (version 2.23.0)
library(here)
library(bayesplot)
library(ggfortify)
library(gridExtra)


rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# ---- base design ----
set.seed(28)
SEED <- 28

# ---- 正規ホワイトノイズ ----
whiten <- rnorm(
  n = 100,
  mean = 0,
  sd = 1
)

## ---- 累積和をとって可視化してみる ----
# 累積和をとって、値がどういう風に増減しているのかを可視化

# ランダムウォーク
random_walk <- cumsum(whiten)  #cumsum: 累積和

df_wn <- data.frame(
  time = seq_along(whiten),
  value = whiten
)

df_rw <- data.frame(
  time = seq_along(random_walk),
  value = random_walk
)

p_wn_1 <- ggplot(
  data = df_wn,
  mapping = aes(
    x = time,
    y = value
  )
) + 
  geom_line() +
  labs(title = "white noise")

p_rw_1 <- ggplot(
  data = df_rw,
  mapping = aes(
    x = time,
    y = value
  )
) + 
  geom_line() +
  labs(title = "Random walk")

# 二つのグラフをまとめて可視化
grid.arrange(p_wn_1, p_rw_1)
# このグラフはたまたまこうなっただけ
# seedを変えればグラフが変わる


# ---- 複数のホワイトノイズとランダムウォーク ----

# 空箱を用意
wn_matrix <- matrix(
  nrow = 100,
  ncol = 20,  # 20個分のwnを作る予定
)
rw_matrix <- matrix(
  nrow = 100,
  ncol = 20,  # 20個分のrwを作る予定
)

# データ生成
set.seed(28)
for (i in 1:20) {  # i はmatrix列の番号
  wn <- rnorm(
    n = 100,
    mean = 0,
    sd = 1
  )
  wn_matrix[,i] <- wn
  rw_matrix[,i] <- cumsum(wn)
}


## ---- 可視化 ----
df_wn_2 <- reshape2::melt(wn_matrix)
df_rw_2 <- reshape2::melt(rw_matrix)


p_wn_2 <- ggplot(
  data = df_wn_2,
  mapping = aes(
    x = Var1,
    y = value,
    group = Var2
  )
) + 
  geom_line(
    alpha = 0.4,
    color = "steelblue"
  ) + 
  labs(
    title = "White noise",
    x = "time",
    y = "Value"
  ) + 
  theme_minimal()

p_rw_2 <- ggplot(
  data = df_rw_2,
  mapping = aes(
    x = Var1,
    y = value,
    group = Var2
  )
) + 
  geom_line(
    alpha = 0.4,
    color = "steelblue"
  ) + 
  labs(
    title = "Random walk",
    x = "time",
    y = "Value"
  ) + 
  theme_minimal()

grid.arrange(p_wn_2,p_rw_2)
