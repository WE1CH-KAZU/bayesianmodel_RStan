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


// 2次のトレンド（平滑化トレンドモデル）を採用した
// 基本構造時系列モデル
// basic structual time series

data {
  int T;  // データの長さ
  vector[T] y;  // 観測値
}

parameters {
  vector[T] mu;  // 水準＋ドリフト成分の推定値
  vector[T] gamma;  // ドリフト成分の推定値
  real<lower=0> sigma_w;  // 季節成分の標準偏差
  real<lower=0> sigma_v;  // 観測方程式の標準偏差
  real<lower=0> sigma_z;  // ドリフト成分の標準偏差
}

transformed parameters {
  // mcmcで生成したサンプルから観測値を推定するαを合成する
  vector[T] alpha;
  for (i in 1:T) {
    alpha[i] = mu[i] + gamma[i];
  }
}


model {
  // 水準＋ドリフト
  for (i in 3:T) {
    mu[i] ~ normal(2 * mu[i-1] - mu[i-2], sigma_z);
  }
  // 季節成分
  // ACF(自己相関)の確認の結果lag=7でピークが起きているから
  for ( i in 7:T) {
    // 周期成分の総和がゼロになるというモデルで
    // i=1~7までの和がnormal(0,σ^2_s)に従うとおけば
    // i=7は、i=1~6までの和から引いたものになる
    gamma[i] ~ normal(-sum(gamma[(i-6):(i-1)]), sigma_w); 
  }
  // 観測方程式
  for (i in 1:T) {
    y[i] ~ normal(alpha[i], sigma_v);
  }
}

