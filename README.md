# Alice Stitzer's Repository for Quantitative Methods Class
## PARAGRAPH ABOUT DATA ## 
# I have bat hibernacula count data, white-nose syndrome (WNS) disease data, and bat banding data from the midwest and northeast. To briefly summarize key columns, the count data includes site, date, species, year of WNS arrival (yoa), and cluster size. I haven’t worked much with the disease data or the banding data yet, but the banding data includes site, date, species, band number, lgdL (metric for Pd load), and sex. I want to focus on little brown bat data from the count data and incorporate disease data to see how survival and growth rates are affected by colony size and white-nose syndrome. I’m still thinking through how to analyze extirpated site data. My main goals for this data are as follows: 1) Determine how little brown bat populations have fared in small and large sites post-WNS invasion, 2) Determine how colony size affects survival and population growth rates, and 3) Determine how many extirpated sites have been recolonized and what were their fates. Overall, what are the recovery dynamics of small and large sites?

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
