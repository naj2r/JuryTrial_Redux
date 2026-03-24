# Section: Description Of Data And Summary Statisti (Part 2)
**PDF pages:** 35–38
**Split method:** headers
**Note:** This is part of a longer section, sub-split to ensure deep reading.

---

--- PAGE 35 ---
The first two models represent general elections and the last two represent pri-
mary elections. For each election type, we run one model for all races and one 
model that only includes races where an incumbent is running, which allows us to 
include the independent variables Partisan Mismatch and Incumbent Tenure. The 
leftmost column shows the various independent variables and other control varia-
bles that we are interested in. For each model and variable, Table 3 reports two sta-
tistics. In the first, it reports the model coefficient which represents the effect of a 
one-unit change of the independent variable on the input of the logistic function. 
Positive numbers indicate the independent variable increases the likelihood of con-
tested elections while negative numbers indicate the variable decreases the likeli-
hood of contested elections. 
Each coefficient estimated has an amount of variation associated with it. This 
variation, called the standard error, is the second statistic reported in parentheses. 
The higher the error, the less confident we can be that the estimated coefficient is 
the true coefficient. Using the standard error, we are able to quantify how likely it is 
that the effect we detect is representative of a true effect rather than random noise. 
If a coefficient estimate is less than five percent likely to be found because of ran-
dom noise,215 it is designated as statistically significant with an asterisk (p<.05). 
The last two rows of the table report the number of observations (prosecutorial 
races) used in the regression model and the Akaike Information Criterion, which 
represents how well the model fits the data;216 lower values mean that the model is 
a better fit for the data than higher values. 
In these first two models, open race, larger populations,217 and partisan mis-
match all have the effect of increasing the likelihood of both contestation and com-
petition. In other words, these models show strong and consistent support for the 
conclusion that these factors have a significant effect on whether voters will have a 
choice at the polls and whether that choice will be meaningful. 
Open seat races—that is, races without an incumbent—are almost three times as 
likely to have a contested election as those with an incumbent.218 This finding is 
entirely consistent with the literature about the power that incumbents have to 
maintain their office if they desire.219 Additionally, since this effect is similar 
across contestation and competition,220 this suggests that incumbents are successful 
in “scaring-off” not only quality challengers but also any potential challengers at 
all. 
215. JEFFREY M. WOOLDRIDGE, INTRODUCTORY ECONOMETRICS: A MODERN APPROACH 124 (5th ed. 2013) 
(describing five percent confidence level as “the most popular choice” for regression). 
216. GELMAN & HILL, supra note 208, at 525. 
217. The variable population is included to capture the fact that there might be differences in contestation and 
competition based on the size of the prosecutorial district. We utilize the natural-logged form of this measure to 
standardize the units of measure and aid with interpretation. See WOOLDRIDGE, supra note 215, at 41–43. 
218. This number comes from transforming the log-odds reported in Table 3 to an odds ratio by taking the 
inverse natural log: e1:068 ¼ 2:89; e1:091 ¼ 2:98  .
219. See supra Part II.A. 
220. See infra tbl. A.1. 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
65
--- END PAGE 35 ---

--- PAGE 36 ---
Table 3: Contestation in Prosecutorial Elections  
 
Dependent variable: 
Any Challenger  
General Elections 
Primary Elections  
All Races 
Only 
Incumbents 
All Races 
Only 
Incumbents  
Straight Ticket
Option 
 
0.213 (0.293) 
0.345 (0.442) 
0.450 (0.240) 
0.700 (0.393) 
Multi-County 
District 
0.123 (0.226) 
0.439 (0.338) 
0.142 (0.185) 
0.268 (0.355) 
Exclude 
Uncontested 
0.097 (0.398) 
0.394 (0.582) 
0.578* (0.236) 
0.831* (0.381) 
Budget per  
Capita 
0.071 (0.057) 
0.149 (0.084) 
0.012 (0.059) 
0.037 (0.129) 
Partisan Election 
1.080* (0.391) 
1.337* (0.604)   
 
 
log(Population) 
0.259* (0.047) 
0.273* (0.064) 
0.267* (0.046) 
0.139 (0.086) 
Open Race 
1.068* (0.135)  
 
1.091* (0.129)  
 
Partisan 
Mismatch  
 
0.481* (0.189)  
 
0.804* (0.284) 
Incumbent 
Tenure  
 
0.034 (0.085)  
 
