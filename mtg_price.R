####
## Practice setting up a complete forecasting workflow
## For now using MTG pricing as an example
####

needed_packages <- c("dplyr", "ggplot2", "rstan")

lapply(needed_packages, require, character.only = TRUE)

source("ggplot_theme.R")

extract_price <- function(x) {
split1 <- strsplit(x, split = "n")[[1]][2]
split2 <- strsplit(split1, split = ", ")[[1]]
}

## Load pricing data
pd <- read.csv("pd.txt", header=FALSE, sep=";")[, 1]

## date
price.out <- apply(as.matrix(pd), 1, extract_price)
price.out <- data.frame(date = price.out[1, ], price = price.out[2, ])

price.out$date <- as.Date(price.out$date)
price.out$price <- as.numeric(price.out$price)

num_forecast <- 200

## Very simple random walk
stan.data <- with(
  price.out
, list(
  y      = log(price.out$price)
, N      = nrow(price.out)
, x_ic   = 20
, tau_ic = 20
, a_obs  = 1, r_obs = 1     ## obs error prior
, a_add  = 1, r_add = 1     ## process error prior
## Forecast
, N_f    = num_forecast

)
)

stan.fit <- stan(
  file    = "mtg_price.stan"
, data    = stan.data
, chains  = 1
, cores   = 1
, iter    = 3000
, warmup  = 500
, thin    = 1
)

stan.fit.summary      <- summary(stan.fit)[[1]]

stan.fit.summary.pred <- as.data.frame(stan.fit.summary[
   grep("y_f_o", dimnames(summary(stan.fit)[[1]])[[1]])
  , c(4:8)])[, c(1, 3, 5)]

names(stan.fit.summary.pred) <- c("lwr", "mid", "upr")
stan.fit.summary.pred <- stan.fit.summary.pred %>% mutate(
  date = max(price.out$date) + seq(1, num_forecast)
)

gg1 <- ggplot(price.out) + 
  geom_line(aes(date, price)) + 
  xlab("Date") + ylab("Price (USD)") + ggtitle("Polluted Delta (Onslaught)") +
  geom_ribbon(data = stan.fit.summary.pred
    , aes(date, ymin = lwr, ymax = upr)
    , alpha = 0.25
    , fill = "dodgerblue1") +
  geom_line(data = stan.fit.summary.pred, aes(date, mid), colour = "dodgerblue4") 
  
ggsave("mtg_price.pdf", width = 6, height = 4)
