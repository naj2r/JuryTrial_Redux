# Section: Results (Part 1)
**PDF pages:** 8–11
**Split method:** headers
**Note:** This is part of a longer section, sub-split to ensure deep reading.

---

--- PAGE 8 ---
702 
McCannon
appellate court may affirm the lower court's decision (80.6 percent) or dismiss the appeal
(2.4 percent). Both outcomes result in the decision being upheld. If the appellate court
does not uphold the decision, it may either reverse the decision (7.2 percent) or modify the
conviction (9.9 percent). A reversal leads to a vacating of a conviction and requires a new
trial. A modification typically adjusts the sentence. This can be done by directly changing
the length of the sentence, switching punishments from running consecutively to concur-
rently, or adjusting the degree of the crime (e.g., moving from first-degree to second-
degree burglary).
The final piece of information available in the slip opinion is the mode of the initial
trial. A conviction can be obtained with ajury trial or with a guilty plea. Additionally, New
York allows for nonjury (bench) trials that do not utilize a jury. Although a majority of
appeals come from guilty pleas, the fact that this percentage is as small as it is (55.6 percent)
is noteworthy. Typically, in state-level criminal courts a much higher proportion of convic-
tions arise from guilty pleas. For an example, in North Carolina over 97 percent of felony
convictions come this way (Bandyopadhyay & McCannon 2013). Thus, as to be expected,
appeals disproportionately come from convictions at trial. One likely reason for this is the
use of waiver of appeals within plea bargain agreements. Also, trials open up the possibility
of additional procedural errors to appeal.
Along with the information provided on the slip opinion, information on the pros-
ecutor, known in New York as the District Attorney, is collected. Information from each
county's Board of Elections is collected regarding both who is the current District Attorney
alongwith recent election results. District Attorneys run in partisan, popular elections in New
York and serve four-year terms. The information on elections is used to create the dummy
variable REELECT. Itis equal to 1 if the conviction occurs in the six months prior to the District
Attorney's reelection. Since the general election occurs in early November, REELECT is equal
to 1 in the months of May through October in the election year. It is important to emphasize
that REELECT is measuring the election concerns at the time of the initial conviction and not at
the time of the appeal. This is necessary to address the question as to whether, years later,
convictions that arose during reelection campaigns are more likely to be overturned by the
appellate courts. The mean value of this dummy variable in the data set is 0.098.
The counties in western New York stagger their elections. Figure 1 depicts the
number of District Attorney races that are in each election cycle. There is an uneven
staggering of elections in western New York.
Lower court judges in New York serve extended terms. County Court judges are
elected for 10-year terms, while Supreme Court justices serve 14-year terms. Thus, while
district attorney elections occur frequently in the data, convictions during times ofjudicial
retention concerns is rare. Furthermore, their election cycles do not coincide with pros-
ecutor elections.
III. RESULTS
With a binary dependent variable, a probit model is estimated to identify the factors
that affect the probability of upholding the lower court's decision. Table 2 presents the
--- END PAGE 8 ---

--- PAGE 9 ---
Prosecutor Elections, Mistakes, and Appeals
Figure 1: Election cycles.
19
8
4-
2-
0-
0 2
2000,2004,2008 
2001,2005,2009 
2002,2006,2010
2003,2007,2011
SOURCE: Data collected by the author from each county's Board of Election website.
results.' For each specification, the robust standard error is presented in parentheses and
the marginal effect is measured in the brackets. A constant term is included but not
reported in each.
Column A of Table 2 presents the results from the pooled data set. Column B
includes county fixed effects and year effects. This allows for an accounting for differences
across regions, which, importantly, captures the characteristics of the judges involved and
differences in political affiliation and ideology. Ftests for joint significance are conducted
restricting the specification in Column B, independently, for each group of controls. The
hypothesis that the variables within the group are jointly equal to 0 can be rejected at the
5 percent level for the county, year, grounds, and defense control variables. The crime
control variables can be rejected only with a 13 percent level of confidence. The Fstat for
the mode controls has a p value greater than 0.16 and the F stat for appellate controls
(including the MISSING5 variable) has one greater than 0.17. Column C reestimates the
model excluding these last two sets of control variables.
The results support the hypothesis put forth: convictions that occur in the months
leading up to a District Attorney's reelection are more error prone. The probability the
8Each specification includes a constant term and omits the dummy variables BURGLARY, PD, PLEA, SUPPRESS, ONON-
DAGA, and 2009. Due to the low number of observations IDENTITY, KIDNAP, and IMPERSON are included in
OTHERCRIME, DOUBLE is included in NOGROUNDS, and the counties LEWIS and ALLEGANY are included in JEFFERSON
and STEUBEN, respectively (as neighboring, adjacent counties).
-
703
6 1
--- END PAGE 9 ---

