# Section: Results (Part 2)
**PDF pages:** 18–21
**Split method:** headers
**Note:** This is part of a longer section, sub-split to ensure deep reading.

---

--- PAGE 18 ---
DRAFT PAPER - PLEASE DO NOT COPY OR DISTRIBUTE
during the one year period after the election year. A corresponding regression table is in the
Appendix. The plot shows perhaps the most clear consistent upward trend in the outcome
variable from about 15 months prior to the election through the middle of the election year.
Across months in the same jurisdiction, there may be a common district attorney and similar
regional conditions, yet individual criminal cases are generally unrelated to each other. Thus,
the fact that the dots are close together and increasing in the period immediately preceding
a general election suggests that there is in fact an increasing trend occurring during this time
period.
One can clearly see that all the estimates during the election year are greater than zero,
which is not the case for the time periods before and after the election year—and is also not
true for the time period omitted from the graph, since that period has been normalized to
zero. Also, one can see that the estimates immediately following the election year have the
greatest concentration of estimates below zero (followed by the period preceding the election
year), which is consistent with the prediction from the theoretical model that the sentencing
intensity of district attorneys increases in the election year. Political incentives and their
impact on prosecution may be lowest just after an election concludes.
Figure 5 illustrates a similar plot as Figure 4, except looking at the average across all
offense categories. Again, the corresponding regression tables are in the Appendix. It is
apparent that the sentencing outcomes for both admissions per capita and sentenced months
per capita is higher during the election year period than during the time periods before and
after, which is consistent with the property offense plot from Figure 4. Furthermore, one can
see that just about all the estimates during the election year are greater than zero, which is
not the case for either of the two other time periods included in the graph. Also, one can
see that the estimates immediately preceding the election year are more frequently lower
than the election year period, which is again consistent with the theoretical model from
Equation 5. Specifically, this plot provides evidence that the estimates for both admissions
per capita and sentenced months per capita increase over the election cycle on average. In
17
--- END PAGE 18 ---

--- PAGE 19 ---
DRAFT PAPER - PLEASE DO NOT COPY OR DISTRIBUTE
Figure 5: Monthly Criminal Sentencing Outcomes in Election Cycle
Notes:
Graph depicts dynamic difference-in-differences model estimates using Equation 1 (population
weighted to adjust for differences in sampling probabilities across districts and across time).
Estimates
are at the county level by month. Estimates include state- and year-month- fixed effects. Lines demarcate
95% confidence intervals. Estimates calculated relative to omitted months in election cycle, which are all
normalized to 0. Corresponding regression table is in Appendix Table C.7.
other words, the period immediately following the election has the lowest estimates (with a
negative mean), then the estimates increase in the second year after the election (which has
been normalized to zero), then they increase again in the period immediately preceding the
election year, and then increase again during the election year itself. This is consistent with
the perspective that DAs may respond to political incentives associated with the election
cycle.
One slight puzzle is that there seems to be a single lagging positive estimate that extends
into the last month of the election year (at t = 1) for the admissions rate plot. This slight
jump is not present in the months sentenced plot nor in the property offenses plot from
Figure 4, suggesting it might be due to an alternative offense subcategory. Yet this jump
does not meaningfully represent an outlier, given the confidence intervals of the adjacent
18
--- END PAGE 19 ---

--- PAGE 20 ---
DRAFT PAPER - PLEASE DO NOT COPY OR DISTRIBUTE
estimates.
5.3
Magnitude of Election Year Effects
To interpret the magnitude of the election year effects, I adopt a similar methodology
for signal variance as described in various papers (see, e.g., Chetty and Hendren 2018).
Signal variance (χ2) allows one to interpret the magnitude of election year effects in units
of standard deviations under basic assumptions (based on the underlying distribution of
district attorney sentencing behavior).
I estimate χ2 by subtracting the average sampling variance across district attorneys
(E[s2
ps]) from the variance of the residuals obtained by regressing ˆµs (state fixed effects) on
¯yps (district attorney sentencing outcomes):
χ2
p = V ar(ˆµs −γp(¯yps −¯ys)) −E[s2
ps]
(2)
where ˆµs denotes the causal effect of an election year on sentencing outcomes in state s, ¯yps
denotes the mean sentencing outcomes for district attorney p in state s, ¯ys = E[¯yps] is the
mean of ¯yps across district attorneys within state s, and γp = Cov(ˆµs,¯yps)
V ar(¯yps)
is the coefficient
obtained from regressing ˆµs on ¯yps.18
This procedure yields χ2
admissions = 0.0323 for the admissions rate per capita and χ2
months =
0.0364 for the total months sentenced per capita. I then take the election year estimates
calculated from the static difference-in-differences specification in Equation 4 and compare it
to the (square root) signal variance. Under an additional assumption of normality in district
attorney sentencing outcomes, the estimates for χ2 tell us that, on average, the election year
18. In practice, the basic steps I employ to calculate χ2 are as follows. First, I estimate the mean sentencing
outcomes for each district attorney (¯yps). Second, I compute an estimate of how much variation there is
across district attorneys in sentencing outcomes (within state). I accomplish this by regressing state fixed
effects (ˆµs) on the set of district attorney sentencing outcomes (¯yps), then calculate the Mean Squared Error
from this regression. It is important to realize that this measure of variation across district attorneys within
state is partly driven by noise (e.g., from sampling variation). Consequently, as a third step, I subtract the
amount of variation coming from the noise (E[s2
ps]). To do so, I subtract the average standard error of the
district attorney fixed effects squared.
19
--- END PAGE 20 ---

--- PAGE 21 ---
DRAFT PAPER - PLEASE DO NOT COPY OR DISTRIBUTE
effects on admissions are akin to moving 0.85 standard deviations along the distribution of
prosecutor sentencing behavior within state. This means that with respect to the admissions
rate, being in an election year is akin to going from the 50th percentile of district attorney
sentencing intensity to the 80th percentile. Under similar normality assumptions, the elec-
tion year effects on months sentenced are akin to moving 0.62 standard deviations along the
distribution of prosecutor sentencing behavior, on average. This means that with respect to
the months sentenced, being in an election year is akin to going from the 50th percentile of
district attorney sentencing intensity to the 73rd percentile.
5.4
Robustness Checks
5.4.1
Alternative Weighting for Two-Way Fixed Effects (TWFE) Estimator
Recent research has highlighted that in settings with variation in treatment timing across
units—such as in election cycles—the estimated coefficients in two-way fixed effects regres-
sions can be contaminated by effects from other periods (De Chaisemartin and d’Haultfoeuille
2020; Sun and Abraham 2021). Given this potential problem in the estimation of regression
coefficients in the two-way fixed effects model, in Appendix Section B.0 I adapt an alternative
estimator introduced by Sun and Abraham (2021), which can be applied to my setting de-
spite some superficial differences with the event-study setting they consider. This alternative
estimator is robust to treatment effect heterogeneity. Under this alternative two-way fixed
effects estimator, the magnitude and direction of the election year effects largely remain.
5.4.2
Common Trends Assumption
The key identifying assumption for the difference-in-differences empirical approach used
throughout this Section is common trends. Given the cyclical nature of elections, the common
trends assumption in this context is different than in standard settings with an absorbing
treatment (i.e., where units remain treated once initially treated). In particular, in this
paper’s setting, for the common trends assumption to hold I require that in the absence of
20
--- END PAGE 21 ---