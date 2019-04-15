rm(list=ls())

ifelse(!require(quantmod), install.packages('quantmod'), library(quantmod))
tw20_adj_close<-read.csv("2018Q4_20.csv")
#
ifelse(!require(readr), install.packages('readr'), library(readr))
tw20.txt<-read.table("tw20.txt", header = T)
#
ifelse(!require(reshape2), install.packages('reshape2'), library(reshape2))
colnames(tw20.txt)<-c("id","", "date", "price")
tw20.xts = dcast(tw20.txt, date~id)
#
tw20.xts$date<-as.Date(as.character(tw20.xts$date), "%Y%m%d") 
library(xts)
tw20.xts.1<-xts(tw20.xts[,-1], order.by = tw20.xts$date)
#
library(quantmod)
tw20.mon.ret <- to.monthly(tw20.xts.1, indexAt = "lastof", OHLC=FALSE)
head(tw20.mon.ret)

library(PerformanceAnalytics)
library(magrittr)
tw20.day.ret <-Return.calculate(tw20.xts.1, method = "log")
head(tw20.day.ret)
#
con = gzcon(url('http://www.systematicportfolio.com/sit.gz', 'rb'))
source(con)
close(con)

load.packages('quantmod')

etf4.all<-readRDS("D:/gitest/gitest01/0415/tw20.txt")
head(etf4.all)
str(etf4.all)
etf4.all.1<-etf4.all[complete.cases(etf4.all),]
head(etf4.all.1)
tail(etf4.all.1)