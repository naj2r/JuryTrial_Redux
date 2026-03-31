# Section: Results (Part 2)
**PDF pages:** 12–15
**Split method:** headers
**Note:** This is part of a longer section, sub-split to ensure deep reading.

---

--- PAGE 12 ---
706 
McCannon
Table 3: 
Results (Ordered Probit; N= 1,874)
A 
B
REELECT 
-0.313*** (0.117) 
-0.248** (0.119)
APPELLANT 
1.297*** (0.264) 
1.415*** (0.274)
PAGES 
-0.466*** (0.049) 
-0.472*** (0.052)
GAP 
-0.003 (0.002) 
-.0.005** (0.002)
SUPREME 
-0.005 (0.091) 
-0.069 (0.098)
MISSING5 
-0.618 (0.522) 
-0.315 (0.514)
Controls
crime 
YES 
YES
defense 
YES 
YES
mode 
YES 
YES
grounds 
YES 
YES
appellate 
YES 
YES
Fixed effects
county 
NO 
YES
year 
NO 
YES
AIC 
1870.5 
1885.2
% correctly predicted 
83.3% 
83.3%
NOTE: QML standard errors in parentheses. ***p<0.01; **p<0.05;
*p<0.10.
While not presented, similar results arise if only contested reelections are considered.
In the data set, 65.8 percent of the observations with REELECT = 1 occur with an incumbent
contested in the election by a candidate of the opposing political party. If the specification
in Column I in Table 2 is reestimated, the marginal impact of a contested reelection is -5.3
percentage points. The coefficient on this new variable using the specification in Column
I of Table 3 in the ordered probit model is -0.247.
One may also be concerned that a bias arises caused by resources available to appeal
a conviction. Previous research has shown that the cases that are appealed are not repre-
sentative of the initial trials (Eisenberg 2004) in civil cases and outcomes of criminal cases
differ based on the type of defensive representation one has (Huang et al. 2010). Individ-
uals who have more financial resources are expected to be able to mount a more substantial
defense. Consequently, appeals made by those with more resources can be expected to be
more successful. Although socioeconomic characteristics of the convicted defendant are
not available, eligibility for publicly provided legal defense in New York is provided for
low-income individuals. Thus, one would expect those who have private legal defense to
differ from those who use public services. Those, though, that qualify for public defense
may, of course, choose to employ their own private representation. Hence, one can be
worried that unobserved sources of variation in defense could be correlated with unob-
served variation in the appeal decision.
To account for this possibility, a Heckit model is estimated. A similar method is
employed by Helland and Tabarrok (2000) when investigating tort awards where selection
into judge or jury decisions is made. The binary selection variable considered is whether or
not private legal defense is employed. Which crime is committed is expected to be correlated
--- END PAGE 12 ---

