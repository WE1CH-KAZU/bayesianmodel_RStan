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
  int N;  // サンプルサイズ
  vector[N] sales;  //データ
}

parameters {
  real mu;  // 平均
  real<lower=0> sigma;  // 標準偏差
}

model {
  // 平均mu 標準偏差sigmaの正規分布に従うデータと仮定
  for (i in 1:N) {
    sales[i] ~ normal(mu, sigma);
  }
}
// 明示的に最後の空行を付ける必要がある