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
  int N;  // n_size
  int K;  // デザイン行列の列数（説明変数の数＋１）
  vector[N] Y;  // 応答変数
  matrix[N, K] X;  // デザイン行列の行と列
}

parameters {
  vector[K] b;  // 切片を含む係数ベクトル
  real<lower=0> sigma;  // 標準偏差
}

model {
  vector[N] mu = X * b;
  Y ~ normal(mu, sigma);
}

