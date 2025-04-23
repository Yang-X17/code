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
abootstrap_r_squared<- numeric(length = 10000)  
# 10000 Bootstrap samplings.Randomly select sample sizes of 70%, 80%, and 90%. The following is a sample size of 70%
for (i in 1:10000) {  
  sample_ratio <-0.7#If it is 80%, set it to 0.8 here
  n <- nrow(data4)
  sample_size <- round(n * sample_ratio)
  bootstrap_indices <- sample(1:n, size=sample_size, replace = FALSE)
  
  #Extract Bootstrap samples from the dataset
  bootstrap_data <- data4[bootstrap_indices, ]
  
  #Fitting a linear mixed effects model on Bootstrap samples
  model<-lmer(aslope_Log10~coastal.province.area_Log10+
                wetland.sum..man.sea.sal.co._Log10+
                protection.level_mean_Log10+hdi_Log10+
                frequency.coast_Log10+
                death.percent.coast_Log10+
                damage.percent.coast_Log10+
                land.dependence_Log10+sdependence_Log10+(1|ID_0),data=bootstrap_data,REML=FALSE)
  
  abootstrap_r_squared[i] <- rsq(model)$model  # Extract R-square of the model
}
write.csv(abootstrap_r_squared,"D:/1.Topic/4.other/model/abootstrap_r_squared.csv")
#retreat
#Create a vector to store the R-squared value of each Bootstrap sample
bootstrap_r_squared<- numeric(length = 10000)  
#retreat
# 10000 Bootstrap samplings.Randomly select sample sizes of 70%, 80%, and 90%. The following is a sample size of 70%
for (i in 1:10000) { 
  sample_ratio <- 0.7 #If it is 80%, set it to 0.8 here
  n <- nrow(data3)
  sample_size <- round(n * sample_ratio)
  bootstrap_indices <- sample(1:n, size = sample_size, replace = FALSE)
  
  #Extract Bootstrap samples from the dataset
  bootstrap_data <- data3[bootstrap_indices, ]
  
  #Fitting a linear mixed effects model on Bootstrap samples
  model <- lmer(SLOPE_Log10 ~ coastal.province.area_Log10 +
                  wetland.sum..man.sea.sal.co._Log10 +
                  protection.level_mean_Log10 + hdi_Log10  +
                  frequency.coast_Log10 + death.percent.coast_Log10 +
                  damage.percent.coast_Log10 +
                  land.dependence_Log10 + sdependence_Log10 + (1|ID_0), data =bootstrap_data, REML = FALSE)
  bootstrap_r_squared[i] <- rsq(model)$model  # Extract the R-square of the model
}
write.csv(bootstrap_r_squared,"D:/1.Topic/4.other/model/bootstrap_r_squared.csv")

