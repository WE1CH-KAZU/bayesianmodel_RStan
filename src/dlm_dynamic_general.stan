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
  vector[T] ex;  // 説明変数
  vector[T] y;  // 観測値
}


parameters {
  vector[T] mu;  // 水準成分の推定値μ
  vector[T] b;  // 時変係数の推定値β
  real<lower=0> sigma_w;  // 水準成分の標準偏差w
  real<lower=0> sigma_tau;  // 時変係数の標準偏差tau
  real<lower=0> sigma_v;  // 観測値の標準偏差v
}

transformed parameters {
  // 状態推定値の算出
  vector[T] alpha;
  for (i in 1:T) {
    alpha[i] = mu[i] + b[i] * ex[i];
  }
}


model {
  // 状態方程式に従って状態が推移するモデル
  for (i in 2:T) {
    mu[i] ~ normal(mu[i-1], sigma_w);  // mu_t = mu_t-1 + w_t, w_t ~ Normal(0, sigma^2_w)
    b[i] ~ normal(b[i-1], sigma_tau);  // β_t = β_t-1 + tau_t, tau_t ~ Normal(0, σ^2_tau)
  }
  // 観測方程式に従い観測値を得る
  for (i in 1:T) {
    y[i] ~ normal(alpha[i], sigma_v);
  }
}

