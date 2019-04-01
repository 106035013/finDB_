rm(list=ls())
#
etf4.all <- readRDS("etf4_xts_all")
head(etf4.all)
etf4.all.1 <- etf4.all[complete.cases(etf4.all), ]
head(etf4.all.1)
tail(etf4.all.1)

RDS = (etf4.all.1)


bt.simple <- function(data, signal)
{
  # lag serial
  signal <- lag(signal,1)
  # back fill
  signal <- na.locf(signal, na.rm = FALSE)
  signal[is.na(signal)] = 0
  # calculate close-to-close returns
  # ROC() : Calculate the (rate of) change of a series over n periods.
  ret <- ROC(Cl(data), type="discrete")
  ret[1] = 0
  # compute stats
  bt <- list()
  bt$ret <- ret * signal 
  bt$equity <- cumprod(1 + bt$ret)
  return(bt)
}

#
data <- getSymbols('etf4.all.1', from = '2015-12-14', to = '2018-12-28', auto.assign = T)
#
signal <- rep(1, nrow(data))
buy.hold <- bt.simple(data, signal)
buy.hold$equity<-as.xts(buy.hold$equity)
head(buy.hold$equity)
tail(buy.hold$equity)
buy.hold$ret<-as.xts(buy.hold$ret)
head(buy.hold$ret)
