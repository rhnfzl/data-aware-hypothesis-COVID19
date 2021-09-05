# Library -----------------------------------------------------------------

library(tidyverse)
library(e1071)
library(fpp2)
library(corrplot)
library(mgcv)
library(caret)
# Wrangling ---------------------------------------------------------------
dset_cases <- read_csv("./datasets/cases.csv")
dset_wdi <- read_csv("./datasets/WDI.csv")
dset_covid <- read_csv("./datasets/covid.csv")
# Trasformation -----------------------------------------------------------

#Traspose of WDI Dataset
temp_wdi <- dset_wdi %>% pivot_wider(names_from = variable,
                                     values_from = Values) %>% 
  rename(location=`Country Name`)

#Trasformation on WDI Dataset              
complete_wdi <- temp_wdi %>% 
  #Select the attributes on to which to work on
                  select(location,
                    `Adjusted net national income per capita (constant 2010 US$)`,
                    `Air transport, passengers carried`,
                    `Current health expenditure per capita (current US$)`,
                    `Domestic general government health expenditure per capita (current US$)`,
                    `GDP per capita (constant 2010 US$)`,
                    `International tourism, number of arrivals`,
                    `Life expectancy at birth, total (years)`,
                    `Population ages 65 and above, total`,
                    `Population in largest city`,
                    `Population, total`,
                    `Urban population`
) %>%
  #To rename the the attributes
  rename(
    incomecapita = `Adjusted net national income per capita (constant 2010 US$)`,
    airtransport = `Air transport, passengers carried`,
    healthexp = `Current health expenditure per capita (current US$)`,
    govhealthexp = `Domestic general government health expenditure per capita (current US$)`,
    gdpcapita = `GDP per capita (constant 2010 US$)`,
    tourism = `International tourism, number of arrivals`,
    lifeexpectbirth = `Life expectancy at birth, total (years)`,
    ge65pop = `Population ages 65 and above, total`,
    citypop = `Population in largest city`,
    totalpop = `Population, total`,
    urbanpop = `Urban population`) %>%
  #To convert the alphabetic to numeric
    mutate(incomecapita = as.numeric(incomecapita),
           airtransport = as.numeric(airtransport),
           healthexp = as.numeric(healthexp),
           govhealthexp = as.numeric(govhealthexp),
           gdpcapita = as.numeric(gdpcapita),
           tourism = as.numeric(tourism),
           lifeexpectbirth = as.numeric(lifeexpectbirth),
           ge65pop = as.numeric(ge65pop),
           citypop = as.numeric(citypop),
           totalpop = as.numeric(totalpop),
           urbanpop = as.numeric(urbanpop)) %>% 
  #To filter out <blank> or NA values
  filter(!is.na(incomecapita), !is.na(airtransport), !is.na(healthexp), !is.na(govhealthexp),
         !is.na(gdpcapita), !is.na(tourism), !is.na(lifeexpectbirth), !is.na(ge65pop),
         !is.na(citypop),!is.na(totalpop),!is.na(urbanpop))



#Note : Income Tax had the NULL values for two countries so have removed it as it can be compensated with GDP

#Rename and remove noise from the covid dataset
complete_covid <- dset_covid %>% rename(location="country",quarantinestart = `quarantine start`,
                                    facemask = `facemask obligation`,avgtemp = `avg temp`) %>% 
  filter(!is.na(quarantinestart), !is.na(facemask), !is.na(avgtemp))

#Trasformation on Cases
complete_cases <- dset_cases %>% 
  group_by(location) %>% # Grouping category
  summarise(deaths = sum(new_deaths),  # summarizing, remember you need to specify new summarizing variable and its function
            cases = sum(new_cases))

#Join all the tables
mod_table <- inner_join(complete_wdi, complete_covid, by = "location") 

final_table <- inner_join(complete_cases, mod_table, by = "location")

correlation_ftable <- final_table %>% 
                  select(location, deaths, cases, incomecapita,
                             airtransport, healthexp, govhealthexp,
                             gdpcapita, tourism, lifeexpectbirth,
                             ge65pop, citypop, totalpop, urbanpop,
                             avgtemp, quarantinestart)

# Section I ---------------------------------------------------------------
#Correlation Matrix