0.075 (0.123) 
Constant 
5.601* (0.620) 
6.119* (0.922) 
5.825* (0.534) 
3.510* (0.975) 
Observations 
2,316 
1,277 
4,307 
1,013 
Akaike Inf. 
Crit. 
1,977.809 
1,050.973 
2,156.754 
636.861 
State-Level 
Random Effects? 
Yes 
Yes 
Yes 
Yes 
Note: * p<.05.  
221. However, as we note below, once we control for population, differences in budget (and, by inference, 
staff) show no detectable effect. 
66
AMERICAN CRIMINAL LAW REVIEW
[Vol. 60:31 
Larger populations also encourage contested elections. This could indicate a 
preference among potential prosecutorial candidates for larger districts, which are 
generally accompanied by larger budgets, staff, and more responsibility.221
--- END PAGE 36 ---

--- PAGE 37 ---
Alternatively, this could be evidence of a supply problem, wherein there are not 
enough interested, eligible candidates in small districts to challenge incumbents. 
The possibility of a supply problem is discussed in the next Part. 
The incumbent’s party also had the predicted effect on elections. In cases of a 
partisan mismatch—that is, districts in which the incumbent’s party did not win 
the majority of the district’s presidential vote—contested general elections were 
more likely. This suggests that shifting district-level party alignments can serve as 
a signal to potential challengers of the incumbent’s electoral weakness, prompting 
more challengers. 
When examining the effect of an incumbent’s party in primary elections, we 
also see the expected result. Incumbents who come from the district’s majority 
party are more likely to face a challenger in the primary election than those incum-
bents who are out of step with the partisan identification of the district. This sug-
gests that potential candidates recognize the value of identifying with the party that 
gets the majority of district support in presidential elections.222 
Of course, because the incumbent will either belong to the majority party or the 
minority party in her district, a partisan election will necessarily feature a partisan 
match or a partisan mismatch.223 
The one exception to this would occur if an incumbent prosecutor ran as a third-party candidate or was 
unaffiliated with a party. But that was relatively rare in our dataset. We identified only fifty-three incumbents 
who ran as Independents. See PROSECUTORS AND POLITICS PROJECT, NATIONAL STUDY OF PROSECUTOR 
ELECTIONS 59, 88, 93, 95, 100–11, 165, 183, 186, 203, 206, 217, 243, 258, 271–72, 274–75, 279–82, 314–28, 
343, 350 (2020), https://law.unc.edu/wp-content/uploads/2020/01/National-Study-Prosecutor-Elections-2020. 
pdf. 
Given this, what the models detect is actually 
when (i.e., what stage of the election) an election is likely to be contested—the pri-
mary election or the general election. It does not tell us whether there will be a con-
tested election. 
When comparing the contestation rates across elections with a partisan match 
and elections with a partisan mismatch—that is, the rate at which either the pri-
mary or the general election was contested—we do not see a meaningful differ-
ence. Nor do we find a relationship between the magnitude of the mismatch and 
challenger emergence in general elections when examining the size of the presi-
dential vote share for a given district. (For example, Democratic incumbents in 
heavily Republican districts do not face more challenges than Democratic incum-
bents in slightly Republican districts.) 
Interestingly, neither incumbent tenure nor any of the professionalism and desir-
ability of position factors have a measurable impact on the predicted probability of 
a contested election. In other words, these factors do not have the expected effects. 
It is unclear why incumbent tenure does not affect contestation.224 After all, 
recently elected incumbents have had less time to establish themselves within the 
222. Presidential elections are frequently used to measure the partisanship of various electoral units because 
turnout is so high. 
223. 
224. We report the regression results for the competition model in Table A.1, infra. For each variable of 
interest, the results are substantively similar. 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
67
--- END PAGE 37 ---

--- PAGE 38 ---
local power structure and less time to build name recognition—some of the impor-
tant benefits that incumbency is thought to confer. It is possible that an incumbent 
who more recently won her election may represent the district better ideologically, 
and the coalitions that mobilized to elect her are more likely to still exist. But when 
we adjusted the model to isolate only those incumbents who had served less than a 
term—that is, those incumbents who likely had been appointed to their position— 
there was still no detectable effect in our main model.225 This suggests the incum-
bency advantage may be even stronger for prosecutors than for judges.226 
As for the professionalism and desirability of office factors, it is hard to know 
whether these factors are simply irrelevant to potential candidates or whether the 
relationship between these factors and population obscures meaningful differences 
from the candidates’ point of view. The size of the office staff and the overall size 
of the office budget fluctuate significantly based on the population of a district.227 
It may be that, for example, potential candidates do not respond to funding relative 
to the population, but rather find offices with a higher level of absolute funding 
more attractive. Of course, the level of absolute funding is highly correlated with 
population (.902), since offices receive funding mostly commensurate with the 
number of cases that they will process. Given the high level of correlation, we are 
unable to conclude if it is larger populations or higher budgets and larger staffs that 
encourage contestation. 
For our state-level variables, the Straight Ticket Option does not appear to have 
an effect on the likelihood of contestation.228 
At the time this data was collected, twelve states offered a straight ticket voting option. Those states are: 
Alabama, Indiana, Michigan, Kentucky, Oklahoma, South Carolina, Utah, Pennsylvania, Michigan, Iowa, and 
Texas. See Straight Ticket Voting, NATIONAL CONFERENCE OF STATE LEGISLATURES (July 11, 2022), https:// 
www.ncsl.org/research/elections-and-campaigns/straight-ticket-voting.aspx. 
Partisan Election, however, does sig-
nificantly increase the likelihood of a contested general election.229 Additionally, 
the practice of Excluding Uncontested from ballots does not appear to have an 
effect in general elections, but it does have an effect in primary elections. Those 
states that exclude uncontested elections from their primary ballots are less likely 
to have contested or competitive primary elections.230 
225. We identified 217 incumbents who ran for reelection after serving less than a full term. Some of these 
candidates had obtained their position by running in special elections. But others were appointed to fill vacancies. 
226. That is because, as noted, above, judges who have been previously appointed to the position were more 
likely to draw a challenger, see supra note 134 and accompanying text, but we do not observe a similar pattern 
for prosecutors. 
227. There is also a clear relationship between full-time and part-time status. Part time offices are found only 
in small population districts. 
228. 
229. This finding is contrary to the correlation that Wright observed, see Wright, supra note 11 at 603 tbl. 3, 
but it is consistent with the political science literature, see supra note 193–96 and accompanying text. The 
following states hold states nonpartisan prosecutor elections: Arkansas, California, Minnesota, North Dakota, 
and Oregon. Hessick & Morse, supra note 3, at 1550 tbl.1. In addition, Hawaii and Montana allow counties to 
decide whether the office is partisan or nonpartisan. Id. at 1552. 
230. Six states exclude uncontested races from the general election ballot, and fifteen states exclude 
uncontested races from the primary ballot. Hessick & Morse, supra note 3, at 1554–55. 
68                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 38 ---