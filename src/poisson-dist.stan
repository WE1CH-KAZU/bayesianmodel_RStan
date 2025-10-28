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
  int animal_num[N];  // data
}


parameters {
  real<lower=0> lambda;  // intensity
}


model {
  // poisson distribution
  // Po(lambda)
  animal_num ~ poisson(lambda);
}

generated quantities {
  // posterior distribution
  // Po(lambda)
  int pred[N];
  for (i in 1:N) {
    pred[i] = poisson_rng(lambda);
  }
}

