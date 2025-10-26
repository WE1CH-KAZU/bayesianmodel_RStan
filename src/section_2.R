1 + 1
3 - 1
3 * 4
8 / 6
2^10

# 変数
x <- 2
x + 1
print(x)

# 関数
sqrt(4)

# vector
vector_1 <- c(1, 2, 3, 4, 5)
vector_1
vector_2 <- c(1:10)
vector_2

# matrix
matrix_1 <- matrix(
  data = 1:10, # data
  nrow = 2, # 行数
  byrow = TRUE, # 行の順番でデータを格納？
  dimnames = NULL
)
matrix_1
matrix_2 <- matrix(
  data = 1:10, # data
  nrow = 2, # 行数
  byrow = FALSE, # 行の順番でデータを格納？
  dimnames = NULL
)
matrix_2

# matrixにindexを与える
rownames(matrix_1) <- c("ROW1", "ROW2")
colnames(matrix_1) <- c("col1", "col2", "col3", "col4", "col5")
print(matrix_1)


# array(配列)
# arrayのいいところは、3次元以上にも対応した形式
arr_1 <- array(
  data = 1:10,
  dim = c(3, 5, 2) # 3行5列が2つ
)
arr_1
# この記述だと数が足りなくなると最初にループする仕様になっている点を注意する事


# data.frame
# pythonだと最後のカンマがあっても受け入れるがRのほうが厳密性が高いので
# 最後のcol2の行にカンマがあるとエラーが出る
df <- data.frame(
  col1 = c("A", "B", "C", "D", "E"),
  col2 = c(1, 2, 3, 4, 5)
)

print(df)
nrow(df)
ncol(df)


# list
# 別々の型を同じリストに入れることができる
# 辞書かjsonの記述方法に近い
list_1 <- list(
  chara = c("A", "B", "C"),
  matrix = matrix_1,
  df = df
)

print(list_1)


# dataの抽出
# vectorだと1次元で指定
vector_1[1]

# arrayだとその次元数で指定
arr_1[1, 1, 1] # row,col,dim

# matrixも同様
matrix_1[2, 2] # row,col

# matrixの行全体
matrix_2[1, ]

# matrixの指定範囲
matrix_1[1, 2:4]

# 要素数を調べる
# pythonのshapeと同じ
dim(matrix_1)

# index, colnameも出せる
dimnames(matrix_1)

dim(list_1) # listは無理

# data.frameの場合
# ドル記号$ を使って抽出も可能
df$col2
df$col2[2]


# data.frameの場合
# pythonのhead(2)が可能
head(df, n = 3)


# listの場合
# ドル記号$が使える
list_1$chara

list_1[[1]]
