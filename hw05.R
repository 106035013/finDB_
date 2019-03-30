#
rm(list=ls())
#-----------------------------------
# ggplot2教學：基本概念與qplot 函數
# 先安裝ggplot2
#(安裝→install.packages("ggplot2")、載入→library(ggplot2))
install.packages('ggplot2')
library(ggplot2)
# 用head看diamonds
head(diamonds)
# 抽出100筆，儲存在diamonds.subset
set.seed(5)
diamonds.subset <- diamonds[sample(nrow(diamonds), 100), ]
#qplot用法
# 前兩個參數分別是x軸與y軸的座標資料
qplot(diamonds$carat, diamonds$price)
# data 參數指定資料來源的data frame
qplot(carat, price, data = diamonds)
# 此圖顯示了鑽石的price與carat有明顯的關係。
# 加上對數（log）
qplot(log(carat), log(price), data = diamonds)
# 經過對數，呈現比較好的線性關係。
# 把x、y、z三個變數相乘，當作y軸的座標。
qplot(carat, x * y * z, data = diamonds)
# 大部分鑽石的體積都跟重量成正比。
# 利用color變數來替資料點著色，區別不同顏色的鑽石。
qplot(carat, price, data = diamonds.subset, color = color)
# 利用shape，以形狀區分資料。
qplot(carat, price, data = diamonds.subset, shape = cut)
# 加上透明度的參數，較容易辨識實際的資料分佈情況。
qplot(carat, price, data = diamonds, alpha = I(1/10))
qplot(carat, price, data = diamonds, alpha = I(1/100))
# 利用smooth，畫出平滑曲線。
qplot(carat, price, data = diamonds.subset,
      geom = c("point", "smooth"))
qplot(carat, price, data = diamonds,
      geom = c("point", "smooth"))
# 加入boxplot，將圖形變成箱形圖。
qplot(color, price / carat, data = diamonds, geom = "boxplot")
# 利用jitter繪製資料點，將每一個資料點都畫出來。
qplot(color, price / carat, data = diamonds, geom = "jitter")
# 加上透明度的參數。
qplot(color, price / carat, data = diamonds,
      geom = "jitter", alpha = I(1 / 5))
qplot(color, price / carat, data = diamonds, geom = "jitter",
      alpha = I(1 / 50))
qplot(color, price / carat, data = diamonds, geom = "jitter",
      alpha = I(1 / 200))
# 練習
# 以資料點的形狀區分cut變數。
qplot(color, price / carat, data = diamonds, geom = "jitter",
      alpha = I(1 / 5), shape = cut)
# 以資料點的顏色區分color變數。
qplot(color, price / carat, data = diamonds, geom = "jitter",
      alpha = I(1 / 5), color = color)
# 以資料點的顏色區分cut變數。
qplot(color, price / carat, data = diamonds, geom = "jitter",
      alpha = I(1 / 5), color = cut)
# 以箱形圖的外框顏色區分color變數。
qplot(color, price / carat, data = diamonds, geom = "boxplot",
      color = color)
# 以箱形圖的內部顏色區分color變數。
qplot(color, price / carat, data = diamonds, geom = "boxplot",
      fill = color)
# 調整箱形圖的外框粗細。
qplot(color, price / carat, data = diamonds, geom = "boxplot",
      size = I(2))
# 利用histogram繪製直方圖，適用於連續型資料，顯示一維資料的分佈。
qplot(carat, data = diamonds, geom = "histogram")
# 直方圖的bin寬度可用「binwidth」參數調整。
qplot(carat, data = diamonds, geom = "histogram",
      binwidth = 0.5, xlim = c(0, 3))
# 細部資訊要在bin寬度非常小的情況下才能顯現出來。
qplot(carat, data = diamonds, geom = "histogram",
      binwidth = 0.01, xlim = c(0, 3))
# 美學對應指定為一個類別型的變數時，
# 會讓資料以此類別變數為依據區分為多個群組，
# 不同顏色畫出不同的鑽石顏色的資料，產生堆疊式的直方圖。
qplot(carat, data = diamonds, geom = "histogram",
      fill = color)
# 利用density繪製密度函數圖，適用於連續型資料。
qplot(carat, data = diamonds, geom = "density")
# adjust調整密度函數圖的平滑程度，值越大曲線越平滑。
qplot(carat, data = diamonds, geom = "density", adjust = 3)
# 呈現多組資料的分佈。
qplot(carat, data = diamonds, geom = "density",
      color = color)
# 將直方圖密度函數圖合在一起，將y軸的單位指定為密度。
qplot(carat, ..density.., data = diamonds,
      geom = c("histogram", "density"))
