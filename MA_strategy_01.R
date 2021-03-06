#****************************************************
# Reference: http://www.systematicportfolio.com
# Evaluate and analyze Trading Strategies
#*****************************************************
rm(list=ls())
#
con = gzcon(url('http://www.systematicportfolio.com/sit.gz', 'rb'))
source(con)
close(con)

load.packages('quantmod')
# data is a time series of price
# signal is a indicator vector for buy and sell
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

# Test for bt.simple functions
# load historical prices from Yahoo Finance
data <- getSymbols('SPY', src = 'yahoo', from = '2000-01-01', to = '2018-12-31', auto.assign = F)
# buy and hold
signal <- rep(1, nrow(data))
buy.hold <- bt.simple(data, signal)
buy.hold$equity<-as.xts(buy.hold$equity)
head(buy.hold$equity)
tail(buy.hold$equity)
buy.hold$ret<-as.xts(buy.hold$ret)
head(buy.hold$ret)
# MA cross (moving average)
# Cl: get closing price
sma <- SMA(Cl(data), 200)
head(sma, 200)
#
signal <- ifelse(Cl(data) > sma, 1, 0) # if price large than moving mean, buy
head(signal, 201)
sma.cross <- bt.simple(data, signal)
# Create a chart showing the strategies perfromance in 2000:2009
dates <- '2000::2018'
buy.hold.equity <- buy.hold$equity[dates] / as.double(buy.hold$equity[dates][1])
sma.cross.equity <- sma.cross$equity[dates] / as.double(sma.cross$equity[dates][1])

# chartSeries() : Charting tool to create standard financial charts given a time series like object
chartSeries(buy.hold.equity, TA = c(addTA(sma.cross.equity, on=1, col='red')), 
            theme ='white', yrange = range(buy.hold.equity, sma.cross.equity) )
#
library(magrittr)
strategy.sma<-merge(buy.hold.equity, sma.cross.equity) %>% 
  set_colnames(c("BH", "SMA"))
head(strategy.sma,550)
tail(strategy.sma)
# plot using ggplot2 
library(ggplot2)
strategy.sma.df<-fortify(strategy.sma, melt=TRUE)
head(strategy.sma.df)
#
p<-ggplot(strategy.sma.df, aes(x = Index, y = Value))+
  geom_line(aes(color = Series), size = 0.5) +
  scale_x_date(date_labels = "%Y/%m") +
  geom_hline(yintercept = c(1.0, 0.6))
p

#===================================================================
# sample code to implement the above strategies using the backtesting 
# library in the Systematic Investor Toolbox:
#*****************************************************************
# Load historical data
#******************************************************************    
load.packages('quantmod')
tickers <- spl('SPY')

data <- new.env() # data is a environment

# bt.prep function merges and aligns all symbols in the data environment
getSymbols(tickers, src = 'yahoo', from = '2000-01-01', to = '2018-12-31', env = data, auto.assign = T)
bt.prep(data, align='keep.all')
names(data)
#prices<-Ad(data$SPY)
#data$prices<-prices
#data$weight<-prices * NA
#data$execution.price <- prices * NA
head(data$prices)
tail(data$prices)
#*****************************************************************
# Code Strategies
#*****************************************************************
# bt.run computes the equity curve of strategy specified by data$weight matrix. 
# The data$weight matrix holds weights (signals) to open/close positions
# Buy & Hold 
data$weight[] <- 1
buy.hold <- bt.run.share(data, clean.signal=F, trade.summary = TRUE)
buy.hold <- bt.run(data)
# MA Cross
# bt.apply function applies user given function to each symbol in the data environment
prices<-data$prices
sma <- bt.apply(data, function(x) { SMA(Cl(x), 200) } ) 
data$weight[] <- NA # update weights matirx
data$weight[] <- iif(prices >= sma, 1, 0)
sma.cross <- bt.run(data, trade.summary=T)   

plotbt.custom.report(sma.cross, buy.hold)
# strategy.performance.snapshoot(): 
models<-list("SMA"= sma.cross, "BH" = buy.hold)
strategy.performance.snapshoot(sma.cross, T) 
strategy.performance.snapshoot(buy.hold, T) 
strategy.performance.snapshoot(models, T)
strategy.performance.snapshoot(models, control=list(comparison=T), sort.performance=T)
#
plotbt.strategy.sidebyside(models, return.table=T)
#====================================================================================
# Example: using etf4 to compare their performance using 50-day and 200-day moving average investment strategy 
# https://systematicinvestor.wordpress.com/2014/08/01/adjusted-momentum/
#*************************************************************************************
con = gzcon(url('http://www.systematicportfolio.com/sit.gz', 'rb'))
source(con)
close(con)

load.packages('quantmod')

