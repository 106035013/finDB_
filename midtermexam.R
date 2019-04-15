rm(list=ls())

#1.台灣二十檔大型股票代號及名稱。

ifelse(!require(quantmod), install.packages('quantmod'), library(quantmod))
tw20_adj_close<-read.csv("2018Q4_20.csv")
head(tw20_adj_close, 20)

#2.從TEJ資料庫下載「除權調整後日收盤價」，將檔案輸出並儲存為tw20.txt。

ifelse(!require(readr), install.packages('readr'), library(readr))
tw20.txt<-read.table("tw20.txt", header = T)
head(tw20.txt, 50)

#3.利用「dcast函數」將tw20.txt轉換成xts格式，並命名為tw20.xts。

ifelse(!require(reshape2), install.packages('reshape2'), library(reshape2))
colnames(tw20.txt)<-c("id","", "date", "price")
tw20.xts = dcast(tw20.txt, date~id)
head(tw20.xts, 50)
#
tw20.xts$date<-as.Date(as.character(tw20.xts$date), "%Y%m%d") 
library(xts)
tw20.xts.1<-xts(tw20.xts[,-1], order.by = tw20.xts$date)
saveRDS(tw20.xts.1, "tw20_xts_all")

#4.計算每日、月報酬率，並將資料輸出為tw20.day.ret, tw20.mon.ret.

ifelse(!require(PerformanceAnalytics), install.packages('PerformanceAnalytics'), library(PerformanceAnalytics))
ifelse(!require(magrittr), install.packages('magrittr'), library(magrittr))
tw20.day.ret <-Return.calculate(tw20.xts.1, method = "log")
head(tw20.day.ret)

ifelse(!require(quantmod), install.packages('quantmod'), library(quantmod))
tw20.mon.ret <- to.monthly(tw20.xts.1, indexAt = "lastof", OHLC=FALSE)
head(tw20.mon.ret)

#6.依90天移動平均操作策略，比較前三檔股票之操作績效。

con = gzcon(url('http://www.systematicportfolio.com/sit.gz', 'rb'))
source(con)
close(con)

load.packages('quantmod')

tw20.all<-readRDS("D:/gittest/01/0415/tw20_xts_all")
head(tw20.all)
tw20.all.1<-tw20.all[complete.cases(tw20.all),]
head(tw20.all.1)

#1101-----
library(xts)
data1<-new.env()
data1$prices<-tw20.all.1$'1101'
prices<-data1$prices
sma1101<-SMA(prices, 90)
head(sma1101, 91)

bt.prep(data1, align='keep.all')
names(data1)
data1$dates
data1$prices
data1$prices<-prices

class(data1$dates)
data1$execution.price = prices
data1$weight[] = 1
buy.hold.1101 <- bt.run.share(data1, clean.signal=F, trade.summary = TRUE)
buy.hold.1101 <-bt.run(data1)

sma1101<-SMA(prices, 90)
head(sma1101, 91)
data1$weight[] <- iif(prices >= sma1101, 1, 0)
sma90.1101 <- bt.run(data1, trade.summary=T)

data1$weight[] <- iif(prices >= sma1101, 1, -1)
sma90.1101.short <- bt.run(data1, trade.summary=T)

models<-list("SMA1101"= sma90.1101, 
             "SMA1101_short" = sma90.1101.short, 
             "BH 1101" = buy.hold.1101)
strategy.performance.snapshoot(models, T)
strategy.performance.snapshoot(models, control=list(comparison=T), sort.performance=T)
plotbt.strategy.sidebyside(models, return.table=T)

ifelse(!require(ggplot2), install.packages('ggplot2'), library(ggplot2))
all.1101<-merge.xts(sma90.1101$equity, 
                    sma90.1101.short$equity, 
                    buy.hold.1101$equity)
colnames(all.1101)<-c("sma1101", "sma1101 short", "BH")
head(all.1101)
all.1101.long<-fortify(all.1101, melt=T)
head(all.1101.long)

