# ---- load ----
library(rstan)
library(here)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# ---- import data ----
sales <- read.csv(here("data", "raw", "2-4-1-beer-sales-1.csv"))
ssize <- nrow(sales)
d_list <- list(
  sales = sales$sales,
  N = ssize
)

# ---- MCMC ----
SEED <- 28
mcmc_result <- stan(
  file = "src/section3_calc-normal-mean-variance.stan",
  model_name = "model",
  data = d_list,
  seed = SEED,
  chains = 4,
  iter = 2000,
  warmup = 1000,
  thin = 1
)


# ---- results ----
print(
  mcmc_result
)

traceplot(
  mcmc_result
)


# ---- extraction ----
mcmc_samples <- rstan::extract(
  mcmc_result,
  permuted = FALSE
)

class(mcmc_samples)
dim(mcmc_samples) # iteration, chains, parameter-number
dimnames(mcmc_samples) # more detail dimension

# 1回目のチェーンで得た、最初の平均サンプル
mcmc_samples[1, "chain:1", "mu"]


# ---- general statistic data ----
mu_mcmc_vec <- as.vector(
  mcmc_samples[, , "mu"]
)

# こうする事で様々な統計量を取得できる
median(mu_mcmc_vec)
mean(mu_mcmc_vec)
max(mu_mcmc_vec)
min(mu_mcmc_vec)
var(mu_mcmc_vec)
quantile(mu_mcmc_vec, probs = c(0.025, 0.975))


# ---- trace plot ----
library(ggfortify)

autoplot(
  ts(mcmc_samples[, , "mu"]),
  facets = F, # chains = 4 を全部まとめて1つのグラフにする
  ylab = "mu",
  main = "Trace plot"
)


# ---- ggplot2による事後分布の可視化 ----
mu_df <- data.frame(
  mu_mcmc_sample = mu_mcmc_vec
)

ggplot(
  data = mu_df,
  mapping = aes(mu_mcmc_sample)
) +
  geom_density(
    linewidth = 0.5
  )


# ---- もっと簡単に記述する方法 ----
library(bayesplot)

# histgram
mcmc_hist(
  mcmc_samples,
  pars = c("mu", "sigma")
)

# kernel density
mcmc_dens(
  mcmc_samples,
  pars = c("mu", "sigma")
)

# trace plot
mcmc_trace(
  mcmc_samples,
  pars = c("mu", "sigma")
)

# trace and kernel density
mcmc_combo(
  mcmc_samples,
  pars = c("mu", "sigma")
)


# ---- この可視化が一番おすすめ ----

# “blue”, “brightblue”, “darkgray”, “gray”, “green”, “orange”, “pink”, “purple”,
# “red”, “teal”, “yellow”, “viridis”, “viridisA”, “viridisB”, “viridisC”,
# “viridisD”, “viridisE”

color_scheme_set(scheme = "viridisA")
mcmc_dens_overlay(
  mcmc_samples,
  pars = c("mu", "sigma")
)
