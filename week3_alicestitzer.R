library(glmmTMB)
library(ggplot2)
library(viridis)
library(gridExtra)

###Practice with simple plotting###

#read in prepared count data 
small_sites = read.csv("small_sites.csv")
huge_sites = read.csv("huge_sites.csv")

#plot counts over time (ysw>3) in relation to site
#making two graphs, small sites N<500 and huge sites (N>40000)

g1 <- ggplot(data=small_sites, aes(x = year, y = N, color=site))+
  geom_point(size=2)+
  geom_line()
g1

g2 <- ggplot(data=huge_sites, aes(x = year, y = N, color=site))+
  geom_point(size=2)+
  geom_line()
g2
#fun to see each site's trajectory but difficult to see any trends with so much noise (a lot of small sites)

###Wanting to plot my GLMM model predictions###

#set-up before plotting#
count = read.csv("pop4.csv")

mod1 = glmmTMB(log.lambda ~ log.max.N + (1|site), data = count)
summary(mod1)
library(effects)
plot(allEffects(mod1))

#create prediction grid

newdat <- expand.grid(
  log.max.N = seq(min(count$log.max.N), max(count$log.max.N), length = 100),
  site = unique(count$site))

#predict fitted values and SEs
pred <- predict(mod1, newdata = newdat, type = "link", se.fit = TRUE, re.form = NA) #exclude random effects, population level, not sure if this is right?

#build confidence intervals
newdat$fit <- pred$fit
newdat$se  <- pred$se.fit
newdat$lower <- newdat$fit - 1.96 * newdat$se
newdat$upper <- newdat$fit + 1.96 * newdat$se

##now the actual plotting##

#overlay raw data
p <- ggplot() +
  geom_point(data = count, aes(x = log.max.N, y = log.lambda, color = log.max.N), alpha = 0.4) +
  geom_line(data = newdat, aes(x = log.max.N, y = fit), linewidth = 1) +
  geom_ribbon(data = newdat, aes(x = log.max.N, ymin = lower, ymax = upper), alpha = 0.25) +
  labs(
    y="Log10 Colony Growth Rate (λ)",
    x="Log10 Maximum Colony Size",
    title = ("Maximum Colony Size effects on Colony Growth Rate")) +
  scale_color_viridis(option="viridis")+
  theme_minimal()

p #this shows how colony growth rate varies with colony size (in log scale)
#the raw count data is overlaid on the predicted model trend

#trying to change prediction scale for next plot
newdat$max.N <- 10^(newdat$log.max.N)
#want to make x-axis reflect real colony size numbers
f <- ggplot() +
  geom_point(data = count, aes(x = max.N, y = log.lambda, color = max.N), alpha = 0.4) +
  geom_line(data = newdat, aes(x = max.N, y = fit), linewidth = 1) +
  labs(
    y="Log10 Colony Growth Rate (λ)",
    x="Maximum Colony Size",
    title = ("Maximum Colony Size effects on Colony Growth Rate")) +
  scale_colour_viridis(option="viridis") +
  theme_minimal() +
  scale_x_log10(breaks = c(10,100, 1000, 10000, 100000), labels = scales::comma)
f
#looks a little better but color gradient is on a weird scale/not doing much for visualization 

###MOD2###
#test categorical effect
count$size.category = "small"
count$size.category[count$max.N>500]="large"
mod2 = glmmTMB(log.lambda ~ size.category, data = count)
summary(mod2)
plot(allEffects(mod2))
#what is the effect of being a small site, relative to the effect of being a large site

#create a prediction dataset (categorical)
mod2 <- glmmTMB(log.lambda ~ size.category + (1 | site), data = count)
count$size.category <- as.factor(count$size.category) 
newdat2 <- expand.grid(size.category = levels(count$size.category))

#generate predictions
pred2 <- predict(mod2, newdata = newdat2, type = "link", se.fit = TRUE, re.form = NA) #link is same scale as log.lambda, re.form = NA excludes random effects

#add predictions and confidence intervals
newdat2$fit   <- pred2$fit
newdat2$se    <- pred2$se.fit
newdat2$lower <- newdat2$fit - 1.96 * newdat2$se
newdat2$upper <- newdat2$fit + 1.96 * newdat2$se

#plotting HERE
c <- ggplot() +
  geom_jitter(data = count, aes(x = size.category, y = log.lambda, color=N), width = 0.1, alpha = 0.4) +
  # predicted means
  geom_point(data = newdat2, aes(x = size.category, y = fit), size = 3) +
  # confidence intervals
  geom_errorbar(data = newdat2, aes(x = size.category, ymin = lower, ymax = upper), width = 0.15) +
  labs(
    x = "Colony size category",
    y = "Log10 colony growth rate",
    title = ("Large vs Small Colony Size on Colony Growth Rate")) +
  scale_colour_viridis(option="viridis") +
  theme_minimal()
c

#effect plots look fine, raw data overlaid just makes the relationship look less clear
#still figuring out best way to visualize  these

#one option might be to average the site data
head(count)
library(tidyverse)
counts.ag = count %>%
  group_by(site) %>%
  mutate(mean.log.lambda = mean(log.lambda))

counts.ag = counts.ag %>%
  select(site, max.N, mean.log.lambda, size.category)

counts.ag = unique(counts.ag)

#plotting HERE
c <- ggplot() +
  geom_jitter(data = counts.ag, aes(x = size.category, y = mean.log.lambda, color=max.N), width = 0.1, alpha = 0.4) +
  # predicted means
  geom_point(data = newdat2, aes(x = size.category, y = fit), size = 3) +
  # confidence intervals
  geom_errorbar(data = newdat2, aes(x = size.category, ymin = lower, ymax = upper), width = 0.15) +
  labs(
    x = "Colony size category",
    y = "Log10 colony growth rate",
    title = ("Large vs Small Colony Size on Colony Growth Rate")) +
  scale_colour_viridis(option="viridis") +
  theme_minimal()
c
#could also remove that one large one and note in caption