etf4.all<-readRDS("D:/gitest/gitest01/0408/etf4_xts_all")
head(etf4.all)
str(etf4.all)
etf4.all.1<-etf4.all[complete.cases(etf4.all),]
head(etf4.all.1)
tail(etf4.all.1)

# 0050
library(xts)
data1<-new.env()
data1$prices<-etf4.all.1$'0050'
prices<-data1$prices

sma50<-SMA(prices, 50)
head(sma50, 51)
# buy and hold for 0050
bt.prep(data1, align='keep.all')
names(data1)
data1$dates
data1$prices
data1$prices<-prices

class(data1$dates)
data1$execution.price = prices
data1$weight[] = 1
buy.hold.0050 <- bt.run.share(data1, clean.signal=F, trade.summary = TRUE)
buy.hold.0050 <-bt.run(data1)
# sma 200 for 0050
prices<-data1$prices
sma200<-SMA(prices, 200)
head(sma200, 201)
data1$weight[] <- iif(prices >= sma200, 1, 0)
sma200.0050 <- bt.run(data1, trade.summary=T)   
# sma 50 for 0050
sma50<-SMA(prices, 50)
head(sma50, 51)
data1$weight[] <- iif(prices >= sma50, 1, 0)
sma50.0050 <- bt.run(data1, trade.summary=T)
# sma 50 for 005, short allowed
data1$weight[] <- iif(prices >= sma50, 1, -1)
sma50.0050.short <- bt.run(data1, trade.summary=T)
# summary of investment
models<-list("SMA50"= sma50.0050, 
             "SMA200"= sma200.0050, 
             "SMA50_short" = sma50.0050.short, 
             "BH 0050" = buy.hold.0050)
strategy.performance.snapshoot(models, T)
strategy.performance.snapshoot(models, control=list(comparison=T), sort.performance=T)
plotbt.strategy.sidebyside(models, return.table=T)
# You can plot in ggplot2
library(ggplot2)
all.0050<-merge.xts(sma50.0050$equity, 
            sma50.0050.short$equity, 
            sma200.0050$equity, 
            buy.hold.0050$equity)
colnames(all.0050)<-c("sma50", "sma50 short", "sma200", "BH")
head(all.0050)
all.0050.long<-fortify(all.0050, melt=T)
head(all.0050.long)
#
title = "Cumulative returns of 0050s"
p = ggplot(all.0050.long, aes(x = Index, y = Value)) +
  geom_line(aes(linetype = Series, color = Series)) +
  #geom_point(aes(shape = Series))+
  xlab("year") + ylab("cumulative returns")+
  ggtitle(title)
p

#0056

library(xts)
data1<-new.env()
data1$prices<-etf4.all.1$'0056'
prices<-data1$prices

sma56<-SMA(prices, 50)
head(sma56, 51)

bt.prep(data1, align='keep.all')
names(data1)
data1$dates
data1$prices
data1$prices<-prices

class(data1$dates)
data1$execution.price = prices
data1$weight[] = 1
buy.hold.0056 <- bt.run.share(data1, clean.signal=F, trade.summary = TRUE)
buy.hold.0056 <-bt.run(data1)
# sma 200 for 0056
prices<-data1$prices
sma200_56<-SMA(prices, 200)
head(sma200_56, 201)
data1$weight[] <- iif(prices >= sma200_56, 1, 0)
sma200_56.0056 <- bt.run(data1, trade.summary=T)   
# sma 50 for 0056
sma56<-SMA(prices, 50)
head(sma56, 51)
data1$weight[] <- iif(prices >= sma56, 1, 0)
sma56.0056 <- bt.run(data1, trade.summary=T)
# sma 50 for 0056, short allowed
data1$weight[] <- iif(prices >= sma56, 1, -1)
sma56.0056.short <- bt.run(data1, trade.summary=T)
# summary of investment
models_1<-list("SMA56"= sma56.0056, 
             "sma200_56"= sma200_56.0056, 
             "SMA56_short" = sma56.0056.short, 
             "BH 0056" = buy.hold.0056)
strategy.performance.snapshoot(models_1, T)
strategy.performance.snapshoot(models_1, control=list(comparison=T), sort.performance=T)
plotbt.strategy.sidebyside(models_1, return.table=T)
# You can plot in ggplot2
library(ggplot2)
all.0056<-merge.xts(sma56.0056$equity, 
                    sma56.0056.short$equity, 
                    sma200_56.0056$equity, 
                    buy.hold.0056$equity)
colnames(all.0056)<-c("sma56", "sma56 short", "sma200_56", "BH")
head(all.0056)
all.0056.long<-fortify(all.0056, melt=T)
head(all.0056.long)
#
title = "Cumulative returns of 0056s"
p1 = ggplot(all.0056.long, aes(x = Index, y = Value)) +
  geom_line(aes(linetype = Series, color = Series)) +
  #geom_point(aes(shape = Series))+
  xlab("year") + ylab("cumulative returns")+
  ggtitle(title)