# 使用bar繪製長條圖，適用於離散型類別資料。
qplot(color, data = diamonds, geom = "bar")
# 使用weight，自行指定列聯表的計算方式。
qplot(color, data = diamonds, geom = "bar", weight = carat) +
  ylab("carat")
# unemploy為失業人口，pop為人口總數，相除之後可計算失業率；
# line圖形的x軸是時間的資訊。
qplot(date, unemploy / pop, data = economics, geom = "line")
# uempmed為失業時間的中位數。
qplot(date, uempmed, data = economics, geom = "line")
# 利用path依據時間把每個點連接起來。
qplot(unemploy / pop, uempmed, data = economics,
      geom = c("point", "path"))
# 加上顏色來表示不同的年份。
year <- function(x) as.POSIXlt(x)$year + 1900
qplot(unemploy / pop, uempmed, data = economics,
      geom = "path", colour = year(date))
# facets將資料分組後畫在表格式圖形中，每一個子圖形的座標都相同。
# facets公式的左邊是列、右邊是行。
qplot(carat, data = diamonds, facets = color ~ cut,
      geom = "histogram", binwidth = 0.1, xlim = c(0, 3))
# 對一個變數分組時，將公式另一側指定為一個句點（.）。
qplot(carat, data = diamonds, facets = color ~ .,
      geom = "histogram", binwidth = 0.1, xlim = c(0, 3))
# main為指定圖形的標題；xlab、ylab為指定x軸與y軸的名稱。
qplot(
  carat, price, data = diamonds.subset,
  xlab = "Price ($)", ylab = "Weight (carats)",
  main = "Price-weight relationship"
)
# xlim、ylim為設定x軸與y軸的繪圖範圍。
qplot(
  carat, price/carat, data = diamonds.subset,
  ylab = expression(frac(price,carat)),
  xlab = "Weight (carats)",
  main="Small diamonds",
  xlim = c(.2,1)
)
# log="xy"則是讓x與y軸都經過對數轉換。
qplot(carat, price, data = diamonds.subset, log = "xy")

#-----------------
# ggplot2教學：圖層式繪圖
# carat對應到x軸、price對應到y軸，而以顏色區隔cut變數。
# stat與position要自行指定，用來指定統計轉換與細部的幾何圖形位置調整。
# 若不需要特別的轉換與調整的話，就指定為 "identity"。
# params用來指定geom與stat所需要的參數。
# geom指定為point，即可產生一張散佈圖。
my.plot <- ggplot(diamonds, aes(carat, price, colour = cut))
my.plot <- my.plot + layer(
  geom = "point",
  stat = "identity",
  position = "identity",
  params = list(na.rm = FALSE)
)
my.plot
# 用bin轉換來計算直方圖每個bin的數值，然後再使用bar使geom呈現圖形。

my.plot2 <- ggplot(diamonds, aes(x = carat))
my.plot2 <- my.plot2 + layer(
  geom = "bar",
  stat = "bin",
  position = "identity",
  params = list(
    fill = "steelblue",
    binwidth = 0.2,
    na.rm = FALSE
  )
)
my.plot2
# 以geom_histogram繪製直方圖的簡化圖層函數改寫。
my.plot3 <- ggplot(diamonds, aes(x = carat))
my.plot3 <- my.plot3 +
  geom_histogram(binwidth = 0.2, fill = "steelblue")
my.plot3
# qplot將建立繪圖物件與加入圖層的動作包裝成一個函數，其效果跟ggplot函數是相同的。
#1
ggplot(msleep, aes(sleep_rem / sleep_total, awake)) +
  geom_point()
qplot(sleep_rem / sleep_total, awake, data = msleep)
#2
qplot(sleep_rem / sleep_total, awake, data = msleep) +
  geom_smooth()
qplot(sleep_rem / sleep_total, awake, data = msleep,
      geom = c("point", "smooth"))
ggplot(msleep, aes(sleep_rem / sleep_total, awake)) +
  geom_point() + geom_smooth()
# 可以利用summary查看其內容。
my.plot4 <- ggplot(msleep, aes(sleep_rem / sleep_total, awake))
summary(my.plot4)
my.plot4 <- my.plot4 + geom_point()
summary(my.plot4)
#
bestfit <- geom_smooth(method = "lm", se = F,
                       color = alpha("steelblue", 0.5), size = 2)
qplot(sleep_rem, sleep_total, data = msleep) + bestfit
qplot(awake, brainwt, data = msleep, log = "y") + bestfit
qplot(bodywt, brainwt, data = msleep, log = "xy") + bestfit
#-------------
my.plot5 <- ggplot(mtcars, aes(mpg, wt, colour = cyl)) + geom_point()
my.plot5
mtcars.trans <- transform(mtcars, mpg = mpg ^ 2)
my.plot5 %+% mtcars.trans
#