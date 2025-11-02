# ---- 平均の差の評価 / generated quantities ----

# ---- library ----
library(rstan)
library(here)
library(ggplot2)

options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)


# ---- import data ----
beer_sales_ab <- read.csv(
  here("data", "raw", "2-6-1-beer-sales-ab.csv")
)

# ---- visualization ----
ggplot(
  data = beer_sales_ab,
  mapping = aes(
    x = sales,
    y = after_stat(density), # ..density..
    colour = beer_name,
    fill = beer_name
  )
) +
  geom_histogram(
    alpha = 0.5,
    position = "identity"
  ) +
  geom_density(
    alpha = 0.5,
    size = NA,
    adjust = 1.5
  )


# ---- data reformat ----
sales_a <- beer_sales_ab$sales[1:100]
sales_b <- beer_sales_ab$sales[101:200]

# to list
d_list <- list(
  sales_a = sales_a,
  sales_b = sales_b,
  N = 100
)


# ---- mcmc ----
file_name <- here("src", "beer_sales_a_b.stan")
mcmc_result <- stan(
  file = file_name,
  data = d_list,
  seed = 28
)

print(
  mcmc_result,
  probs = c(0.03, 0.5, 0.97)
)
