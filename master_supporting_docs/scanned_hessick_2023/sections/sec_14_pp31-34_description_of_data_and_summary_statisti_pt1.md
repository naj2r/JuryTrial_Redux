# Section: Description Of Data And Summary Statisti (Part 1)
**PDF pages:** 31–34
**Split method:** headers
**Note:** This is part of a longer section, sub-split to ensure deep reading.

---

--- PAGE 31 ---
voters could respond to the prison admission rate per crime, since this is a metric 
the prosecutor has more control over than the actual crime rate.199 Voters might 
think that the prosecutor is sending too many or too few people to prison. 
Of course, voters alone do not determine whether there is a challenger—because 
only lawyers can stand for election, a dissatisfied voter may not have a choice at 
the polls. But potential challengers might see crime rates or prison admission rates 
as a weakness for the incumbent prosecutor. In other words, these numbers might 
incentivize quality candidates to run for the office. 
B. Description of Data and Summary Statistics 
For this study, we rely on data collected by the Prosecutors and Politics 
Project.200 These data include vote share information about each candidate that ran 
in a district prosecutor election for forty-five states, each sampled in one year rang-
ing from 2012–2017.201 We combine these data with additional district-level infor-
mation including presidential election results,202 
MIT Election Data Science Lab, County Presidential Election Returns, HARVARD DATAVERSE, https:// 
dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/VOQCHQ (last visited Oct. 23, 2022). 
demographic information from 
the U.S. Census, prison admissions information from National Corrections 
Reporting Program through the National Archive of Criminal Justice Data,203 
Danielle Kaeble, Bureau of Justice Statistics, National Corrections Reporting Program, U.S. DEP’T OF 
JUST. (2019), https://bjs.ojp.gov/data-collection/national-corrections-reporting-program-ncrp#publications-0. 
and 
information about the size, salary, budget, staff, and full- or part-time statues of 
prosecutors’ offices from the Bureau of Justice Statistics.204 We also included the 
various state election law rules discussed in the previous subsection.205 
Here, a contested election is defined as a race with more than one candidate run-
ning for the office of prosecutor. A competitive race is defined in accordance with 
political science literature that suggests a competitive race is one in which there is 
more than “token opposition.”206 We code a race as competitive if the winning can-
didate received less than eighty percent of the vote in the election.207 
199. The prosecutor’s charging and plea bargaining decisions have a direct effect on how many people are 
admitted to prison, while crime rates depend on many variables, some of which are unknown. Cf. Bibas, supra 
note 9, at 986 (“Crime rates are often driven by exogenous factors, such as the crack-cocaine boom or increased 
police hiring, for which prosecutors deserve little credit or blame.”). 
200. See supra note 177. For more information about how the data was collected, see Hessick & Morse, supra 
note 3, at 1558–61. 
201. Different jurisdictions are sampled in different years because not all prosecutor elections are held in the 
same year. 
202. 
203. 
204. See Perry et al., supra note 188. 
205. See supra notes 191–98 and accompanying text. 
206. Burden, supra note 101, at 221. 
207. Different studies use different thresholds. For example, Burden uses ninety percent as an indication of 
competitiveness, Burden, supra note 101, at 221, while Jewitt and Treul use seventy-five percent, Ideological 
Primaries, supra note 101, at 214. We use the eighty percent threshold as it allows us to capture more opposition 
than the seventy-five percent threshold and given low levels of contestation to start with, this allows us to classify 
as many elections as competitive, while still remaining within the bounds of what is considered acceptable in 
political science literature. 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
61
--- END PAGE 31 ---

--- PAGE 32 ---
Table 1 presents summary statistics about the incidence of contestation and 
competition: 
Table 1: Contestation and Competition in Prosecutorial Elections by 
Election Type 
Type of Challenge 
Contested 
Competitive  
General Election 
17.78% 
17.26% 
Primary Election 
13.85% 
13.72% 
Both Primary & General 
3.45% 
3.37%  
208. Logistic regression relies on a logistic distribution to model binary outcomes (dependent variables). 
They are used to predict the likelihood of one outcome happening opposed to the other based on certain factors 
(independent variables). For a detailed discussion of logistic regression, see ANDREW GELMAN & JENNIFER HILL, 
DATA ANALYSIS USING REGRESSION AND MULTILEVEL/HIERARCHICAL MODELS 79–86 (2006). 
209. Id. 
210. The precise specification of the multilevel mode is Pr yi ¼ 1
ð
Þ ¼ logit 1
; for i
1; :::; n; where 
X is the matrix of individual level predictors (defined below), j i½  indexes the state where district i is contained, yi is 1 if 
the election was contested (or competitive) and 0 otherwise, and b is the vector of predictors of length i. The second part 
62                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31 
Table 1 shows that 17.78% of general elections attract a challenger and 17.26% 
of general elections are competitive using the 80% standard discussed above. This 
indicates that almost all challengers in general elections offer more than token 
opposition. This is also the case for primary elections, where the gap between con-
testation and competition rates—13.85% and 13.72%, respectively—is even 
smaller. 
The last row reflects the frequency with which an election is contested or com-
petitive in both the primary and the general election. This is quite rare at less than 
4% for both contested and competitive elections, which means that if an incumbent 
is going to face a competitive election, it is likely to be in the general or the pri-
mary stage, but not both. 
To test the various factors identified, we fit two logistic regression models208 
with state-level varying intercepts. This method allows us to estimate the individ-
ual effect of district-level characteristics—the independent variables—on the inci-
dence of contestation or competition—the dependent variable.209 For example, 
regression analysis can tell us how district population (an independent variable) is 
related to the likelihood of a prosecutor’s race being contested (the dependent vari-
able), controlling for the effects of other independent variables. 
To account for unobserved state-level variation, we estimate a multilevel model. 
This type of model allows us to assume that states may have different baseline lev-
els of contestation and competition due to features that we cannot observe and 
therefore include in the model, but the independent variables in the model affect 
the individual states in a consistent way.210
--- END PAGE 32 ---