p1


#006205
library(xts)
data1<-new.env()
data1$prices<-etf4.all.1$'006205'
prices<-data1$prices

sma6205<-SMA(prices, 50)
head(sma6205, 51)

bt.prep(data1, align='keep.all')
names(data1)
data1$dates
data1$prices
data1$prices<-prices

class(data1$dates)
data1$execution.price = prices
data1$weight[] = 1
buy.hold.006205 <- bt.run.share(data1, clean.signal=F, trade.summary = TRUE)
buy.hold.006205 <-bt.run(data1)
# sma 200 for 006205
prices<-data1$prices
sma200_6205<-SMA(prices, 200)
head(sma200_6205, 201)
data1$weight[] <- iif(prices >= sma200_6205, 1, 0)
sma200_6205.006205 <- bt.run(data1, trade.summary=T)   
# sma 50 for 6205
sma6205<-SMA(prices, 50)
head(sma6205, 51)
data1$weight[] <- iif(prices >= sma6205, 1, 0)
sma6205.006205 <- bt.run(data1, trade.summary=T)
# sma 50 for 6205, short allowed
data1$weight[] <- iif(prices >= sma6205, 1, -1)
sma6205.006205.short <- bt.run(data1, trade.summary=T)
# summary of investment
models_2<-list("SMA6205"= sma6205.006205, 
               "sma200_6205"= sma200_6205.006205, 
               "SMA6205_short" = sma6205.006205.short, 
               "BH 006205" = buy.hold.006205)
strategy.performance.snapshoot(models_2, T)
strategy.performance.snapshoot(models_2, control=list(comparison=T), sort.performance=T)
plotbt.strategy.sidebyside(models_2, return.table=T)
# You can plot in ggplot2
library(ggplot2)
all.006205<-merge.xts(sma6205.006205$equity, 
                      sma6205.006205.short$equity, 
                      sma200_6205.006205, 
                      buy.hold.006205$equity)
colnames(all.006205)<-c("sma6205", "sma6205 short", "sma200_6205", "BH")
head(all.006205)
all.0056.long<-fortify(all.006205, melt=T)
head(all.006205.long)
#
title = "Cumulative returns of 006205s"
p2 = ggplot(all.006205.long, aes(x = Index, y = Value)) +
  geom_line(aes(linetype = Series, color = Series)) +
  #geom_point(aes(shape = Series))+
  xlab("year") + ylab("cumulative returns")+
  ggtitle(title)
p2

#00646

library(xts)
data1<-new.env()
data1$prices<-etf4.all.1$'00646'
prices<-data1$prices

sma646<-SMA(prices, 50)
head(sma646, 51)

bt.prep(data1, align='keep.all')
names(data1)
data1$dates
data1$prices
data1$prices<-prices

class(data1$dates)
data1$execution.price = prices
data1$weight[] = 1
buy.hold.00646 <- bt.run.share(data1, clean.signal=F, trade.summary = TRUE)
buy.hold.00646 <-bt.run(data1)

prices<-data1$prices
sma200_646<-SMA(prices, 200)
head(sma200_646, 201)
data1$weight[] <- iif(prices >= sma200_646, 1, 0)
sma200_646.00646 <- bt.run(data1, trade.summary=T) 

sma646<-SMA(prices, 50)
head(sma646, 51)
data1$weight[] <- iif(prices >= sma646, 1, 0)
sma646.00646 <- bt.run(data1, trade.summary=T)

data1$weight[] <- iif(prices >= sma646, 1, -1)
sma646.00646.short <- bt.run(data1, trade.summary=T)


models_3<-list("SMA646"= sma646.00646, 
               "sma200_646"= sma200_646.00646, 
               "SMA646_short" = sma646.00646.short, 
               "BH 00646" = buy.hold.00646)
strategy.performance.snapshoot(models_3, T)
strategy.performance.snapshoot(models_3, control=list(comparison=T), sort.performance=T)
plotbt.strategy.sidebyside(models_3, return.table=T)


library(ggplot2)
all.00646<-merge.xts(sma646.00646$equity, 
                     sma646.00646.short$equity, 
                     sma200_646.00646$equity, 
                     buy.hold.00646$equity)
colnames(all.00646)<-c("sma646", "sma646 short", "sma200_646", "BH")
head(all.00646)
all.00646.long<-fortify(all.00646, melt=T)
head(all.00646.long)


title = "Cumulative returns of 00646s"
p3 = ggplot(all.00646.long, aes(x = Index, y = Value)) +
  geom_line(aes(linetype = Series, color = Series)) +
  #geom_point(aes(shape = Series))+
  xlab("year") + ylab("cumulative returns")+
  ggtitle(title)
p3

#------

