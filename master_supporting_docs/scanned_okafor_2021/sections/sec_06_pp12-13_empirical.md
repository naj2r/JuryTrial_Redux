# Section: Empirical
**PDF pages:** 12–13
**Split method:** headers

---

--- PAGE 12 ---
DRAFT PAPER - PLEASE DO NOT COPY OR DISTRIBUTE
Table 1: Annual State Prison Sentencing Outcomes, By County
Mean
Median
Standard
Deviation
Admissions/1000 Population
All Offenses
1.68
1.21
2.83
Violent Offenses
0.42
0.31
0.70
Drug Offenses
0.50
0.30
1.21
Property Offenses
0.63
0.48
0.87
Sentenced Months/1000 Population
All Offenses
141.73
99.32
215.02
Violent Offenses
65.61
42.86
115.62
Drug Offenses
37.03
18.81
74.35
Property Offenses
40.40
27.75
52.37
Notes: Data cover roughly 1986–2006 and 42,500 county-years.
4
Empirical Strategy
In this paper, I adopt a quasi-experimental research design to estimate the effects of
election cycles on the decision-making of district attorneys. County-level variation in the
timing of district attorney elections resulted in substantial variation across counties that I
exploit using a series of dynamic difference-in-differences specifications:
log(Ycst) = γs + λt +
T−1
X
k=−T
βk1{Rct = k} + Γcst + εcst
(1)
The variable Ycst corresponds to one of two outcome variables—(1) admissions/ capita or (2)
months sentenced/capita—evaluated for county c in state s in time period t.11 Time period t
is evaluated in either years or in months. On the right-hand-side, let Rct = t−Ec denote the
“relative time”—the number of periods relative to the nearest election period for the district
attorney in county c in time period t. T equals half the length of a district attorney’s term in
11. Following the approach of Lim, Snyder Jr, and Str¨omberg (2015), all life sentences and death penalties
are coded as a 1200-month sentence.
11
--- END PAGE 12 ---

--- PAGE 13 ---
DRAFT PAPER - PLEASE DO NOT COPY OR DISTRIBUTE
office.12 γs are state fixed effects, λt are year fixed effects, and Γcst is a vector of controls.13
The standard errors are corrected for correlation across district attorneys and over time in
a given county by clustering at the district level.
The coefficients of interest are βk for k ̸= normalized time period. I indicate in each
section below which election cycle time period corresponds with the normalized time pe-
riod. For example, if I normalize such that β0 = 0, that would mean for a district attorney
serving in county c in time period t, all βk coefficients for k ̸= 0 would estimate the sen-
tencing outcomes relative to the sentencing outcomes during the election period. I measure
the dependent variable in logs, which yields regression estimates that can approximate the
percentage difference in sentencing outcomes.14
I first estimate these models using the NCRP data for which I also have data on the cor-
responding prosecutor from the National Directory of Prosecuting Attorneys.15 The NCRP
data contain offender-level information, such as BJS offense category, total sentence, county,
and state where sentence imposed.
The sample for each year consists of all states that
reported data who had four-year election cycles.16
The key identifying assumption for difference-in-differences estimation strategies is the
common trends assumption, which in this case is that any differential change in outcomes
in district attorney election years is the result of the district attorney election. Perhaps the
greatest challenge to this identifying assumption is the confounding effects of other relevant
12. The length of a district attorney term in office is determined by the state and usually equals four years
(since -2 and +2 are functionally equivalent in this specification, the index of summation ends at T −1).
Furthermore, only one state was found that had their district attorney term length change during the time
period under analysis, Arkansas. Arkansas Prosecuting Attorneys were elected for 2-year terms until about
2001; Amendment 80 §20 of the Arkansas Constitution (passed in 2001) modified the Prosecuting Attorneys’
term limits to 4 years.
13. The main results persist even with inclusion of controls such as white share of the population and per
capita income.
14. A log point estimate of a approximates a (100·a)% effect when the magnitude of a is small. The formal
definition of log points holds that an estimate of a corresponds with a multiplicative effect of ea.
15. The years of coverage correspond to the full term length for all prosecutors who were in office between
1987 and 2005. The states of coverage consist of the entire United States, except for the states with non-
elected DAs—Alaska, Delaware, Connecticut, and New Jersey.
16. See Appendix Table A.1 for the number of total reporting states by year in the NCRP dataset. All
years from 1986–2006 include data on over 44 states in the United States, with over 1/3 including all 50
states. Limiting to states with four-year election cycles yields a sample of 39 states.
12
--- END PAGE 13 ---