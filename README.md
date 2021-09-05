# Alternative Hypothesis of COVID19 using the provided data

## Goal

There are 1,754 preprint articles published in the Medrxiv and Biorxiv concerning the COVID-19 as of 7 April 2020. A lot of them also talks about infection rate and the mortality model whom the Author had little to no experiences with the subject matter so far. Although interesting, some results presented in the papers are rudimentary at best and might lead to disastrous policy making, here then you can pose different take on the situation based on the dataset available.

As of 7 April 2020, there are 1,754 preprint papers on the Medrxiv and Biorxiv pertaining to the COVID-19. Numerous them also discuss infection rates and fatality models, with which the Author has little to no prior expertise. Like one of the paper Hypothesies :

**Countries with higher rice consumption have a lower death rate due to the Coronavirus. Thus, rice is prevalent in coronavirus immunity.**

While the articles are fascinating, some of the findings given in them are elementary at best and may result in catastrophic policy decisions; in this project, take a different view of the issue based on the dataset available.


So, analyse and provide and **alternative hypothesis** by selecting variable available in the dataset and explain the reason behind selecting the particular variable.

## Setup

Use the R-Studio

## Implementation

#### Data Wrangling

- Trasposed the WDI.csv dataset based on variable and values.
- Renamed the respective variables columns which is needed for analysis and also Country Name to location.
- Since the variables values are in character, So, it has been changed to numeric using ```as.numeric()```  function followed by removed the noise (i.e missing values) from the transposed WDI dataset using ```!is.na()function```.
- Similarly, renamed the column and filtered the noise from the covid.csv file.
- Finally to group the number of cases in cases.csv file, it needs to be consolidated first, which has been done using ```group_by()``` function over the location and summed up the death and case rate. 
- Once all the three datasets are processed individually, it has been joined using ```inner_join()``` function first with WDI.csv and covid.csv and the output of it with the cases.csv on the basis of location.


### Analysis

For the analysis, within the provided variables selected the tourism based on correlation measure with death. Since tourism had the high value of Spearman's correlation i.e., ```0.5774436```. Below figure represents the heatmap for correlation measure with the respective variables for the given dataset.

![corrplot](/img/corrplot.png)

The effect of tourism on COVID-19 deaths or cases weren't studied at the time of this analysis. Instead, there were some papers and articles which explains the effect of COVID-19 spread rate with air travel/ travel, the most relevant study done was [The effect of travel restrictions on the spread of the 2019 novel coronavirus (COVID-19) Outbreak](https://www.science.org/doi/full/10.1126/science.aba9757) where studies have been done on Wuhan travel ban effects on the COVID-19 epidemic in and outside China.

So, instead of going with tourism, first, will establish the correlation between the Tourism and Air Transport followed by establishing the correlation between the death and cases. Once formed a relationship in both the models individually, will model the relationship between Air Transport and the number of cases.

#### Density Plot to understand the Normality of Dataset

Density plot has been plotted to check weather the Tourism, Air-Transport, Death, and Cases is normally distributed or not. It is clear from below figures that non of the variables are Normally Distributed. So, to establish the correlation with the respective variables, Spearman's correlation will be used.

![densityplot](/img/densityplot.png)

```Density Plot of Tourism, Air Transport, Deaths and Cases```

#### Correlation

Using Spearman's correlation between Tourism and Air Transport, the value turn out to be ```0.4646617```. Which suggests there is a Moderate relationship between them. Similarly, using the Spearman's correlation for Death and Cases, which equals to ```0.8977444```. Which suggest there is a high correlation between them. So, the deriving relationship between tourism or Air Transport and death or cases will provide almost the same results with the Linear regression model.


### Linear Regression Modeling

The Linear regression model provided the p-value equal to ```2.255e-05```, which obtained for Air Transport (independent variable) is significant as it is ```<0.05```; it suggests that Air Transport significantly influences the variable response Cases (i.e., there is a significant relationship between Air Transport and Cases). The R-squared value is ```0.6407```, which suggests that ```64.07%``` of the variance in Cases can be explained by Air Transport alone. Below plot of regression model is for the Cases and Air Transport.

![lrmodelcasesair](/img/lrmodelcasesair.png)

So, combining the correlation analogy, it also suggests that the volume of tourism is proportional to the number of deaths.

p-value | AirTrasport | Tourism
------- |------------ | ---------
Cases   | 0.0000225   | 0.0000225
Deaths  | 0.002106    | 0.002106

```p-value for all the cases```

R-Square| AirTrasport | Tourism
------- |------------ | ---------
Cases   | 0.6407      | 0.4169
Deaths  | 0.4169      | 0.6588

```R-Square for all the cases```

The respective p-value and R-square combination has been tabulated above.
 
From the Linear Regression Model on the Deaths and Rice the statistical values are shown in. 

R-Square| 0.2258
------- |--------
p-value | 0.03425

```Linear Regression Statistical Values of Rice and Deaths```

This clearly shows that the Regression model only explains ```22.58%``` of the model, which is not enough. For the sake of reference applied ANOVA one way modeling to understand if the eating rice helps to boost the immune system or not, the statistical values are shown in  as the p-value is ```<0.05``` it is evident that rice immunity Hypothesis is rejected.
 
Lower bound of thedifference in meanbetween the groups | Upper bound of thedifference in meanbetween the groups | p-Value
------------------------------------------------------ |------------------------------------------------------- | ---------
-19665.33                                              | -850.9775                                              | 0.0342478

```One way ANOVA Statistical Values of Rice and Deaths```

The variables taken into account for the Alternative Hypothesis clearly explains the relation between the Deaths/ Cases using the Linear regression model.


The Initial Hypothesis is the case comprises of two biases, The Lampost Fallacy and The Causality Bias. The causality bias because researchers develop the belief that there is a causal connection between death and rice that are unrelated, which can lead to a disastrous situation. Like optical illusions, these biases also occur for some known reason, but scientifically it is not true. The high causality leads to The Lamppost Fallacy because other researchers did not tend to understand why rice was selected and follow this based on wrong presumptions, which leads to incorrect research paper.


### Other Modeling Approach : Generalized Additive Models

It is evident from the density plot from the above figure that the Death and Tourism are not normally distributed. Designing a model that fits these two would require a nonlinear approach. Using Generalized Additive Models(GAM) for analysis modeling. The reason for using GAM is interpret-ability, regularisation, and flexibility. It offers a regularized and interpret-able approach when the model involves nonlinear effects – whereas other approaches ignore at least one of them.

Using GAM model R square value is ```0.74``` which means it is able to explain the ```74%``` of cases. Below figure represents the GAM model fit of chosen variable.

![gammodel](/img/gammodel.png)
