
install.packages("fredr")
devtools::install_github("KevinKotze/tsm")
install.packages("mFilter", repos = "https://cran.rstudio.com/", 
                 dependencies = TRUE)
install.packages("remotes")
remotes::install_github("KevinKotze/tsm")
install.packages("tsm")

library(tsm)
library(mFilter)

library(fredr)
library(ggplot2)

fredr_set_key("8dfc8ace522963be92c46133b6da50a8")


rm(list = ls())
graphics.off()



# How to use http://www.supplychaindataanalytics.com/188-2/

#search_ls <- fredr_series_search_text("gdp")
#colnames(search_ls)
series_ls <-fredr_series_observations(series_id = "A191RL1Q225SBEA") 
series_df <- do.call(cbind.data.frame, series_ls)

# plotting data
ggplot(series_df) + geom_line(mapping = aes(x=date,y=value), 
                              color = "red") +
  ggtitle("GDP seasonally adjusted - FRED") + 
  xlab("years") + 
  ylab("GDP")

## Beverige Decomposition https://kevinkotze.github.io/ts-5-tut/
## https://rdrr.io/github/KevinKotze/tsm/
gdp <- ts(series_df, start = c(1947, 1), frequency = 4)
lin.mod <- lm(gdp ~ time(gdp))
lin.trend <- lin.mod$fitted.values  # fitted values pertain to time trend
linear <- ts(lin.trend, start = c(1947, 11), frequency = 4)  # create a time series variable for trend
lin.cycle <- gdp - linear  # cycle is the difference between the data and linear trend

bn.decomp <- bnd(gdp, nlag = 2)  # apply the BN decomposition that creates dataframe

bn.trend <- ts(bn.decomp[, 1], start = c(1947, 1), frequency = 4)  # first column contains trend
bn.cycle <- ts(bn.decomp[, 2], start = c(1947, 1), frequency = 4)  # second column contains cycle

par(mfrow = c(1, 2), mar = c(2.2, 2.2, 1, 1), cex = 0.8) # plot two graphs side by side and squash margins

plot.ts(gdp, ylab = "") # first plot time series

lines(bn.trend, col = "red")  # include lines over the plot

legend("topleft", legend = c("data", "BNtrend"), lty = 1, 
       col = c("black", "red"), bty = "n")
plot.ts(bn.cycle, ylab = "")  # second plot for cycle

legend("topleft", legend = c("BNcycle"), lty = 1, col = c("black"), 
       bty = "n")
