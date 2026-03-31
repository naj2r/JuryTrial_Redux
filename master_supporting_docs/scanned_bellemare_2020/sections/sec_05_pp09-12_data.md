# Section: Data
**PDF pages:** 9–12
**Split method:** headers

---

--- PAGE 9 ---
4
Data and Descriptive Statistics
After developing your theory of change, you have presumably gone in search of data
to test the predictions of that theory. As with writing formal theoretical models, entire
books have been written about the dos and don’ts of data collection (see Deaton 1997 or
Glewwe and Grosh 2000 for survey data; see Gerber and Green 2012 or Glennerster and
Takavarasha 2013 for randomized controlled trials), so this section will not discuss where
the data come from to assume instead that you have them. Rather, this section will focus
on how to present your data in the context of an applied economics article.
The best Data and Descriptive Statistics sections answer all of the reader’s questions
about the data themselves. Speciﬁcally, a good Data and Descriptive Statistics section
ﬁrst discusses where the data come from, when they were collected, by whom, how the
observations that compose the sample were chosen for inclusion (i.e., the survey method-
ology, or how regions, communities, households, individuals, etc. were all chosen), what
population the sample is representative of, what the target sample size was and how that
sample size was determined (e.g., via power calculations), what the actual sample size is,
what the nonresponse rate was, what the attrition rate is in case the data are longitudinal,
how missing data were dealt with (e.g., whether observations were simply dropped, or
whether some values were imputed and, if so, how the imputation was done). Broadly
speaking, the information presented here allows the reader to judge the external valid-
ity of the results contained in a paper (and sometimes their internal validity, as is the case
when the data suffer from attrition), or how those results might be used for out-of-sample
predictions.
After presenting those basics, a good Data and Descriptive Statistics section introduces
all the variables used in the paper (and no variable not used in the paper) by precisely and
concisely explaining what they measure, and how they do so. For instance, in many rural
areas of developing countries, people derive their income from many difference sources.
So if “income” is included in the analysis, the reader needs to be told what the various
9
--- END PAGE 9 ---

--- PAGE 10 ---
income sources are.
This may seem tedious—and if it seems tedious to you as writer, you can imagine
what it seems like to the reader—but it can nevertheless contain crucial information. For
instance, an age-old question in the literature on agricultural development, and one on
which I have done quite a bit of work is whether participation in agricultural value chains
(via contract farming, as a grower) makes participating households better off (see Belle-
mare and Bloem 2018 for a review). This is usually assessed by regressing a measure of
household income (as a proxy for welfare) on a dummy for whether the household partic-
ipates in contract farming. Without knowing what the components of household income
are, however, it is impossible to know whether it includes income from contract farming
(in which case there is an obvious reverse causality problem) or not (in which case reverse
causality is much less of a problem).
The good news is that it is relatively easy to present that information when one has
access to the survey questionnaires that were used to collect the data, which is almost al-
ways the case. Moreover, one way of presenting that information optimally is by creating
a table of variable descriptions, where each line is a speciﬁc variable retained for analysis,
where the ﬁrst column gives the name of that variable (and the unit of measurement in
parentheses), and where the second column gives precise measurements. Figure 1 shows
one such table. This allows presenting a lot of required but tedious information in a com-
pact manner, which minimizes reader discontent: Those who want to know all there is
to know about the data can read the table, and those who do not can just skip it to focus
instead on variable names.
After presenting the foregoing, it is time to present and discuss descriptive statistics.
Here, whereas it used to be sufﬁcient to simply present a table of means and standard
deviations, it has become practically necessary in cases where the variable of interest (i.e.,
the treatment variable) is composed of a small number of categories to show the results of
balance tests, viz. tables where each line is a variable retained for analysis, where means
10
--- END PAGE 10 ---

--- PAGE 11 ---
FIGURE I: Example Table of Variable Descriptions from Bellemare (2012).
and standard errors are shown conditional on treatment status, and wherein one assesses
whether the mean of each variable systematically differs across treatment statuses by re-
porting p-values for a test of difference in means. Though the textbook example involves
two treatment statuses—treatment and control—it is increasingly common for studies to
include more than two treatment arms, and so any meaningful balance test must be re-
ported for each pairwise comparison of means. With two treatment arms, this means
(i) treatment 1 versus control, (ii) treatment 2 versus control, and (iii) treatment 1 versus
treatment 2.
With experimental data, the idea behind such balance tests is to show the reader that
randomization was done properly. With observational data, where we would not expect
the data to be balanced, the idea behind such balance tests is to assess how unbalanced the
data are—an idea which comes from the matching literature (Morgan and Winship 2015).
With perfect random assignment across treatment and control groups, there should be
fewer than 1 in 10 pairwise comparisons differing at less than the 10 percent level of sta-
tistical signiﬁcance, fewer than 1 in 20 pairwise comparisons differing at less than the
20 percent level of statistical signiﬁcance, and fewer than 1 in 100 pairwise comparisons
different at less than the 1 percent level of statistical signiﬁcance. In cases where pair-
11
--- END PAGE 11 ---

--- PAGE 12 ---
wise comparisons return too many systematic differences, one should ideally control for
the relevant covariates in a regression or matching context when estimating treatment
effects.7
Beyond the usual table of means and standard deviations and one or more tables
showing the results of balance tests, a good Data and Descriptive Statistics section can
also be used to explore the data nonparametrically by showing kernel density estimates
of the relevant variables (i.e., outcome and treatment variables at a minimum, but also
controls suspected to be the source of treatment heterogeneity) when they are continu-
ous, histograms of the relevant variables when they are categorical, or cross-tabulations
(i.e., two-by-two tables) in cases where both the treatment and the outcome are both bi-
nary.
When writing a Data and Descriptive Statistics section, there are a few important mis-
takes you should avoid making. The ﬁrst such mistake is for the write-up to present
a bland enumeration of means. If a gender variable is merely used as a control in the
analysis, there is little use to stating in the text that “37.4 percent of respondents are fe-
male”when the reader can look that up for herself; the only variables that typically de-
serve discussion here are the outcome and treatment variables, any variable that is used
for identiﬁcation (e.g., an instrumental or forcing variable), or anything that really stands
out. Generally, a good rule of thumb is to keep the discussion of the descriptive statistics
to a few sentences.
The second such mistake is the use of the past tense in discussing the data and descrip-
tive statistics. The example above stated how “37.4 percent of respondents are female,”
and not how “37.4 percent of respondents were female.” Scientiﬁc communication in En-
glish is more effective when using the present tense to discuss one’s data or results, and
7Comparing means across treatment and control groups is the strict minimum when it comes to testing
for balance. A more restrictive approach consists in running a joint test (i.e., F-test) of whether all means
are simultaneously the same across groups. Another more restrictive approach consists in conducting tests
of equality of distributions for pairwise comparison using a Kolmogorov-Smirnov test or using Bera et al.’s
(2013) smooth test for equality of distributions.
12
--- END PAGE 12 ---