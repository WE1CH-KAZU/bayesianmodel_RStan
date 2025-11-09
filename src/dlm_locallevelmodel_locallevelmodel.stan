//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//


data {
  int T; // データの観測時間の長さ
  vector[T] y;  // 観測値
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
  for (i in 1:T) {
    y[i] ~ normal(mu[i], sigma_v);
  }
}

