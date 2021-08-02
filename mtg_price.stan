data {

  int<lower=0> N;                    // number of observations
  real y[N];                         // price
  real x_ic;                         // initial condition prior
  real tau_ic;                       // initial condition prior

  real a_obs;                        // variance prior
  real r_obs;                        // variance prior
  real a_add;                        // variance prior
  real r_add;                        // variance prior

  int<lower=0> N_f;
  
}

parameters {

  real<lower=0> tau_obs;             // obs error
  real<lower=0> tau_add;             // random walk error    
  real x[N];                         // latent state of the system

}

model {

// priors
  x[1] ~ normal(x_ic,tau_ic);
  tau_obs ~ gamma(a_obs,r_obs);
  tau_add ~ gamma(a_add,r_add);

// Data Model
  for(i in 1:N) {
    y[i] ~ normal(x[i],tau_obs);
  }
  
// Process Model
  for(i in 2:N) {
    x[i] ~ normal(x[i-1],tau_add);
  }

}

generated quantities {

  real y_f[N_f];                // price forecast
  real x_f[N_f];                // forecast latent state
 
  real y_f_o[N_f];

  x_f[1] = normal_rng(x[N],tau_add);
  y_f[1] = normal_rng(x_f[1], tau_obs);

// Process Model
  for(i in 2:N_f) {
   x_f[i] = normal_rng(x_f[i-1],tau_add);
  }

// Data Model
  for(i in 2:N_f) {
   y_f[i] = normal_rng(x_f[i],tau_obs);
  }

  y_f_o = exp(y_f);

}

