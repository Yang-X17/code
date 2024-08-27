setwd("D:\\1.Topic\\4.other\\model")#设定工作路径

library(xlsx)
library(trend)#MK检验的包
data<-read.xlsx("D:/1.Topic/4.other/model/3.dropdata.xlsx" ,3)

#循环 定义一个数据范围，定义一个数据操作，在这个范围中遍历这个操作
for (i in 1:1071){
a<- as.numeric(data[,c(i)])
b<-mk.test(a,continuity = TRUE)
mk_p[i] <- as.numeric(b[2])
mk_z[i] <- as.numeric(b[3])
}
df<-data.frame(mk_p,mk_z)
write.csv(df,"D:/1.Topic/4.other/model/df.csv")#保存输出结果，存在工作路径中
