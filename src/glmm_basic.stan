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
  int fish_num[N];  // 獲得魚数
  vector[N] sunny;  // 晴れダミー数
  vector[N] temp;  // 気温
}


parameters {
  real Intercept;  // 切片
  real b_temp;  // 気温係数
  real b_sunny;  // 晴れの場合の係数
  vector[N] r;  // ランダム効果の平均
  real<lower=0> sigma_r;  // ランダム効果の標準偏差
}

transformed parameters {
  vector[N] lambda = Intercept + b_sunny*sunny + b_temp*temp + r;
}

model {
  r ~ normal(0, sigma_r);
  fish_num ~ poisson_log(lambda);
}

