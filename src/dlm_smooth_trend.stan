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
  int T;  // データの長さ
  vector[T] y;  // 観測値
}

parameters {
  vector[T] mu;  // 水準＋ドリフト成分の推定値
  real<lower=0> sigma_w;  // 状態方程式（平滑化モデル）の標準誤差
  real<lower=0> sigma_v;  // 観測方程式の標準誤差
}

model {
  // 状態方程式に従って、推定値muが遷移する
  for (i in 3:T) {
    mu[i] ~ normal(2*mu[i-1] - mu[i-2], sigma_w);
  }
  
  // 観測方程式に従って、観測値yが得られる
  for (i in 1:T) {
    y[i] ~ normal(mu[i], sigma_v);
  }
}

