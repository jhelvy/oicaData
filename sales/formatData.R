library(tidyverse)
library(readxl)

setwd('/Users/jhelvy/pCloud Drive/data/cars/oica/sales')

#==============================================================================

# Read in and merge the two data frames
pc = read_excel('./salesData/raw/pc-sales-2019.xlsx', skip=5)
pc$country = str_to_title(pc$'REGIONS/COUNTRIES')
pc = pc %>%
    gather(year, sales, '2005':'2019') %>%
    select(country, year, sales) %>%
    mutate(type = 'pc')
cv = read_xlsx('./salesData/raw/cv-sales-2019.xlsx', skip=5)
cv$country = str_to_title(cv$'REGIONS/COUNTRIES')
cv = cv %>%
    gather(year, sales, '2005':'2019') %>%
    select(country, year, sales) %>%
    mutate(type = 'cv')
df = rbind(pc, cv) %>%
    filter(is.na(country)==F) %>%
    mutate(country = str_replace(country, '\\*', '')) %>%
    filter(country != 'Only Lv')

# Fix country name typos
countryNames <- data.frame(
    country=c('Switzerland (+Fl)', 'Congo Kinshasa', 'Moldavia',
              'United States Of America', 'Azerbaidjan', 'Cambodge',
              'Hong-Kong', 'Irak', 'Kazakstan', 'Kirghizistan', 'Tadjikistan',
              'Tahiti', 'Tukmenistan', 'Burkina', 'Guiana (French)'),
    goodName=c('Switzerland', 'Congo', 'Moldova', 'United States',
               'Azerbaijan', 'Cambodia', 'Hong Kong', 'Iraq', 'Kazakhstan',
               'Kyrgyzstan', 'Tajikistan', 'French Polynesia',
               'Turkmenistan', 'Burkina Faso', 'French Guiana'))
df <- df %>%
    left_join(countryNames) %>%
    mutate(goodName=ifelse(is.na(goodName), country, as.character(goodName)),
           country=goodName) %>%
    select(-goodName)

# Add region and continent data
worldRegions <- read.csv(file='./regionsData/worldRegions.csv', header=T)
df = df %>%
    left_join(worldRegions) %>%
    arrange(year, country)

# Separate out countries and regions
regions <- df %>%
    filter(is.na(region) == T) %>%
    mutate(region = country) %>%
    select(region, year, sales, type) %>% 
    arrange(region)
countries <- df %>%
    filter(is.na(region) == F) %>% 
    arrange(country)

# Save data frames
write.csv(countries, file='./salesData/salesDataByCountry.csv', row.names=F)
write.csv(regions, file='./salesData/salesDataByRegion.csv', row.names=F)
