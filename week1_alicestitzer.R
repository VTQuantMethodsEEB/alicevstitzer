#week 1 code

#reading data into R
pop = read.csv("kate_cluster_master_class.csv") #count data

#using View to view the data
View(pop)

#exploring structure of data
head(pop)

str(pop$species)
str(pop$site)
str(pop$date) #currently stored as character, will need to change later

dim(pop) #10 columns

#selecting things
pop[pop$site=="GERMANIA NO. 2",] #selecting all Germania No. 2 entries
View(pop[pop$site=="GERMANIA NO. 2",])
pop[pop$species=="MYLU"&pop$site=="GERMANIA NO. 2",] #selecting all entries where the species is MYLU AND the site is Germania No. 2
pop[pop$species=="MYLU" | pop$site=="GERMANIA NO. 2",]#selecting all entries where the species is MYLU OR the site is Germania No. 2

#summary
summary(pop)

#add a column
pop$date2 = as.Date(pop$date, "%m/%d/%Y") #making new column that fixes the formatting of the date
dim(pop) #checking that a new column was added, should be 11 columns now

#aggregate
f1 = aggregate(clustersize~site+date+species, FUN = sum, data = pop) #sum of counts for each species, grouped by date and site
View(f1)
f2 = aggregate(clustersize~site+species, FUN = mean, data = f1) #curious about the average number of bats counted in a site for each species over ALL years
View(f2)
f3 = aggregate(clustersize~site+date, FUN = sum, data = f1[f1$species == "MYLU",], na.rm = T) #want to see just the little brown bat counts, grouped by date and site
View(f3)

#tidyverse equivalent to f1
#although?? the output for this function has 11 more entries than f1 and I'm not sure why... I thought they would be identical
library(tidyverse)
pop2 = pop %>%
  group_by(site,date,species) %>%
  summarise(N = sum(clustersize, na.rm = T))
View(pop2)

