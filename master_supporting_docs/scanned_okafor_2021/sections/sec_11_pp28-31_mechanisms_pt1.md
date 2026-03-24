# Section: Mechanisms (Part 1)
**PDF pages:** 28–31
**Split method:** headers
**Note:** This is part of a longer section, sub-split to ensure deep reading.

---

--- PAGE 28 ---
DRAFT PAPER - PLEASE DO NOT COPY OR DISTRIBUTE
5.4.4
Other Robustness Checks
I also performed additional robustness checks. For example, the findings in this study
are robust to specifications in which the set of controls—white share of the population and
income—are not included. The findings are also robust to county (instead of state) fixed
effects. Also, the shape of the curve depicting the relationship between the election cycle
and criminal sentencing outcomes is preserved under a log transformation—log(1+x)—of the
data; the utility of this transformation is that it prevents zeros from being omitted from the
regression analysis. See the Appendix for graphs of the primary election cycle analyses with
log transformations.
6
Mechanisms on Public Sentiment
The results thus far document that the admissions rate per capita and the rate of total
months sentenced per capita increase in the lead up to general elections during an era of
rising incarceration (roughly 1986 to 2006). In this section, I perform additional analysis to
shed light on various mechanisms that underlie the relationship between DA election year
sentencing outcomes and public sentiment. The analysis uncovers five key facts, described
in more detail below: (1) DA election effects vary by region and are concentrated in the
South Central U.S.; (2) DA election effects depend on county political ideology more than
DA ideology, with effects larger in contested elections; (3) anti-Black/pro-White county-level
bias associated with greater punitiveness on black prisoners throughout the entire election
cycle; (4) DA election effects declined in the era of rising incarceration, coinciding with
softening public opinion on punishment; and (5) DA election effects disappeared at the
national level after the era of rising incarceration ended. Taken together, these facts provide
evidence of a nexus between public sentiment and sentencing outcomes.
27
--- END PAGE 28 ---

--- PAGE 29 ---
DRAFT PAPER - PLEASE DO NOT COPY OR DISTRIBUTE
6.1
DA Election Effects Vary by Region and are Concentrated in
South Central U.S.
To begin our spatial analysis of the election year effects, let us return to the monthly
sentencing outcome analysis from Section 5.2. For this spatial analysis, I seek to also use
a second modeling approach since there is comparatively less data available for any given
region. Hence, the objective here is to estimate the magnitude of the election period effect
given the relative time from an upcoming election. To capture potential non-linearities, I
first fit a LOESS regression to the non-parametric conditional expectation functions plot-
ted previously in Figure 5 to find a transformation of relative time from an election that
renders the relationship between sentencing outcomes and relative time linear.22 Through
22. As described in (Chetty et al. 2018), this estimation approach is analogous to a Box-Cox transformation.
The main assumption underlining this estimator is that the shape of the conditional expectation of the
outcome is preserved in each county up to an affine transformation.
Figure 8: Parameterizing Sentencing Outcomes
Notes: Graph depicts a dynamic difference-in-differences model (population weighted to adjust for differences
in sampling probabilities across districts and across time). Estimates are at the county level by year. Jagged
lines demarcate 95% confidence intervals. Estimates include state- and year- fixed effects. Plot includes
non-parametric LOESS best-fit line and parametric sinusoidal model.
28
--- END PAGE 29 ---

--- PAGE 30 ---
DRAFT PAPER - PLEASE DO NOT COPY OR DISTRIBUTE
observation of Figure 8, an appropriate transformation appears to be sinusoidal. Hence, one
approach I use in this section is to estimate partial effects on the amplitude A from the
following specification evaluated with time t in years (since differences in the A parameter
roughly correspond to differences in the magnitude of election year effects):
log(Ycst) = γs + λt + A · sin(2πRct/4 + ϕ) + εcst
(3)
A second approach I use is the static difference-in-differences model from Equation 4
below, evaluating the β parameter:
log(Ycst) = γs + λt + βDct + Γcst + εcst
(4)
The dependent variable Ycst corresponds to one of two outcome variables—(1) admissions/capita
or (2) months sentenced/capita—evaluated for county c in state s in year t. On the right-
hand-side, let Dct denote the treatment, which is an indicator variable denoting whether
county c is in an election year in year t. γs are state fixed effects, λt are year fixed effects,
and Γcst is a vector of controls.23 The standard errors are corrected for correlation across
district attorneys and over time in a given county by clustering at the district level.
Based on the two approaches from Equation 3 and Equation 4, I examine how election
effects vary by geographic region. Figure 9 shows election year effects by region for both
outcome variables, with the maps on the lefthand side shaded according to partial effects from
the static difference-in-differences model (Equation 4). The righthand side of the figure shows
the corresponding partial effects based on both the static diff-in-diff model and the sinusoidal
model (Equation 3), evaluated with the time period in years. One can see that the largest
election year effects on admissions rate is consistently in the South Central region of the U.S.
(east and west). Furthermore, these effects significantly differ from zero for both modeling
23. Again, the main results persist even with inclusion of controls such as white share of the population
and per capita income.
29
--- END PAGE 30 ---

--- PAGE 31 ---
DRAFT PAPER - PLEASE DO NOT COPY OR DISTRIBUTE
Figure 9: Election Year Effects By Region
Notes: Map shading depicts a static difference-in-differences model (population weighted to adjust for differ-
ences in sampling probabilities across districts and across time). Estimates are at the county level by year.
The standard errors are corrected for correlation across district attorneys and over time in a given county
by clustering at the district level. Estimates include state- and year- fixed effects. Horizontal lines mark
two standard errors. Heterogeneity across regions calculated via a static difference-in-difference model and
a sinusoidal model, respectively.
30
--- END PAGE 31 ---