--- PAGE 33 ---
We include a number of independent variables that we expect to be relevant 
to contestation and/or competition. At the state level, the model includes three 
variables that correspond to three different legal rules surrounding elections in 
different states. The first of those variables, Exclude Uncontested, refers to the 
practice in some states of excluding uncontested elections from their ballots. 
The second variable, Partisan Election, refers to those states that indicate the 
political party affiliation of prosecutorial candidates on the ballot. The third 
variable, Straight Ticket Option, refers to the practice of states allowing voters 
to vote for a party across the entire ballot. 
In addition to these state-level variables, we also include multiple county- 
level variables. Budget per Capita reflects the dollars spent per person by the 
district’s prosecutors’ office. The variable Partisan Mismatch represents 
cases where the incumbent prosecutor is not representing the party that 
received the majority of votes in the 2016 presidential election. Open Race 
identifies cases where there is no incumbent running. Incumbent Tenure cap-
tures the number of years the incumbent has held the office of district prose-
cutor. To capture district level electoral context, the model also includes the 
percent change in the crime rate (Change in Crime) from four years preced-
ing the election year to the election year211 as well as the district’s Prison 
Admissions which show how many people from a district were admitted to 
prison in a given year.212 
See Josh Keller & Adam Pearce, U.S. State Prison Admissions by County, GITHUB.COM (Sept. 13, 2016), 
https://github.com/TheUpshot/prison-admissions. 
It also controls for the districts’ Population. In later 
models, we capture the effects of lawyer supply by specifying models with 
an independent variable for Number of Lawyers as well as Lawyers per 
Capita. 
Table 2 shows a description of each independent variable included in the 
model.   
of the model is defined as: aj 
a ; for j
1; :::; 44: Where U is the matrix of state-level predictors, g 
is the vector of coefficients for the state-level regression, and s a is the standard deviation of the unexplained 
state-level errors. See id. at 301–20. 
211. We chose four years because that is overwhelmingly the most common term length for local prosecutors. 
See Hessick & Morse, supra note 3, at 1550. 
212. 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
63
--- END PAGE 33 ---

--- PAGE 34 ---
Table 2: Descriptions of Variables 
Independent Variable 
Description  
Straight Ticket 
Option 
1 if the state has an option for party-based straight ticket 
voting 
Multi-County 
District 
1 if the prosecutorial district contains multiple counties 
Exclude 
Uncontested 
1 if the state does not include uncontested prosecutorial races 
on the ballot 
Budget per 
Capita 
Dollars in the 2007 prosecutorial budget per person in 
the district 
Partisan 
Election 
1 if the prosecutor is a partisan office 
log(Population) 
Natural log of the 2010 Census Population for the district 
Partisan 
Mismatch 
1 if the incumbent is not representing the party that received 
the majority of votes in the 2016 presidential election 
Open Race 
1 if the incumbent is not running for re-election 
Incumbent 
Tenure 
The number of years the incumbent has held the office of 
prosecutor 
Number of 
Lawyers 
Number of lawyers in the district 
Lawyers per 
Capita 
The number of lawyers in a district divided by the population 
of the district multiplied by 1000 
Change in 
Crime 
The change in crime rate for a district between four years 
prior to the election year and the election year 
Prison Admissions 
The number of people from a prosecutorial district admitted 
to prison in one year  
213. See infra tbl. A.1. 
214. Each statistically significant covariate in the contestation model is also significant and has the same sign 
in the competition model. 
64                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31 
Below, Table 3 reports the results of four models. In all models the dependent 
variable is 1 if there was more than one candidate in the prosecutorial race. The 
results of our models for whether the election is competitive are included in the ap-
pendix below.213 The results are largely similar.214
--- END PAGE 34 ---