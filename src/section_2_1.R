# ---- 時系列データ ----
df_2 <- data.frame(
  data = 1:24
)

## ---- 時系列データに変換 ----
# ts(time series)を使う
ts_1 <- ts(
  data = df_2,
  start = c(2025, 1),
  frequency = 12
)

print(ts_1)

# ---- dataの読み込み ----
# library(here)をした後この記述方法でデータを取り出せる
birds <- read.csv(here("data", "raw", "2-1-1-birds.csv"))

print(birds)
head(birds, n = 3)
# crow = カラス, sparrow = スズメ


# ---- 乱数の生成 ----
## ---- N(0,1)に従う乱数を1つ取得
rnorm(
  n = 1,
  mean = 0,
  sd = 1
)

rnorm(
  n = 1,
  mean = 0,
  sd = 1
)

## ---- 乱数固定の方法 ----
# 固定した後の乱数生成は同じものが生成される
# 完全に同一の乱数を1つずつ生成するには
# 都度set.seedする必要がある
SEED <- 28
set.seed(SEED)
rnorm(
  n = 1,
  mean = 0,
  sd = 1
)
set.seed(SEED)
rnorm(
  n = 1,
  mean = 0,
  sd = 1
)

# ---- for文 ----
for (i in 1:3) {
  print(i)
}

result_vec_1 <- c(0, 0, 0) # 空箱
set.seed(SEED)
for (i in 1:3) {
  result_vec_1[i] <- rnorm(
    n = 1,
    mean = 0,
    sd = 1
  )
}

print(result_vec_1)

## --- mean vectorを用意してループさせる方法 ----
result_vec_2 <- c(0, 0, 0)
mean_vec <- c(0, 10, -5)
set.seed(SEED)
for (i in 1:3) {
  result_vec_2[i] <- rnorm(
    n = 1,
    mean = mean_vec[i],
    sd = 1
  )
}

print(result_vec_2)