my_datax <- correlation_ftable[, c(2:16)]
M <- cor(my_datax)
head(round(M,2))
corrplot(M, type="upper", order="hclust")

#Selecting the Variable
cor(final_table$deaths,final_table$tourism, method = "spearman")

#Density plot – Check if the response variable is close to normality
par(mfrow=c(1, 4))  # divide graph area in 2 columns
plot(density(final_table$tourism), main="Density Plot: Tourism", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(final_table$tourism), 2)))  # density plot for 'tourism'
polygon(density(final_table$tourism), col="red")
plot(density(final_table$airtransport), main="Density Plot: Air Trasport", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(final_table$airtransport), 2)))  # density plot for 'airtransport'
polygon(density(final_table$airtransport), col="green")
plot(density(final_table$deaths), main="Density Plot: Deaths", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(final_table$deaths), 2)))  # density plot for 'airtransport'
polygon(density(final_table$deaths), col="blue")
plot(density(final_table$cases), main="Density Plot: Cases", ylab="Frequency", sub=paste("Skewness:", round(e1071::skewness(final_table$cases), 2)))  # density plot for 'airtransport'
polygon(density(final_table$cases), col="orange")

#Correlation
cor(final_table$tourism,final_table$airtransport, method = "spearman")

cor(final_table$deaths ,final_table$cases, method = "spearman")

# Linear Regression Model between Cases and Air Trasport --------------------

linear_modelCA <- lm(data = final_table, # passing the table that we want to analyze
                    formula = cases ~ airtransport)  # y = airtransport and x = tourism

print(linear_modelCA)
summary(linear_modelCA) # looking at the summary of the linear mode

linear_modelDT <- lm(data = final_table, # passing the table that we want to analyze
                     formula = deaths ~ tourism)  # y = airtransport and x = tourism

summary(linear_modelDT) # looking at the summary of the linear mode


linear_modelDA <- lm(data = final_table, # passing the table that we want to analyze
                     formula = deaths ~ airtransport)  # y = airtransport and x = tourism

summary(linear_modelDA) # looking at the summary of the linear mode

linear_modelCT <- lm(data = final_table, # passing the table that we want to analyze
                     formula = cases ~ tourism)  # y = airtransport and x = tourism

summary(linear_modelCT) # looking at the summary of the linear mode
# Plot --------------------------------------------------------------------

ggplot(data = final_table, aes(x = cases, y = airtransport)) + #passing the mod table to create the plot
  geom_smooth(method = "lm") + # creating linear regression line in the plot layer  
  geom_point() # adding the points in the graph

ggplot(data = final_table, aes(x = deaths, y = airtransport)) + #passing the mod table to create the plot
  geom_smooth(method = "lm") + # creating linear regression line in the plot layer  
  geom_point() # adding the points in the graph

ggplot(data = final_table, aes(x = cases, y = tourism)) + #passing the mod table to create the plot
  geom_smooth(method = "lm") + # creating linear regression line in the plot layer  
  geom_point() # adding the points in the graph

ggplot(data = final_table, aes(x = deaths, y = tourism)) + #passing the mod table to create the plot
  geom_smooth(method = "lm") + # creating linear regression line in the plot layer  
  geom_point() # adding the points in the graph



# Section II --------------------------------------------------------------

boxplot(deaths~rice, data = final_table)


#ANOVA
anova_death_rice <- aov(deaths~rice, data = final_table)
summary(anova_death_rice)

#tUKEYS Test

TukeyHSD(anova_death_rice)


linear_modelrice <- lm(data = final_table, # passing the table that we want to analyze
                     formula = deaths ~ rice) 

summary(linear_modelrice)


ggplot(data = final_table, aes(x = rice, y = deaths)) + #passing the mod table to create the plot
  geom_smooth(method = "lm") + # creating linear regression line in the plot layer  
  geom_point() # adding the points in the graph


# Section III -------------------------------------------------------------


gam_tourism <- gam(deaths ~ s(tourism),
               data = final_table)
summary(gam_tourism)
plot(gam_tourism, rug = TRUE)

ggplot(final_table, aes(x = tourism, y = deaths) ) +
  geom_point() +
  stat_smooth(method = gam, formula = y ~ s(x))
