setwd("D:\\1.Topic\\4.other\\model\\graph")

library(xlsx)
library(lme4)
library(lmerTest)
library(rsq)

alldata<-"D:/1.Topic/4.other/model/slopedata2/standata7.xlsx" 
data3<-read.xlsx(alldata,3) #retreat
data4<-read.xlsx(alldata,4) #approaching

data3$ID_0 <-as.character(data3$ID_0)
data4$ID_0 <-as.character(data4$ID_0)

#retreat
model3<-lmer(SLOPE_Log10~coastal.province.area_Log10+
               wetland.sum..man.sea.sal.co._Log10+
               protection.level_mean_Log10+hdi_Log10+
               frequency.coast_Log10+
               death.percent.coast_Log10+
               damage.percent.coast_Log10+
               land.dependence_Log10+sdependence_Log10 +(1|ID_0),data=data3,REML=FALSE)
summary(model3)
rsq(model3)



#approaching
model5<-lmer(aslope_Log10~coastal.province.area_Log10+
               wetland.sum..man.sea.sal.co._Log10+
               protection.level_mean_Log10+hdi_Log10+
               frequency.coast_Log10+death.percent.coast_Log10+
               damage.percent.coast_Log10+
               land.dependence_Log10+sdependence_Log10+(1|ID_0),data=data4,REML=FALSE)
summary(model5)
rsq(model5)