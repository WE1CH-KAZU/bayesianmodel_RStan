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
  int T;
  vector[T] y;
}

parameters {
  real<lower=0> sigma_w;
  real b_ar;
  real Intercept;
}

model {
  for (i in 2:T) {
    y[i] ~ normal(Intercept + b_ar * y[i-1], sigma_w);
  }
}