--- PAGE 10 ---
704 
McCannon
Table 2: 
Results (Binary Probit; Dependent Variable = UPHELD; N= 1,874)
A 
B 
C
REELECT 
-0.293** (0.121) 
-0.223* (0.125) 
-0.240* (0.124)
[-0.071] 
[-0.051] 
[-0.056]
APPELLANT 
1.340*** (0.275) 
1.521*** (0.288) 
1.662*** (0.266)
[0.452] 
[0.516] 
[0.560]
PAGES 
-0.710*** (0.083) 
-0.746*** (0.082) 
-0.732*** (0.080)
[-0.151) 
[-0.154] 
[-0.155]
GAP 
-0.004* (0.002) 
-0.005** (0.002) 
-0.005** (0.002)
[-0.001] 
[-0.001] 
[-0.001]
SUPREME 
-0.015 (0.093) 
-0.083 (0.102) 
-0.054 (0.101)
[-0.003] 
[-0.017] 
[-0.012]
MISSING5 
-0.649 (0.519) 
-0.290 (0.498)
[-0.174] 
[-0.067]
Controls
crime 
YES 
YES 
YES
defense 
YES 
YES 
YES
mode 
YES 
YES 
NO
grounds 
YES 
YES 
YES
appellate 
YES 
YES 
NO
Fixed effects
county 
NO 
YES 
YES
year 
NO 
YES 
YES
McFadden I 
0.191 
0.216 
0.200
AIC 
1515.3 
1517.0 
1509.2
% correctly predicted 
84.8% 
84.8% 
84.8%
Nor: QML standard crrors in parentheses. Marginal effects (at the mean) in brackets. ***p< 0.01; **p< 0.05;
*p<0.10.
appellate court upholds the lower court's decision decreases by between 5.1 and 7.1
percentage points.' Given that for the entire data set only 17 percent of cases are altered,
these are large effects.
The source of the appeal, the number of pages of the slip opinion, and the gap
between the conviction and appeal are all highly significant. Cases that result in longer slip
opinions are negatively correlated with a case being upheld and an increase in the number
of months is associated with increased rates of overturned decisions. Although not pre-
sented, excluding observations with excessively long gaps does not change the results or
their significance. The type of the lower court and the composition of the panel of appellate
justices are rather irrelevant.
The goodness-of-fit measurements are weak, which is to be expected since specific
information on the individual and case is not available. A satisfactorily high proportion of
observations, though, could be accurately classified with the econometric model. The
inclusion of county and year effects, while each jointly significant, does not improve the
'Table 2 presents QML-robust standard errors. The statistical significance remains if, instead, standard errors are
clustered at the county level.
--- END PAGE 10 ---

--- PAGE 11 ---
Prosecutor Elections, Mistakes, and Appeals
quality of the overall fit. In fact, the AIC worsens. Thus, county-level, time-invariant differ-
ences have little role in the appeals process. Since such controls are used to capture
systematic events at the county level (e.g., office size and budget, socioeconomic charac-
teristics, etc.) and macroeconomic events (e.g., recession), respectively, this points to
mistakes in the legal system being unrelated to these external factors. Information on
county-level demographics, features, and economics outcomes is used as substitutes to
district effects in alternative specifications. While not presented, the sign and significance
of REELECT does not change in these estimations. Similarly, controls for the number of
violent crimes and property crimes along with political variables (e.g., support for Obama
in election contests) can be added. Again, the sign, magnitude, and significance of REELECT
remain.' 0
If the estimations are redone substituting or adding a dummy variable for the first
four months of the year of reelection (January through April), they are statistically insig-
nificant. Thus, it is the immediate leadup to the reelection that matters. Furthermore, if the
preelection window is shortened or expanded by a month, the significance remains. When
April is added, the relationship weakens. Thus, a six-month window is most appropriate.
Typically, public announcements of candidacies occur the last week of April or in early May
so the econometric result coincides with practice."
Since the appellate justices sit in panels, it is possible that a nonunanimous decision
is reached." While it has been shown that reelection concerns increase the probability of an
overturned conviction, they may also lead to split decisions that result in affirmation (but
unable to achieve a majority in favor of reversal or modification). To consider this possibil-
ity, the variable ORDER is created. I define it so that ORDER = 3 if the decision is unanimously
affirmed, ORDER = 2 if affirmed (not unanimously), ORDER = 1 if reversed or modified (not
unanimously), and ORDER = 0 if unanimously reversed or modified. An increase in this
variable represents more support for the lower court's decision. The mean value of ORDER
is 2.511. Table A3 in the Appendix provides a full breakdown.
Table 3 presents the ordered probit results. A constant term is included and not
reported and robust standard errors are presented.
The results in Table 3 confirm those found in Table 2. A conviction during a District
Attorney's reelection campaign is associated with a decreased probability of being upheld
by the appellate court. In fact, the statistical significance of REELECT is enhanced.
'Control variables used in the alternative specification are: population in 2012; change in population since 2010;
population density; proportion of the population under 18, over 65, female, white, black, Native American, Hispanic,
with a high school diploma, with a college degree, and below the poverty line; homeownership rates, and income per
capita. Regarding the criminal and political controls, the proportion of votes Obama received relative to McCain;
number of violent crimes per 1,000 people; number of property crimes per 1,000 people; number of ADAs; and the
number of supporting staff (where part-time equals on-half of a person) are included.
"Additionally, sUbsamples of differing crimes are considered. The timing and magnitude of the effect differs across
various categories of crimes. For crimes such as DWils, the effect may begin before May, while assaults show a strong
effect in the six-month window but no effect prior. These additional results are available from the author upon
request.
21n the data set, 2.35 percent of decisions are not unanimous.
705
--- END PAGE 11 ---