title = "Cumulative returns of 1101s"
p = ggplot(all.1101.long, aes(x = Index, y = Value)) +
  geom_line(aes(linetype = Series, color = Series)) +
  #geom_point(aes(shape = Series))+
  xlab("year") + ylab("cumulative returns")+
  ggtitle(title)
p

#1216----
library(xts)
data1<-new.env()
data1$prices<-tw20.all.1$'1216'
prices<-data1$prices
sma1216<-SMA(prices, 90)
head(sma1216, 91)

bt.prep(data1, align='keep.all')
names(data1)
data1$dates
data1$prices
data1$prices<-prices

class(data1$dates)
data1$execution.price = prices
data1$weight[] = 1
buy.hold.1216 <- bt.run.share(data1, clean.signal=F, trade.summary = TRUE)
buy.hold.1216 <-bt.run(data1)

sma1216<-SMA(prices, 90)
head(sma1216, 91)
data1$weight[] <- iif(prices >= sma1216, 1, 0)
sma90.1216 <- bt.run(data1, trade.summary=T)

data1$weight[] <- iif(prices >= sma1216, 1, -1)
sma90.1216.short <- bt.run(data1, trade.summary=T)

models.1<-list("SMA1216"= sma90.1216, 
             "SMA1216_short" = sma90.1216.short, 
             "BH 1216" = buy.hold.1216)
strategy.performance.snapshoot(models.1, T)
strategy.performance.snapshoot(models.1, control=list(comparison=T), sort.performance=T)
plotbt.strategy.sidebyside(models.1, return.table=T)

ifelse(!require(ggplot2), install.packages('ggplot2'), library(ggplot2))
all.1216<-merge.xts(sma90.1216$equity, 
                    sma90.1216.short$equity, 
                    buy.hold.1216$equity)
colnames(all.1216)<-c("sma1216", "sma1216 short", "BH")
head(all.1216)
all.1216.long<-fortify(all.1216, melt=T)
head(all.1216.long)

title = "Cumulative returns of 1216s"
p1 = ggplot(all.1216.long, aes(x = Index, y = Value)) +
  geom_line(aes(linetype = Series, color = Series)) +
  #geom_point(aes(shape = Series))+
  xlab("year") + ylab("cumulative returns")+
  ggtitle(title)
p1

#1301----
library(xts)
data1<-new.env()
data1$prices<-tw20.all.1$'1301'
prices<-data1$prices
sma1301<-SMA(prices, 90)
head(sma1301, 91)

bt.prep(data1, align='keep.all')
names(data1)
data1$dates
data1$prices
data1$prices<-prices

class(data1$dates)
data1$execution.price = prices
data1$weight[] = 1
buy.hold.1301 <- bt.run.share(data1, clean.signal=F, trade.summary = TRUE)
buy.hold.1301 <-bt.run(data1)

sma1301<-SMA(prices, 90)
head(sma1301, 91)
data1$weight[] <- iif(prices >= sma1301, 1, 0)
sma90.1301 <- bt.run(data1, trade.summary=T)

data1$weight[] <- iif(prices >= sma1301, 1, -1)
sma90.1301.short <- bt.run(data1, trade.summary=T)

models.2<-list("SMA1301"= sma90.1301, 
             "SMA1301_short" = sma90.1301.short, 
             "BH 1301" = buy.hold.1301)
strategy.performance.snapshoot(models.2, T)
strategy.performance.snapshoot(models.2, control=list(comparison=T), sort.performance=T)
plotbt.strategy.sidebyside(models.2, return.table=T)

ifelse(!require(ggplot2), install.packages('ggplot2'), library(ggplot2))
all.1301<-merge.xts(sma90.1301$equity, 
                    sma90.1301.short$equity, 
                    buy.hold.1301$equity)
colnames(all.1301)<-c("sma1301", "sma1301 short", "BH")
head(all.1301)
all.1301.long<-fortify(all.1301, melt=T)
head(all.1301.long)

title = "Cumulative returns of 1301s"
p2 = ggplot(all.1301.long, aes(x = Index, y = Value)) +
  geom_line(aes(linetype = Series, color = Series)) +
  #geom_point(aes(shape = Series))+
  xlab("year") + ylab("cumulative returns")+
  ggtitle(title)
p2
