# Section: Results (Part 2)
**PDF pages:** 23–26
**Split method:** headers
**Note:** This is part of a longer section, sub-split to ensure deep reading.

---

--- PAGE 23 ---
6.4
Mechanisms
As a result of the Credibility Revolution (Angrist and Pischke, 2010), applied microe-
conomists have been answering questions of the form “Does D cause y?” or “What is the
effect of D on y?” ﬁrst and foremost.
FIGURE II: Direct and Indirect Mechanisms
m
D
y
In recent years, however, much has been written in the quantitative social science
literature about how to test for whether a given variable m is a mechanism whereby some
other variable D causes some outcome y—what is called mediation analysis—and this
remains a very active area of research.
To start with, readers should read the paper by Acharya et al. (2016), which develops
a method which, under certain assumptions, allows determining for the directed acyclic
graph (Pearl 2009) in Figure I (i) what is the indirect effect of D on y, i.e., D −→m −→y,
(ii) what is the direct effect of D on y, i.e., D −→y, and (iii) whether m is the only
mechanism whereby D causes y, or whether there are multiple such mechanisms.
A good section on mechanisms does its best to investigate potential mechanisms. In
the best-case scenario, this involves a proper mediation analysis. In many cases, this
means doing what one can do with the data at hand, such as presenting descriptive (i.e.,
not causally identiﬁed) regressions or correlations. In other cases, this means simply ad-
mitting that there are some mechanisms one cannot test for, not even with imperfect
proxies. When anything but the ideal is feasible, you should clearly explain why you
cannot test for speciﬁc mechanisms to leave no doubt in your readers’ minds that you
have thought about the question “How does D cause y?”
23
--- END PAGE 23 ---

--- PAGE 24 ---
6.5
Limitations
A good empirical results section should be honest about what it can and cannot do.
Though this is often discussed quickly in the conclusion, it should be discussed more
fully in a separate sub-section of the estimation results section.
What limits one’s results? Typically, limitations come in three varieties. First and fore-
most, internal validity may be limited. In other words, one might not be able to make a
causal statement, but instead only get close to doing so relative to the literature. For in-
stance, your instrumental variable might only be plausibly exogenous, but not strictly so.
This would be a good time to remind the reader that this is so (and you should also have
assessed the effects of departures from strict exogeneity in the robustness checks section
using the various methods laid out in Conley et al. 2012).
Second, external validity may be limited as well. This is often the case with lab or a
lab-in-the-ﬁeld experiments,13 or with randomized controlled trials. Or you may have a
strictly exogenous instrumental variable, but it is not entirely clear who the compliers and
deﬁers are, and so who the local average treatment effect applies to is a nebulous subset
of the sample.
Lastly, the variables you use as your treatment or your outcome variable might only be
proxies for what you are truly interested in. For instance, though you may be interested
in looking at whether economic shocks push people to commit suicide, data on suicides
may not be available (or suicides may be signiﬁcantly under-reported), and so you might
have to resort to using mortality rates instead.
6.6
Tables
Before closing out this section, I would like to discuss some miscellaneous pieces of advice
regarding tables of empirical results. In no particular order:
13Lab-in-the-ﬁeld experiments are lab experiments that are conducted with “real” subjects (e.g., farmers
or managers) in the ﬁeld, outside of the experimental lab.
24
--- END PAGE 24 ---

--- PAGE 25 ---
• The titles of your tables should be self-explanatory: “OLS Results for the Effect of
Participation in Contract Farming on Household Income,” or “OLS Results for the
Effect of Participation in Contract Farming on Income by Gender.” The titles should
thus tell us what is being estimated (e.g., OLS), what the causal relationship of inter-
est is (i.e., the effect of participation in contract farming on household income), and
what subset of your sample, if any, it applies to (i.e., male and female respondents
separately).
• Coefﬁcient estimates and standard errors should be reported with the same number
of decimal places throughout your tables—usually two or three.
• Some people like to omit control variables, preferring instead to include a line that
says “Controls? Yes” in the second (i.e., bottom) half of the table. Though this is
ﬁne to save space in a published article, a working paper should show everything
to the readers (especially the reviewers and the editor). The obvious exception is
for individual, household, or community ﬁxed effects, of which there are usually
too many to list. If you must include a line at the bottom that says “Controls? Yes,”
make sure the notes to the table (i.e., right under the table) include a detailed list
of which controls are included—a careful reader will want to know whether you
condition on colliders or include as control a variable that lies on the causal path
between the treatment and outcome variables.14
• The last lines of the table should list the number of observations, the R2 (I prefer the
usual R2 to the adjusted one, because this tells me how much of the variation in y is
explained by the variables on the right-hand side, without any arbitrary correction
for the number of observations and parameters), maybe the results of a test of joint
signiﬁcance of the variables on the right-hand side, and various lines indicating
14A collider is a variable caused by two separate, possibly unrelated variables. Conditioning on a collider
or on a variable that lies on the causal path between the treatment and outcome variables is problematic
because it introduces bias (Morgan and Winship 2015).
25
--- END PAGE 25 ---

--- PAGE 26 ---
which controls are included (e.g., state ﬁxed effects, a linear time trend, year ﬁxed
effects, state-speciﬁc linear trends, state-speciﬁc quadratic trends, region–year ﬁxed
effects, and so on).
• Finally, the notes to the table should present all symbols for statistical signiﬁcance
(typically, * for statistical signiﬁcance at less than the 10 percent level, ** at less than
the 5 percent level, and *** at less than the 1 percent level; none should be omitted for
completeness and transparency), and additional symbols if necessary. For instance,
you may have adjusted your p-values for multiple comparisons, bootstrapped your
standard errors, or done some randomization inference, all of which would lead to
different inferences and critical levels of statistical signiﬁcance, in which case you
might use the symbols †, ††, and † †† to denote signiﬁcance at less than the 10, 5,
and 1 percent level for this additional version of the standard errors.
• Present estimation results for the same estimation sample. That is, as the number
of control variables increases, the sample size is nonincreasing due to missing vari-
ables. If the sample size decreases as you throw controls on the right-hand side,
this involves and apples-to-oranges comparison (different estimation samples are
representative of different populations). Instead, take your smallest sample size (as
dictated by missing observations) and use that sample for all speciﬁcations.
• For variable names, use plain English words like “Years of education,” “Age squared,”
and “Female” and not Stata or R codenames like “Edu,” “AGE_2,” or “SEX.”
• Ultimately, it always helps to put yourself in your reader’s shoes,15 and the right
question to ask yourself (or a friend who owes you a favor) is this: When given only
the tables, can one write down the exact regression that was estimated? Or is one
15This can be difﬁcult, which is why the best way to learn is to review as many papers for journals as
possible. Many scholars—economists, in particular—see refereeing as an unfortunate tax they need to pay
in order to get their own papers reviewed and published. Unlike a tax, however, there is almost always
something to be learned from refereeing, and from refereeing bad papers in particular.
26
--- END PAGE 26 ---