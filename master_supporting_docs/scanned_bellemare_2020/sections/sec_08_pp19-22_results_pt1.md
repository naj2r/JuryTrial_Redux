# Section: Results (Part 1)
**PDF pages:** 19–22
**Split method:** headers
**Note:** This is part of a longer section, sub-split to ensure deep reading.

---

--- PAGE 19 ---
how much you wish those claims to be true.11 Editors and reviewers would much
rather deal with manuscripts wherein the author candidly admit to the limitations of
their ﬁndings than with manuscripts wherein the authors try to deceive the reader.
In plain English: The former kind of manuscript has a much better chance of not
being rejected than the latter.
6
Results and Discussion
The section of an applied economics article that discusses the paper’s ﬁndings is obvi-
ously the most important section of the paper. Somewhat paradoxically, it is perhaps also
the least read section of a paper: After a reader has read the title, the abstract, the intro-
duction, looked at a few tables, and maybe looked at the empirical framework section to
answer her lingering question, your reader knows whether she can trust you and your
ﬁndings, and she is often only interested in your core ﬁnding. Only reviewers and crit-
ical readers (e.g., graduate students reading your paper for a class, should your article
end up on someone’s syllabus, or for their dissertation) will read the entirety of the re-
sults section. Nevertheless, results sections have their own structure, which is discussed
below.
6.1
Order of Results
There is a certain logical order in which results should be presented. Typically, results
progress from most parsimonious (e.g., a simple, bivariate regression of y on D) to least
parsimonious (i.e., a regression of y on D and a full set of control variables x). With
experimental variation in D, this is not as useful as with observational variation in D. In
the former case, adding controls on the right-hand side of the equation of interest will in
11The proper conduct of social science dictates that one should not wish that one’s ﬁndings should go in a
particular direction. Research economists should strive to be ﬁrst and foremost scientists, and not advocates
for a certain position.
19
--- END PAGE 19 ---

--- PAGE 20 ---
principle not change the sign and the magnitude of the estimated treatment effect. Rather,
it will only make the estimate of the treatment effect more precise (i.e., it will reduce the
standard error around it).12
In the latter case, where one cannot assume that E(y|x) = E(y|do(x)), the most-to-
least-parsimonious approach is one ﬁrst step toward assessing the robustness of one’s
results: If the sign and the magnitude do not change much or at all as one adds in control
variables on the right-hand side, this suggests that one’s results are already somewhat
robust. This is in the spirit of Altonji et al.’s (2005) approach to robustness (although
Oster 2019 critiques Altonji et al. 2005 and suggests a new method aimed at assessing
how important unobserved heterogeneity is in a given application).
6.2
Robustness Checks
After presenting the core results in a paper, it is time to turn to robustness checks. Though
there was a time where it was sufﬁcient to present one or two tables of empirical results
to convince the reader that there was a “there” there, times have changed, and as a conse-
quence of the Credibility Revolution (Angrist and Pischke, 2010), standards of evidence
are considerably higher than they were in the early to mid-2000s. Authors now have to
work hard to convince readers that their results were not cherrypicked, which means that
establishing the robustness of a ﬁnding involves its own song and dance.
In many cases, the outcome we are interested in has more than one measurement.
“Welfare,” for instance, can be measured in a number of ways: household income, house-
hold income per capita, household income per adult equivalent, household consumption
expenditures, household consumption expenditures per capita, household consumption
expenditures per adult equivalent, subjective well-being of the respondent, etc. If you
have access to all seven of those measures of “welfare,” one ﬁrst step toward establishing
12A colleague who has run numerous RCT notes that in his experience, adding controls tends to have al-
most no effect on the standard errors, with the only exception being when the baseline value of the outcome
is added as a control variable in an ANCOVA setup (McKenzie 2012).
20
--- END PAGE 20 ---

--- PAGE 21 ---
that your result is robust might be simply to re-estimate your core equation for all seven
of those measures, showing that the result holds across all seven of them.
Similarly, you may have different measures of the treatment variable. In most ran-
domized controlled trials, there is one (and only one) treatment variable (unless there are
several treatment arms, and unless those treatment arm are interacted). But with obser-
vational data, it might be possible to look at different measures of the treatment variable.
In the contract farming literature, for example, one can look at whether a household par-
ticipates in contract farming (i.e., contract farming at the extensive margin), but one could
also look at the proportion of one’s crop acreage that is under contract (i.e., contract farm-
ing at the intensive margin).
Now imagine that you have those two measures for the treatment variable, and the
aforementioned seven measures for the outcome variable. This allows estimating 14 dif-
ferent speciﬁcations of the core equation of interest! If the ﬁnding holds for each and
every one of those speciﬁcations, that goes a long way toward establishing that a ﬁnding
is robust.
One can also check for robustness by conducting placebo and falsiﬁcation tests. In the
former case, a “fake” treatment (i.e., a variable that is correlated with the treatment, but
which presumably does not cause the outcome) is used in lieu of the actual treatment. In
the latter case, a “fake” outcome (i.e., a variable that is correlated with the outcome, but
which presumably is not caused by the treatment) is used in lieu of the actual outcome.
In both cases, robustness comes from the lack of a statistically signiﬁcant ﬁnding, since a
statistically signiﬁcant ﬁnding hints at the fact that the core results might be spurious.
Yet another kind of robustness check comes in the form of looking at different esti-
mators. Most applied economics articles, for instance, rely on some linear, fully para-
metric regression. If the treatment is continuous, it might be useful to estimate speciﬁca-
tions that allow for a more ﬂexible functional form (e.g., a restricted cubic spline), which
would allow one to determine whether the relationship between y and D is generally
21
--- END PAGE 21 ---

--- PAGE 22 ---
monotonic. Very often, robustness checks of this kind are where modest methodological
contributions—a paper’s third contribution, as listed in the introduction—come from.
6.3
Treatment Heterogeneity
It is almost never the case that the treatment effect we are interested in estimating is homo-
geneous across the population of interest. After assessing the robustness of your results,
you may be interested in looking at whether the treatment varies for various sub-groups
(e.g., men vs. women, rural vs. urban, black vs. white, by income quintile, etc.) This
section is where this is assessed. Keeping with the contract farming example, suppose
you were interested in whether the impacts of contract farming differ between male and
female respondents. This alone would bring the number of estimated speciﬁcations up to
28 (i.e., seven measures of welfare, two treatment measures, and male vs. female respon-
dents). From this, it is rather it easy to see why the average applied paper is now typically
50 pages—if not longer.
One good thing about exploring treatment heterogeneity is this: Very often, doing so
can salvage a null ﬁnding (i.e., an effect that is statistically insigniﬁcant) because average
effects can mask a tremendous amount of heterogeneity. One of my students, for instance,
was interested in looking at the effects of introducing soup kitchens on food insecurity in
Mexico. Looking at the whole sample yielded nothing interesting, as her estimated effects
were not statistically signiﬁcantly different from zero. It was only when a colleague sug-
gested that she split up the sample in income quintiles that she found that soup kitchens
were associated with a decrease in food insecurity—but only for the poorest income quin-
tiles. So before calling it quits, saying that an intervention or treatment has had “no ef-
fect,” and abandoning an entire research project, it is well worth thinking about whether
the treatment effect might be heterogeneous, and whether said heterogeneity is of interest
for policy or business.
22
--- END PAGE 22 ---