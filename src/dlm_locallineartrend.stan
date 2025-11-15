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
  vector[T] delta;  // ドリフト成分の推定値
  real<lower=0> sigma_w;  // 水準成分の標準偏差
  real<lower=0> sigma_v;  // 観測方程式の標準偏差
  real<lower=0> sigma_z;  // ドリフト成分の標準偏差
}

model {
  // 弱情報事前分布
  sigma_w ~ normal(2,2);
  sigma_v ~ normal(0.5,0.5);
  sigma_z ~ normal(10,5);
  
  // 状態方程式に従って、推定値muが遷移する
  for (i in 2:T) {
    mu[i] ~ normal(mu[i-1] + delta[i-1], sigma_w);
    delta[i] ~ normal(delta[i-1], sigma_z);
  }
  
  // 観測方程式に従って、観測値yが得られる
  for (i in 1:T) {
    y[i] ~ normal(mu[i], sigma_v);
  }
}

