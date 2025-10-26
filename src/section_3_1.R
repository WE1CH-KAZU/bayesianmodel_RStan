# ---- ライブラリのロード ----
library(ggplot2)
library(here)
library(gridExtra)


# ---- import data
fish <- read.csv(here("data", "raw", "2-2-1-fish.csv"))
head(fish, n = 3)


# ---- ヒストグラムとカーネル密度推定 ----
ggplot(
  data = fish,
  mapping = aes(x = length)
) + # ここまでがggplotのデータの指定
  geom_histogram(
    alpha = 0.5,
    bins = 20
  ) + # ここまでが可視化方法の指定
  labs(
    title = "histgram of fish data" # 脚色
  )

ggplot(
  fish,
  aes(length)
) +
  geom_density(
    linewidth = 0.5
  ) +
  labs(
    title = "kernel density of fish data"
  )


## ---- グラフの重ね合わせ ----
# グラフの重ね合わせは"+"を使って重ねていく
ggplot(
  fish,
  aes(x = length, y = after_stat(density)) # ここに重ねたい情報を追記しておく
) +
  geom_histogram(
    alpha = 0.6,
    bins = 20
  ) +
  geom_density(
    linewidth = 0.5
  ) +
  labs(
    title = "duplicated graph viewing"
  )


## ---- グラフの行列可視化 ----
# gridExtraを使うのがよい

p_hist <- ggplot(
  data = fish,
  mapping = aes(x = length)
) +
  geom_histogram(
    alpha = 0.5,
    bins = 20
  ) +
  labs(
    title = "histgram"
  )

p_density <- ggplot(
  fish,
  aes(length)
) +
  geom_density(
    linewidth = 0.5
  ) +
  labs(
    title = "kernel density"
  )

# girdExtraで並列描画
grid.arrange(
  p_hist,
  p_density,
  ncol = 2
)


# ---- 箱ひげ図とバイオリンプロット ----
# dataはRに最初から入っているiris data を使う
dim(iris)
dimnames(iris)
head(iris, n = 3)

# 花弁の長さをSpecies毎に箱ひげ図で描画する
p_boxplot <- ggplot(
  iris,
  aes(x = Species, y = Petal.Length)
) +
  geom_boxplot() +
  labs(
    title = "iris dataの種別の花弁長さ箱ひげ図"
  )

p_boxplot


p_violin <- ggplot(
  iris,
  aes(Species, Petal.Length)
) +
  geom_violin() +
  labs(
    title = "iris dataの種別の花弁長さバイオリン図"
  )

# grid.Extraで描画
grid.arrange(
  p_boxplot,
  p_violin,
  ncol = 2
)


# ---- 散布図 ----
ggplot(
  iris,
  aes(Petal.Width,
    Petal.Length,
    colour = Species
  )
) +
  geom_point() +
  labs(
    title = "scatter plot of iris data"
  )


# ---- line図（折れ線グラフ）----
# 時系列データを描画する
# Nileデータをdata.frame構造に変換する
Nile

nile_df <- data.frame(
  year = 1871:1970,
  Nile = as.numeric(Nile) # 連続値でNileの情報をNile引数に渡す
)

head(nile_df)

# line plot using ggplot
ggplot(
  nile_df,
  aes(year, Nile)
) +
  geom_line() +
  labs(
    title = "line plot of Nile data"
  )

## ---- もっと簡単な時系列データ可視化方法 ----
# ggfortifyパッケージを使う

library(ggfortify)

autoplot(Nile)
