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
  int N;  //  sample size
  vector[N] animal_num;  // data
}


parameters {
  real<lower=0> mu;  // average
  real<lower=0> sigma;  // standard deviation
}


model {
  // normal distribution
  // N(mu, sigma)
  animal_num ~ normal(mu, sigma);
}

generated quantities {
  // posterior distribution
  // N(mu, sigma)
  vector[N] pred;
  for (i in 1:N) {
    pred[i] = normal_rng(mu, sigma);
  }
}

