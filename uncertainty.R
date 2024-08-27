library(xlsx)
library(lme4)
library(lmerTest)
library(boot)
library(rsq)
options(scipen = 200)
rm(list=ls())
alldata<-"D:/1.Topic/4.other/model/slopedata2/standata7.xlsx" 
data3<-read.xlsx(alldata,3) #retreat 
data4<-read.xlsx(alldata,4)#approaching

data3$ID_0 <-as.character(data3$ID_0)
data4$ID_0 <-as.character(data4$ID_0)
#approaching
abootstrap_r_squared<- numeric(length = 10000)  # 假设有1000次Bootstrap抽样
# 执行10000次Bootstrap抽样
for (i in 1:10000) {  # i 用于迭代，代表第几次 Bootstrap 抽样
  # 随机抽取70%、80%和90%的样本量，以下是抽取70%样本
  sample_ratio <-0.7#80%-0.8，90%-0.9
  n <- nrow(data4)
  sample_size <- round(n * sample_ratio)
  bootstrap_indices <- sample(1:n, size=sample_size, replace = FALSE)
  
  # 从数据集中提取Bootstrap样本
  bootstrap_data <- data4[bootstrap_indices, ]
  
  # 在Bootstrap样本上拟合线性混合效应模型
  model<-lmer(aslope_Log10~coastal.province.area_Log10+
                wetland.sum..man.sea.sal.co._Log10+
                protection.level_mean_Log10+hdi_Log10+
                frequency.coast_Log10+
                death.percent.coast_Log10+
                damage.percent.coast_Log10+
                land.dependence_Log10+sdependence_Log10+(1|ID_0),data=bootstrap_data,REML=FALSE)
  
  abootstrap_r_squared[i] <- rsq(model)$model  # 提取模型的整体R方
}
write.csv(abootstrap_r_squared,"D:/1.Topic/4.other/model/abootstrap_r_squared.csv")
#retreat
# 创建一个空的向量来存储每次Bootstrap抽样的R方值
bootstrap_r_squared<- numeric(length = 10000)  # 假设有1000次Bootstrap抽样
# 执行1000次Bootstrap抽样
for (i in 1:10000) {  # i 用于迭代，代表第几次 Bootstrap 抽样
  # 随机抽取70%、80%和90%的样本数，以下是抽取70%样本
  sample_ratio <- 0.7#80%-0.8，90%-0.9
  n <- nrow(data3)
  sample_size <- round(n * sample_ratio)
  bootstrap_indices <- sample(1:n, size = sample_size, replace = FALSE)
  
  # 从数据集中提取Bootstrap样本
  bootstrap_data <- data3[bootstrap_indices, ]
  
  # 在Bootstrap样本上拟合线性混合效应模型
  model <- lmer(SLOPE_Log10 ~ coastal.province.area_Log10 +
                  wetland.sum..man.sea.sal.co._Log10 +
                  protection.level_mean_Log10 + hdi_Log10  +
                  frequency.coast_Log10 + death.percent.coast_Log10 +
                  damage.percent.coast_Log10 +
                  land.dependence_Log10 + sdependence_Log10 + (1|ID_0), data =bootstrap_data, REML = FALSE)
  bootstrap_r_squared[i] <- rsq(model)$model  # 提取模型的整体R方
}
write.csv(bootstrap_r_squared,"D:/1.Topic/4.other/model/bootstrap_r_squared.csv")

