// len_obsはNAを除いた長さ
// obs_noはNAを飛ばした行番号（1,2,4,...)

data {
  int T; // データの観測時間の長さ
  int len_obs;  // 観測値数の長さ
  vector[len_obs] y;  // 観測値 
  int obs_no[len_obs];  // 観測値が得られた時点
}

parameters {
  vector[T] mu;  // 状態方程式の推定値（水準成分）
  real<lower=0> sigma_w;  // 過程誤差の標準偏差
  real<lower=0> sigma_v;  // 観測誤差の標準偏差
}

model {
  // 状態方程式
  // i=1を指定していない点に注意
  // ここでは無情報事前分布を想定して事後分布を得る方針とする。
  for (i in 2:T) {
    mu[i] ~ normal(mu[i-1], sigma_w);
  }
  
  // 観測方程式
  // 観測値が得られた時点のみ実行する
  for (i in 1:len_obs) {
    y[i] ~ normal(mu[obs_no[i]], sigma_v);
  }
}

