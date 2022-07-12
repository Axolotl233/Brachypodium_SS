rm(list=ls())
library(tidyverse)
library(ggrepel)
data <- read.csv("z.filter_TE.pca.txt",row.names=1)
data2 <- data[,colMeans(data[,-1175]) > 0]
data2 <- data2[ , which(apply(data2, 2, var) != 0)]
data2[,1174] <- data[,1175]
pca1 <- prcomp(data2[,-ncol(data2)],center = TRUE,scale. = TRUE)
df1 <- pca1$x
df1 <- as.data.frame(df1)
summ1 <- summary(pca1)
xlab1 <- paste0("PC1(",round(summ1$importance[2,1]*100,2),"%)")
ylab1 <- paste0("PC2(",round(summ1$importance[2,2]*100,2),"%)")
ggplot(data = df1,aes(x = PC1,y = PC2,color = data2$V1174))+
  stat_ellipse(aes(fill = data2$V1174),
               type = "norm",geom = "polygon",alpha = 0.25,color = NA)+ # 添加置信椭圆
  geom_point(size = 3.5)+
  labs(x = xlab1,y = ylab1,color = "Condition",title = "PCA Scores Plot")+
  guides(fill = "none")+
  theme_bw()+
  scale_fill_manual(values = c("#EB977D","#818DB8"))+
  scale_colour_manual(values = c("#EB977D","#818DB8"))+
  theme(
    panel.grid=element_blank()
  )