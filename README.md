# Alice Stitzer's Repository for Quantitative Methods Class
## PARAGRAPH ABOUT DATA ## 
I have bat hibernacula count data, white-nose syndrome (WNS) disease data, and bat banding data from the midwest and northeast. To briefly summarize key columns, the count data includes site, date, species, year of WNS arrival (yoa), and cluster size. I haven’t worked much with the disease data or the banding data yet, but the banding data includes site, date, species, band number, lgdL (metric for Pd load), and sex. I want to focus on little brown bat data from the count data and incorporate disease data to see how survival and growth rates are affected by colony size and white-nose syndrome. I’m still thinking through how to analyze extirpated site data. My main goals for this data are as follows: 1) Determine how little brown bat populations have fared in small and large sites post-WNS invasion, 2) Determine how colony size affects survival and population growth rates, and 3) Determine how many extirpated sites have been recolonized and what were their fates. Overall, what are the recovery dynamics of small and large sites?

## WEEK 1 ##

CODE: week1_alicestitzer.R

DATA: kate_cluster_master_class.csv

This week, I read in bat count data and explored some basic functions in R. 
Specifically, summing counts across species, averaging counts for each species, and summing the MYLU counts grouped by site and date using aggregate.

## WEEK 2 ##

CODE: week2_alicestitzer.R

DATA: kate_cluster_master_class.csv, 1_yoa_midwest_class.csv

This week, I manipulated the bat count data by using dplyr to group by site, date, and species.
I used summarise to sum clustersize by group and mutate to add an additional column that added 1 to every clustersize row.
I also practiced joining where I used a left_join to match sites from a new dataframe, yoa, to sites in my original dataframe, pop2, and add in the corresponding year of WNS arrival to pop2.

## WEEK 3 ##

CODE: week3_alicestitzer.R

DATA: small_sites.csv, huge_sites.csv, pop4.csv

This week, I practiced making simpler plots showing MYLU counts over time in small and large sites.
I also wanted to try and make more advanced plots showing my GLMM predictions with the count data.
I made a plot showing growth rates (log.lambda) on colony size as a continuous variable, and a box plot comparing growth rates in categorical groupings for small and large sites.
I learned how to tweak visual elements, like adding/changing axes, changing color themes, etc.

## WEEK 5 ##

CODE: week5_alicestitzer.R

DATA: pop4.csv, unique_sites_master_class.csv

This week, I applied various tests on two sets of hypotheses.

#First set of hypotheses:
#null: there is no difference in max colony size (max.N) between wisconsin and new york
#alternative: there is a significant difference in max colony size (max.N) between wisconsin and new york

I made a for loop and ran a permutation on my data to see if colony sizes vary by region (filtered by WI and NY for simplicity).
It showed no significance, meaning that the northeast and midwest have no statistical difference in colony sizes.

#Second set of hypotheses:
#null: there is no relationship between growth rates (log.lambda) and colony size (log.max.N)
#alternative: there is a relationship between growth rates (log.lambda) and colony size (log.max.N)

I ran a Pearson's correlation test to see if colony size affects growth rates, assuming my data was normally distributed and linear. 
It indicated a weak, but significant positive relationship between colony size (log.max.N) and growth rates (log.lambda), meaning growth rates increased slightly as colony size increased.

## WEEK 7/8 ##

CODE: week7_alicestitzer.R

DATA: pop_join.csv

#PART1
For week 7, I used a univariate linear model to see if there is an influence of colony size (predictor variable) on growth rates (response variable).
Looking at residuals and other diagnostic plots generated in check_model made me realize that this model does not fit my data very well. sad face :-(
Alas! plotting my data and using stat_smooth with "lm" showed a weakly positive relationship between growth rates and colony size

#PART2
For week 8, I joined my count data with disease and temperature data to test some different hypotheses using additive and interactive linear models.

Additive model: In this model, neither population size nor hibernacula temperature has a detectable effect on fungal growth.

Interactive mode: Fungal loads was influenced by an interaction between pre-WNS colony size and hibernacula temperature.
The effect of colony size shifted from positive at low temperatures to negative at high temperatures
Small colonies did not undergo rapid evolution of adaptive traits which could explain the increase in fungal loads in warmer hibernacula.
This is more aligned with decline patterns in the epidemic phase, and opposite the trend seen in large and warm colonies in the established phase.

## WEEK 10/11 ##

CODE: week10_alicestitzer.R

DATA: pop_new.csv

#PART1
For week 10, I used a generalized linear model to see if there is an influence of colony size and temperature on fungal loads (same variables I used for week 8, but using GLM).
Large colonies at colder temperatures have HIGHER fungal loads than large colonies at warmer temperatures, and the effect reverses at smaller colonies.
I attached a more in-depth results statement in a word doc on Canvas

#PART2
For week 11, I compared four models that are testing similar hypotheses as Week 10.
1) glm(lgdL~log.max.N)
2) glm(lgdL~log.max.N+temp)
3) glm(lgdL~log.max.N*temp)
4) glm(lgdL~1)

The interactive model with colony size and temp performed the best out of all the models I compared. 
Mod 3 had the lowest p-value (0.022) in the likelihood test, and the lowest dAIC (0) and highest weight (0.46) when compared using AIC