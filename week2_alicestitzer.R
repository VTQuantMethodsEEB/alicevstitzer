#week 2 code

library(tidyverse)
library(tidyr)
library(dplyr)

#reading in data
pop = read.csv("kate_cluster_master_class.csv")

#examining for mistakes
head(pop) #correct column names, first few rows look good
str(pop) #have to change date formatting from character, looks good otherwise
unique(pop$species) #should be 11 species and UNK, there were some NAs and blanks that I fixed

#experimenting with group by and dplyr

#summarise
pop2 = pop %>% #this assigns the resulting summary table a new name, pop2
  group_by(site,date,species) %>% #groups corresponding site, date, and species together 
  summarise(N = sum(clustersize, na.rm = T)) #reduces the number of rows by summing the counts from a certain site and date, aka sums each group if that makes sense
View(pop2) #quick check, looks good

#mutate
pop = pop %>% #manipulating the existing pop dataframe, not making a new one
  group_by(site,date,species) %>%
  mutate(N=(clustersize)+1) #adds a new column named N that is just clustersize + 1
View(pop) #check that the column was added, looks good
  
#difference between summarise and mutate is that summarise collapses rows and mutate adds columns but keeps the same number of rows

#practicing joins

#quick prep on dataframe, pop2, so I can join in a new dataframe, yoa

pop2$date2 = as.Date(pop2$date, "%m/%d/%Y") #adding column with the fixed date formatting
library(lubridate)
pop2$year = year(pop2$date2) #adding a column for year

yoa = read.csv("1_yoa_midwest_class.csv") #this dataframe has names of all of sites and the year that WNS arrived to that site

pop3 = left_join(x = pop2, y = yoa, by = c("site")) #matches site names from pop2 to yoa and adds in the corresponding year of WNS arrival and additional columns from the yoa dataframe
View(pop3) #check that it worked, looks good

 