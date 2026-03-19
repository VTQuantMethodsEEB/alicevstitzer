### WEEK 5 TESTS ###
library(tidyverse)

##First set of hypotheses##
#null: there is no difference in max colony size (max.N) between wisconsin and new york
#alternative: there is a significant difference in max colony size (max.N) between wisconsin and new york

pop <- read.csv("pop4.csv")
sites <- read.csv("unique_sites_master_class.csv")

sites$site <- toupper(sites$site)
sites <- sites %>%
  select(site, state, county)

join <- left_join(pop, sites, by="site")

pop2 = join %>%
  filter(state %in% c("NY", "WI")) %>% #choosing wisconsin and new york sites to represent midwest and northeast
  filter(ysw %in% c("4")) %>% #arbitrarily choosing 4 years since WNS
  select(state, max.N)

#permutation test
set.seed(101)

res <- NA ## set aside space for results

for (i in 1:1000) {
  countboot <- sample(c(pop2$max.N))
  nyboot <- countboot[1:length(pop2$state[pop2$state=="NY"])]
  wiboot <- countboot[(length(pop2$state[pop2$state=="NY"])+1):length(pop2$state)]
                      
  res[i] <- mean(wiboot)-mean(nyboot)       #calculate difference in wisconsin colony means and new york colony means               
}

#observed mean difference in colony sizes
obs <- mean(pop2$max.N[pop2$state=="NY"])-mean(pop2$max.N[pop2$state=="WI"])
obs

hist(res,col="gray",las=1,main="")
abline(v=obs,col="red")

#calculating p-value
res[res>=obs]
length(res[res>=obs]) #there are 645 possible values that the permutation spit out
645/1000 #divide by total length of for loop, 1000
mean(res>=obs)
#not significant, but I think that makes sense
#in ysw=4, the colony sizes in wisconsin and new york were not very different from each other

#curious about data distribution
#Shapiro-Wilk Test

swt<-shapiro.test(pop2$max.N)
swt

swt_NY<-shapiro.test(pop2$max.N[pop2$state=="NY"])
swt_NY

swt_WI<-shapiro.test(pop2$max.N[pop2$state=="WI"])
swt_WI
#not normally distributed

##Second set of hypotheses##
#null: there is no relationship between growth rates (log.lambda) and colony size (log.max.N)
#alternative: there is a relationship between growth rates (log.lambda) and colony size (log.max.N)

#Pearsons - for linear data
#use cor.test for testing correlations
pt <- cor.test(pop$log.max.N,pop$log.lambda)
pt
#correlation value is 0.15 which means the relationship is weakly linear, or growth rates increase slightly as colony size increases
#used this test because I'm assuming my data is normally distributed and linear

##everything below is extra but I was trying to justify what test to use##

swt_lambda<-shapiro.test(pop$log.lambda)
swt_lambda

swt_N<-shapiro.test(pop$log.max.N)
swt_N
#says data isn't normally distributed but I think my sample size is just too big?

#trying to visually check if my data is linear
plot(pop$log.max.N, pop$log.lambda, main="Scatterplot", xlab="X", ylab="Y")
lines(lowess(pop$log.max.N, pop$log.lambda), col="red")
#cant see clear relationship? slightly linear

model <- lm(log.lambda ~ log.max.N, data=pop)
plot(model, which=1)
#kind of horizontal but also curved at the beginning = maybe not totally linear?

#fitting model again, prob redundant
model <- lm(log.lambda ~ log.max.N, data = pop)
plot(model, which = 3) #which=3 is scale-location plot to check for homoschedasticity
#red line is slightlyy coned shape which worries me, should be horizontal

#QQ plot to visualize relationship
qqnorm(pop$log.max.N) #ok yeah basically linear
qqnorm(pop$log.lambda) #linear

install.packages("lmtest")
library(lmtest)
model <- lm(log.lambda ~ log.max.N, data=pop)
raintest(model)
#linear!