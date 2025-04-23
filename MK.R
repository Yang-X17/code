setwd("D:\\1.Topic\\4.other\\model")#Set default storage working path

library(xlsx)
library(trend)#package for MK test
data<-read.xlsx("D:/1.Topic/4.other/model/3.dropdata.xlsx" ,3)
mk_p<- numeric(length = 1071) 
mk_z<- numeric(length = 1071)

for (i in 1:1071){
a<- as.numeric(data[,c(i)])
b<-mk.test(a,continuity = TRUE)
mk_p[i] <- as.numeric(b[2])
mk_z[i] <- as.numeric(b[3])
}
df<-data.frame(mk_p,mk_z)
write.csv(df,"D:/1.Topic/4.other/model/df.csv")
