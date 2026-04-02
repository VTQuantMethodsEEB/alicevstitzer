### WEEK 7/8 LINEAR MODELS ###
library(tidyverse)
library(performance)
library(ggplot2)
library(emmeans)
library(effects)

#### PART 1 ####
pop <- read.csv("pop_join.csv")

#question: what is the influence of colony size on growth rates?
#hypothesis: pre-WNS colony size (log.max.N) will have an effect on population growth rates (log.lambda)
#particularly, as colony size increases, growth rates will increase

#diagnostic plots
mod1 = lm(log.lambda ~ log.max.N, data = pop)
summary(mod1)
#[now write out equations]
# y (growth rate) = ax +b
# y (growth rate) = 0.02837x - 0.07301
#population growth rates increase with colony size, 
#although the effect size is small (R squared is 0.024)

plot(mod1)
#this looks almost horizontal, but there is a bit of a dip that worries me 

resid(mod1) 
#this is saying my data is normal around the center, but has some crazy weird residuals at both ends
hist(resid(mod1))
#this is checking for heteroscedasticity and shows a 'cone' around -0.01 which means my data may be violating the assumption of homoscedasticity
shapiro.test(resid(mod1))
#this says my p-value is close to 0, which for this test means that my sample does not come from a normally distributed population

hist(pop$log.lambda) #data is bunched in the center but has long tails

check_model(mod1)
#yeah... not great! this model might not be the best for my data

#ggplot2
head(pop)
library(ggplot2)
r=ggplot(data=pop, aes(x=log.max.N, y=log.lambda))+ 
  geom_point()+
  stat_smooth(method = "lm")+
  theme_bw() + 
  theme(axis.title=element_text(size=20),axis.text=element_text(size=10),panel.grid = element_blank(), axis.line=element_line(),legend.position="top",legend.title=element_blank())
print(r)
#showing weakly positive relationship between growth rates and colony size

#### PART 2 ####

# ADDITIVE MODEL #
#hypothesis: the effect of pre-WNS colony size is consistent on fungal load across different temperatures
lmPOP1 <- lm(lgdL~log.max.N+temp, data= pop)
summary(lmPOP1)
plot(allEffects(lmPOP1))
#neither temp or log.max.N are significant, no evidence that colony size or temp affects fungal load independently

#utility function for pretty printing
pr <- function(m) printCoefmat(coef(summary(m)),
                               digits=3,signif.stars=FALSE)

pr(lm1 <- lm(lgdL~log.max.N+temp, data= pop))
#same output as summary

#using emmeans
# we can add the interaction for all pairwise comparisons
lsm2<-emmeans(lmPOP1,pairwise~log.max.N+temp)
lsm2
#wait emmeans is not right for this because i dont have categorical data

#creating prediction dataset and plotting
new.bat.combos = with(pop,
                      expand.grid(
                        log.max.N = seq(min(N, na.rm=T), max(log.max.N, na.rm=T), by=1),
                        temp = c(1, 6, 10) #different temps to demonstrate effect
                      ))
#predict
new.bat.combos$lgdL <- predict(lmPOP1,newdata=new.bat.combos)

#plotting predictions with raw data
ggplot(new.bat.combos,aes(x=log.max.N,y=lgdL,colour=temp))+ #set up plot using predictions dataset
  geom_line(aes(group=temp))+ #draw lines that are predictions, group them by temperature
  geom_point(data=pop, aes(x=log.max.N,y=lgdL,colour = temp)) #add the observed data to the plot
#temps have the same slope

# INTERACTIVE MODEL #
#question: how do colony size, temperature, and their interaction affect fungal load (lgdL)?
#hypothesis: the effect of colony size on fungal load CHANGES depending on temperature
lmPOP2 <- lm(lgdL~log.max.N*temp, data= pop)
summary(lmPOP2)
plot(allEffects(lmPOP2))

#trying out emtrends by manually adding categories?
lsm2<-emtrends(lmPOP2, pairwise~temp, var = "log.max.N", at = list(temp = c(1, 6, 10))) #binning temp into categories to highlight low, medium, and high
lsm2
#slope at temp = 1 is positive
#slope at temp = 6 is close to 0
#slope at temp = 10 is negative
#slope decreases and eventually becomes negative as temperature increases

#creating prediction dataset (redundant - same dataset for lmPOP1 above)
new.bat.combos = with(pop,
                      expand.grid(
                        log.max.N = seq(min(N, na.rm=T), max(log.max.N, na.rm=T), by=1),
                        temp = c(1, 6, 10) #different temps to demonstrate effect
                      ))
#predict
new.bat.combos$lgdL <- predict(lmPOP2,newdata=new.bat.combos)

#plotting predictions with raw data
ggplot(new.bat.combos,aes(x=log.max.N,y=lgdL,colour=temp))+ #set up plot using predictions dataset
  geom_line(aes(group=temp))+ #draw lines that are predictions, group them by temperature
  geom_point(data=pop, aes(x=log.max.N,y=lgdL,colour = temp)) #add the observed data to the plot
#large colonies at colder temperatures have HIGHER fungal loads than large colonies at warmer temperatures, and the effect reverses at smaller colonies
#potential evidence that small colonies lack the adaptive traits that evolved rapidly in large, and warm colonies
