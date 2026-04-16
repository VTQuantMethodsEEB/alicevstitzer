#### WEEK 10 GLMs ####
library(tidyverse)
library(DHARMa)
library(viridis)
library(emmeans)
library(effects)
library(glmmTMB)
library(dplyr)

pop <- read.csv("pop_new.csv") 

#testing the same hypothesis from week 7, but GLM is a better fit for the data
#hypothesis: the effect of colony size on fungal load CHANGES depending on temperature
mod1 <- glm(lgdL~log.max.N*temp, data= pop)
summary(mod1)
plot(allEffects(mod1))
#output is telling me that the interaction between colony size and temperature is significant (0.0224) and changes the effect on fungal loads

#emtrends on binned temps
lsm2<-emtrends(mod1, pairwise~temp, var = "log.max.N", at = list(temp = c(1, 6, 10))) #binning temp into categories to highlight low, medium, and high
lsm2
#slope at temp = 1 is positive
#slope at temp = 6 is close to 0
#slope at temp = 10 is negative
#slope decreases and eventually becomes negative as temperature increases

#creating prediction dataset
newdat = with(pop,
                      expand.grid(
                        log.max.N = seq(min(log.max.N, na.rm=T), max(log.max.N, na.rm=T), length.out=100), 
                        temp = c(1, 6, 10) #different temps to demonstrate effect
                      ))


#predict
newdat$yhat <- predict(mod1,newdata=newdat, type = "response")
head (newdat)

#plotting predictions with raw data
plot1 = ggplot(newdat,aes(x=log.max.N,y=yhat,colour=temp))+ #set up plot using predictions dataset
  geom_line(aes(group=temp))+ #draw lines that are predictions, group them by temperature
  geom_point(data=pop, aes(x=log.max.N,y=lgdL,color = temp)) #add real data points to plot
plot1

###getting prediction intervals##
preds  = predict(mod1,type="link",newdata = newdat, se.fit = T)
newdat = cbind(newdat, preds[1:2])#bind together se's and fitted points on your newdata
#get the inverse link function for your glm
ilink <- family(mod1)$linkinv
#back transform the CIs (not the SEs!)
newdat <- transform(newdat, 
                     Fitted = ilink(fit), 
                     Upper = ilink(fit + (2 * se.fit)),
                     Lower = ilink(fit - (2 * se.fit)))
#fitted should be the same as yhat
head(newdat)

#plot the output
plot1=ggplot(data=pop,aes(x=log.max.N,y=lgdL,color=temp))+
  geom_point(size=2,shape =1) +
  facet_wrap(~temp, nrow=3)+
  geom_line(data=newdat, aes(x=log.max.N,y=Fitted,col = temp))+
  geom_ribbon(data = newdat, aes(ymin = Lower, ymax = Upper, x = log.max.N,y=Fitted),
              fill = "steelblue2", alpha = 0.2) 
plot1
#annoyed because I can't get this to look right

#### WEEK 11 Model Comparisons ####

#making sure number of observations are consistent
dim(pop)
pop.trim = pop %>%
  drop_na(lgdL, temp, log.lambda, site, log.max.N)
dim(pop.trim)

#Likelihood ratio tests
mod1 = glm(lgdL~log.max.N, data = pop.trim)
mod2 = glm(lgdL~log.max.N+temp, data = pop.trim)
mod3 = glm(lgdL~log.max.N*temp, data = pop.trim)
mod4 = glm(lgdL~1, data = pop.trim) #null model

anova(mod1, mod2, mod3, mod4, test = "LRT")
#mod3 (lgdl~log.max.N*temp) has the lowest p-value, 0.022, followed by mod4 (null) with a p-value of 0.080
#this means that colony size and temp have the most significant relationship on fungal loads out of the other models tested

#testing for log.lambda for fun
mod5 = glm(log.lambda~log.max.N, data = pop.trim)
mod6 = glm(log.lambda~log.max.N+temp, data = pop.trim)
mod7 = glm(log.lambda~log.max.N*temp, data = pop.trim)
mod8 = glm(log.lambda~1, data = pop.trim) #null model

anova(mod5, mod6, mod7, mod8, test = "LRT")

#I thought these could be more interesting... but nothing is significant, except for the null model
#so this can be ignored

#AIC
library(bbmle)
AICtab(mod1, mod2, mod3, mod4, weights=T, sort=T)

#mod3 has a dAIC of 0 and a weight of 0.457, which means it's the best supported model in comparison to the others, and could explain ~46% of the data
#but kind of concerning that the null model, mod4, performs almost as well with a dAIC of 0.9, which would mean my predictors don't explain much of the variation in fungal loads 