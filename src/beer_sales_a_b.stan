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
  int N;
  vector[N] sales_a;
  vector[N] sales_b;
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  // for beer_a
  real mu_a;
  real<lower=0> sigma_a;
  // for beer_b
  real mu_b;
  real<lower=0> sigma_b;
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  // for beer_a
  sales_a ~ normal(mu_a, sigma_a);
  // for beer_b
  sales_b ~ normal(mu_b, sigma_b);
}

generated quantities {
  // diff a-b
  real diff;
  diff = mu_a - mu_b;
}

