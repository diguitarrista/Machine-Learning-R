# I'm not using this in an academic level or for commercial purposes. 
# This code is only to demonstrate programming technics.
# This code was written by me (@diguitarrista) and was inspired by 
# a project from my class about RNN and Deep Learning.

# Using RNN algorithms we will analyze the humidity level at 3pm based on the humidity data at 9am

# 0) Installation of packages
packages <- c("rattle","rnn","ggplot2","dplyr")

if(sum(as.numeric(!packages %in% installed.packages())) != 0){
  instalador <- packages[!packages %in% installed.packages()]
  for(i in 1:length(instalador)) {
    install.packages(instalador, dependencies = T)
    break()}
  sapply(packages, require, character = T) 
} else {
  sapply(packages, require, character = T) 
}

# Packages

library("rnn")
library("ggplot2")

# 1) Data wrangling
# 1.1 - Data view
weatherAUS <- read.csv("weatherAUS.csv")
View(weatherAUS)

# 1.2 - Extract only columns 1 and 14 and first rows 3040 (Albury location)
data <- weatherAUS[1:3040,14:15]
summary(data)

# 1.3 - Clean
data_cleaned <- na.omit(data)

data_used <- data_cleaned[1:3000,]
x <- data_used[,1]
y <- data_used[,2]
head(x)
head(y)

# Split column x into 30 columns of 100 rows (3000/30)
X <- matrix(x, nrow = 30)
Y <- matrix(y, nrow = 30)

# 1.4 - Normalize
Yscaled <- (Y - min(Y)) / (max(Y) - min(Y))
Y <- Yscaled

Xscaled <- (X - min(X)) / (max(X) - min(X))
X <- Xscaled

# Train test split
train=1:80
test=81:100

# 2) Model
set.seed(12)
model <- trainr(Y = Y[,train],
                X = X[,train],
                learningrate = 0.01,
                hidden_dim = 15,
                network_type = "rnn",
                numepochs = 100)

plot(colMeans(model$error),type='l',xlab='epoch',ylab='errors')

# 3) Prediction
Yp <- predictr(model, X[,test])

rsq <- function(y_actual,y_predict)
{
  cor(y_actual,y_predict)^2
}

Ytest <- matrix(Y[,test], nrow = 1)
Ytest <- t(Ytest)
Ypredicted <- matrix(Yp, nrow = 1)
Ypredicted <- t(Ypredicted)

result_data <- data.frame(Ytest)
result_data$Ypredicted <- Ypredicted     

r_squared = rsq(result_data$Ytest,result_data$Ypredicted)

mean_y_test = mean(result_data$Ytest)
mean_y_pred = mean(result_data$Ypredicted)

table <- data.frame(
  Statistics = c("R²", "Mean Y values test", "Mean Y values predicted"),
  Values = c(r_squared, mean_y_test, mean_y_pred)
)
# Printing the table
print(table)

# Chart
plot(as.vector(t(result_data$Ytest)), col = 'blue', type='l',
     main = "Actual vs Predicted Humidity: testing set",
     ylab = "Y,Yp")
lines(as.vector(t(Yp)), type = 'l', col = 'red')
legend("bottomright", c("Predicted", "Actual"),
       col = c("blue","red"),
       lty = c(1,1), lwd = c(1,1))
