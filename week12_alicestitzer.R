## WEEK 12 ##
library(tidyverse)
library(DHARMa)
library(viridis)
library(emmeans)
library(effects)
library(glmmTMB)
library(dplyr)
library(performance)

pop <- read.csv("pop_new.csv") 

mod1 = glmmTMB(log.lambda ~ log.max.N + (1|site), dispformula = ~ log.max.N, data = pop, family = "gaussian") #accounting for site as random effect
summary(mod1)
plot(allEffects(mod1))
library(DHARMa)
p = simulateResiduals(mod1, plot=T)
#added a dispersion formula here to account for small colonies having bigger residuals and that improved model fit a lot
#still has significant deviation in the KS test, but it's close enough

#create prediction grid
newdat <- expand.grid(
  log.max.N = seq(min(pop$log.max.N), max(pop$log.max.N), length = 100),
  site = unique(pop$site))

#predict fitted values and SEs
pred <- predict(mod1, newdata = newdat, type = "response", se.fit = TRUE, re.form = NA) #se.fit calculates standard error for each predicted value so it makes the confidence intervals easy to calculate, re.form NA drops site effects
#I used to use type = "link" here before, but using response doesn't seem to change it

#putting in confidence intervals
newdat$fit <- pred$fit
newdat$se  <- pred$se.fit
newdat$lower <- newdat$fit - 1.96 * newdat$se
newdat$upper <- newdat$fit + 1.96 * newdat$se

#overlay raw data (OG plot, all data points)
ggplot() +
  geom_point(data = pop, aes(x = log.max.N, y = log.lambda, color = max.N), alpha = 0.4) +
  geom_line(data = newdat, aes(x = log.max.N, y = fit), linewidth = 1) +
  geom_ribbon(data = newdat, aes(x = log.max.N, ymin = lower, ymax = upper), alpha = 0.25) + #CIs
  scale_x_continuous(labels = function(x) round(10^x)) + #convert back to actual N
  geom_vline(xintercept = 2.49, linetype = "dashed")+ #x-intercept is equal to N=310
  labs(
    y="Log10 Colony Growth Rate (λ)",
    x="Log10 Maximum Colony Size",
    title = ("Maximum Colony Size effects on Colony Growth Rate")) +
  scale_colour_viridis(option="viridis")+
  theme_bw()

#if I wanted to average log lambda for visualization purposes
pop$size.category = "small"
pop$size.category[pop$max.N>1000]="large"

head(count)
library(tidyverse)
counts.ag = pop %>%
  group_by(site) %>%
  mutate(mean.log.lambda = mean(log.lambda))

counts.ag = counts.ag %>%
  select(site, max.N, log.max.N, mean.log.lambda, size.category)

counts.ag = unique(counts.ag)

#plotting the means here, and also cutting Atkinson Mine Cave from plot because it throws everything off
ggplot() +
  geom_point(data = counts.ag %>% filter (site != "ATKINSON MINE CAVE"), aes(x = log.max.N, y = mean.log.lambda, color = max.N), alpha = 0.4) +
  geom_line(data = newdat, aes(x = log.max.N, y = fit), linewidth = 1) +
  geom_ribbon(data = newdat, aes(x = log.max.N, ymin = lower, ymax = upper), alpha = 0.25) +
  scale_x_continuous(labels = function(x) round(10^x)) + #convert back to actual N
  geom_vline(xintercept = 2.49, linetype = "dashed")+ #x-intercept is equal to N=310
  labs(
    y="Log10 Colony Growth Rate (λ)",
    x="Log10 Maximum Colony Size",
    title = ("Maximum Colony Size effects on Colony Growth Rate")) +
  scale_colour_viridis(option="viridis")+
  theme_bw()