--- PAGE 13 ---
Prosecutor Elections, Mistakes, and Appeals
Table 4: 
Type of Appellate Adjustment (Binary Probit;
N= 1,874)
Dependent Variable 
= MODIFIED 
= REVERSED
REELECT
coefficient 
0.233* 
0.139
standard error 
(0.133) 
(0.166)
marginal effect 
[0.032] 
[0.0131
Controls
crime 
YES 
YES
defense 
YES 
YES
mode 
YES 
YES
grounds 
YES 
YES
appellate 
YES 
YES
Fixed effects
county 
YES 
YES
year 
YES 
YES
NOTE: QML standard errors in parentheses. ***p<0.01; **p<0.05;
*p< 0 .
1 o.
with income levels. Hence, type of crime is used to estimate the likelihood of a private defense
being utilized. Taking into consideration the selection effect due to socioeconomic differ-
ences, the statistical significance of REELECT in a Heckit estimation continues to be negative
and highly statistically significant." Thus, the selection of type of defense does not affect the
significance of the election pressures on the accuracy of the lower court outcome.
A natural question that arises is: Given that fewer convictions are upheld, what type
of adjustments are made? Two dummy variables are created. The variable MODIFIED equals
1 if the appellate court modified (either unanimously or not) the decision, while REVERSED
equals 1 if it was reversed. For the full sample, 58 percent of cases not upheld are modified
(see Table A3 in the Appendix). Partitioning the sample, for observations with REELECT = 1,
64.1 percent of decisions not upheld are modified, leaving 35.9 percent reversed. In the
subsample of data with REELECT = 0, only 57.3 percent of adjustments come from modifi-
cations. This is suggestive of the dominant type of mistake made. To formalize this, a probit
analysis is undertaken to estimate the ability of REELECT to explain MODIFIED and REVERSED.
Table 4 presents the results decomposing the effect of prosecutor elections.
Thus, it can be estimated that 71 percent (= 0.032/ [0.013 + 0.032]) of the increase
in overturned lower court decisions comes from the modification of the sentence, while 29
percent of the marginal effect of a reelection campaign comes via reversing the lower
court's decision. The statistical insignificance of the effect of reelection concerns on
reversals can, potentially, be explained by the relatively few observations (only 7.2 percent
of the sample).
Now that it has been established that reelection campaigns affect the likelihood of an
overturning of a lower court's decision (through modifications typically), another follow-up
-The coefficient on REELECT from the Heckit estimation is -0.088 with a standard error of 0.045 and a pvalue of 0.05.
707
--- END PAGE 13 ---

--- PAGE 14 ---
708 
McCannon
Table 5: Jury Trials Versus Plea Bargains (Binary Probit)
JURY = 1 
I.FA 
0
Subsample 
A 
B 
C 
D
REELECT
coefficient 
-0.059 
-0.071 
-0.371 
** 
-0.607 **
standard error 
(0.212) 
(0.253) 
(0.167) 
(0.210)
marginal effect 
[-0.016] 
[-0.015] 
[-0.080] 
[-0.112]
Controls
independent variables 
YES 
YES 
YES 
YES
crime 
NO 
YES 
NO 
YES
defense 
NO 
YES 
NO 
YES
grounds 
NO 
YES 
NO 
YES
appellate 
NO 
YES 
NO 
YES
Fixed effects
county 
NO 
YES 
NO 
YES
year 
NO 
YES 
NO 
YES
McFadden If 
0.122 
0.270 
0.118 
0.291
AIC 
544.8 
594.4 
594.2 
603.7
% correctly predicted 
80.7% 
82.8% 
88.3% 
88.2%
N 
605 
605 
885 
885
NOTE: QML standard errors in parentheses. ***p<0.01; **p< 0.05; *p<0.10.
issue to investigate is in which environments do the changes occur. First, consider the mode
of conviction. One would suspect that the decision making and potential for mistakes is
significantly different in jury trials as compared to plea bargains. One could argue, for
example, that trials provide the opportunity for the prosecutor to influence nonprofession-
als in ways that would not be possible if only dealing with a legal representative of a
defendant. Alternatively, one may believe that a stricter set of guidelines can be adhered to
in the courtroom. For example, evidence and arguments can be presented and made at the
bargaining table that would not be permissible at trial.
Tables Al and A2 in the Appendix not only report the crimes committed and
grounds of appeal for the full sample, but also disaggregate them by separating out the
subsample of appeals that arise from ajury trial conviction (N'= 605). Most crime catego-
ries are shown to come equally from jury trial convictions and plea bargains. Exceptions
include serious crimes such as unlawful imprisonment, reckless endangerment, kidnap-
ping, endangering the welfare of a minor, and murder. The significant difference is in the
grounds of appeal. The arguments put forth by the convicted appellant depend on the
mode of conviction that arises.
Therefore, to separate the effect of reelection pressures on cases that go to trial versus
cases where a plea bargain is reached, the econometric model specified in Table 2 is
reestimated but considering, independently, only the sample of plea bargained cases that
are appealed and the sample ofjury trial convictions contested. Table 5 presents the results
of the probit model with UPHELD as the dependent variable, a constant term included in
each specification, and robust standard errors reported.
--- END PAGE 14 ---

--- PAGE 15 ---
Prosecutor Elections, Mistakes, and Appeals
709
Table 6: 
Interaction Terms (Binary Probit; Dependent Variable = UPHELD; N= 1,874)
Grounds 
Defense 
Cme
speedy 
0.023 (0.365) 
LAS 
0.277* (0.167) 
dwi 
0.242 (0.225)
[0.005] 
[0.054] 
[0.044]
speedy x reelect 
-1.869** (0.948) 
LAS x reelect 
-0.031 (0.337) 
dwi x reelect 
-1.234** (0.593)
[0.638] 
[0.013] 
[-0.407]
assault 
0.243* (0.148)
[0.045]
assault X reelect 
-0.819** (0.397)
[-0.244]
fraud 
-0.285 (0.275)
[-0.068]
fraud x reelect 
-6.506*** 
(0.601)
[-0.876]
Note: QML standard errors in parentheses. ***p<0.01; **p<0.05, *p<0.10
For the sample of jury trial convictions, reelection pressures have a negative but
statistically insignificant effect. For those cases where a guilty plea was entered, interestingly,
substantially fewer convictions appealed are upheld. In the full model in Table 5 (Column
D), the likelihood of a conviction being affirmed decreases by over 11 percentage points.
Within the sample of appealed guilty pleas, the mean value of UPHELD is 0.8768 (as
compared to 0.7934 in the jury sample). Thus, this represents a 12.8 percent reduction in
the rate of affirmation. This is evidence that the impact of the prosecutorial zeal is felt most
heavily in the pretrial interaction between the DA and the accused. The courtroom acts to
mitigate these effects.
Second, to achieve a more complete understanding of the environment in which
mistakes in the criminal justice system occur, the circumstances of the crime and process
need to be considered. To analyze this, I interact the reelection variable with the variables
in each grouping of controls. Table 6 presents the results from each specification. Only the
control variable where the interaction term is statistically significant is presented."' Each
specification includes REELECT, the independent variables, all control variables, year effects,
and county fixed effects.'" Additionally, robust standard errors are calculated and marginal
effects are presented in the brackets of Table 6.
With regard to the grounds used by the appellant, the only one that can be shown to
have a significant interaction effect with REELECT is appeals claiming one did not receive a
speedy trial. The negative and statistically significant interaction term signifies that if a trial
took place while the prosecutor was running for reelection and later was challenged on the
grounds that the prosecution took too long, there is a decrease in the probability that the
"Each column represents a separate probit model estimation considering the interaction with one set of control
variables.
1n the third colunn, a number of crimes have no observations during a reelection campaign. They are ANIMAL
CRUELTY, ARSON, ESCAPE, HARASSMENT, MENACING, POSSESSION OF STOLEN PROPERTY, RECKLESS ENDANGERMENT, and
TRESPASS. These interaction terms are, obviously, omitted.
--- END PAGE 15 ---