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

// The input data is a vector 'y' of length 'N'.
data {
  int N;  // sample size
  vector[N] sales;  // sales
  vector[N] temperature;  // temperature
  
  int N_pred;
  vector[N_pred] temperature_pred;
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  real intercept;
  real beta;
  real<lower=0> sigma;
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  sales ~ normal(intercept + beta*temperature, sigma);
}

generated quantities {
  // temperature_predに沿ってsales_predを推定する
  // 推定時の期待値も出したいのでmu_predを用意する
  vector[N_pred] mu_pred;
  vector[N_pred] sales_pred;
  
  for (i in 1:N_pred) {
    mu_pred[i] = intercept + beta*temperature_pred[i];
    sales_pred[i] = normal_rng(mu_pred[i], sigma);
  }
}

