# Section: Empirical (Part 1)
**PDF pages:** 13–16
**Split method:** headers
**Note:** This is part of a longer section, sub-split to ensure deep reading.

---

--- PAGE 13 ---
just as the passive voice should be avoided, so should the past tense, except when sum-
marizing and concluding.
Lastly, another mistake is to present numbers that either have too many decimal places
because they are too small (usually, three decimal places is more than enough and, at
any rate it is always possible to rescale a variable to make its magnitude ﬁt with that
of the other variables) or to present numbers that are hard to interpret in tables, such
as 1.37e + 8, or anything other than units readers are used to deal with (for instance, it
is always possible to express a dollar amount in thousands or hundreds of thousands if
need be). In other words, even if the empirical work regresses the logarithm of income
on the treatment variable, the table of descriptive statistics should report the mean of the
income level, not the mean of the log of income.
Ultimately, although a lot of what goes in a Data and Descriptive Statistics section
might seem like useless posturing, as stated before, a good Data and Descriptive Statistics
section should allow the reader to form reasonable expectations about the sign and the
magnitude of the causal effect of interest, and to get an idea of how that effect is likely to
vary across a given conditioning domain.
5
Empirical Framework
After discussing the data and presenting descriptive statistics, you normally turn to dis-
cussing your empirical framework, i.e., the research design you use to empirically answer
your research question.
An empirical framework consists of two related components: (i) an estimation strategy
(i.e., what is estimated, how it is estimated, and how statistical inference is conducted),
and (ii) an identiﬁcation strategy (i.e., what feature of the data allows making a causal
statement or, if that is not possible, how we know we are getting close to making such a
statement).
13
--- END PAGE 13 ---

--- PAGE 14 ---
5.1
Estimation Strategy
An estimation strategy typically consists of the equations to be estimated in an effort to
answer a research question. Though it may be possible for a savvy reader to recover
the estimated equations in a paper by looking at the tables in a paper, that is not always
possible. At any rate, the amount of work a reader should have to do should be kept to a
minimum, so presenting the equations to be estimated is very much the norm.
Ideally, those equations will be as parsimonious as possible. Although a regression
might include 10 to 15 control variables, it is best to put all of those into a vector x of
control variables. What deserves its own variable in an equation to be shown in an esti-
mation framework? For starters, the dependent variable (labeled y) should be included
along with the treatment variable (labeled either D or T), the (vector of) controls (labeled
x), an intercept term (labeled α), and the error term (labeled ϵ).
Here are, in no particular order, a few other norms that are best followed:
• All variables should have the proper subscripts, usually labeled i, j, k, ℓ, etc. from
the smallest (e.g., individual) to the largest level (e.g., region).
• Latin letters should denote variables. Greek letters should denote coefﬁcients.
• If the estimation strategy sub-section features several different speciﬁcations of the
same equation, coefﬁcients should also have subscripts. In other words, one should
not re-use estimand notation. If β is used to denote the coefﬁcient of interest in a
regression of y on D, it should not be re-used to denote the coefﬁcient of interest in a
regression of y on D and x as well—the two estimands being different, the notation
used to denote them should also be different. This is best done by adding numerical
subscripts to each coefﬁcient, so that in the former speciﬁcation, the coefﬁcient on
D would be denoted β0 and in the latter, β1. Or it can be done by adding letter
subscripts to each coefﬁcient, so that for example βr and βs can respectively refer to
reduced-form and structural estimates of the same coefﬁcient.
14
--- END PAGE 14 ---

--- PAGE 15 ---
• The estimation strategy sub-section should also specify what estimation method is
used to estimate each estimable equation. We are generally interested in E(y|x), but
E(y|x) could be estimated in a number of different ways parametrically, semipara-
metrically, or nonparametrically. With a binary outcome variable, the reader needs
to know whether a linear probability model, a probit, or a logit is estimated. In
cases where it is ambiguous, the estimator (e.g., least squares, maximum likelihood,
or generalized method of moments) also needs to be speciﬁed.
• After presenting the estimable equations, it is a good idea to discuss the relevant
hypothesis tests. In a regression of the form
y = α + γD + βx + ϵ,
(1)
for instance, the relevant hypothesis test would be of the form H0 : γ = 0 versus
HA : γ ̸= 0. Here, note that a hypothesis test always tests for an equality sign. So
while a paper might test the (theoretical) hypothesis that changing D from 0 to 1
causes an increase in y (and further assesses by how much y increases in response
to the change in D), statistically speaking, the same paper tests the (null) hypothesis
that the association between D and y is not statistically signiﬁcantly different from
zero.
• The estimation strategy sub-section also needs to discuss inference, meaning whe-
ther and how the standard errors are robust (and if so, robust to what; it is not
enough to say that the standard errors are robust if the Huber-sandwich-White cor-
rection is used, but it is warranted to say that they are robust to heteroskedasticity),
whether and how they are clustered (and if so, at what level and why; see Abadie et
al. 2017 for a primer), and whether sampling weights were used to bring the sample
closer to the population of interest (and if so, how they were constructed; see Solon
et al. 2015 for a primer).
15
--- END PAGE 15 ---

--- PAGE 16 ---
5.2
Identiﬁcation Strategy
After showing and discussing what equations are estimated, there needs to be a discus-
sion of how the coefﬁcient pertaining to the causal relationship of interest is identiﬁed.
The term “identiﬁcation” has gone through several meanings over time (Lewbel, 2019).
For better or for worse, the term more often than not refers to causal identiﬁcation nowa-
days in applied papers. What is causal identiﬁcation? In a few sentences, it refers to sit-
uations where a coefﬁcient is more than just a partial correlation between the dependent
variable y and some variable of interest D, and where the estimated coefﬁcient instead
reﬂects a relationship that is causal.
Although an unbiased coefﬁcient estimate implies an identiﬁed—that is, causally identiﬁed—
coefﬁcient estimate, the converse is not true. Indeed, there are situations where one knows
a coefﬁcient to be biased, but where a statistically signiﬁcant coefﬁcient estimate can still
be used to denote a causal relationship.
For instance, imagine that D is continuous and randomly assigned and you have data
on an outcome variable y and a vector of controls x. Imagine further that subjects perfectly
comply with D, so that you can in principle estimate an average treatment effect, but that
D is measured with error—when the data for D were entered, they were entered with
some degree of error. With classical measurement error on D (i.e., with random mistakes
in the entering of D), we know the treatment effect will be biased toward zero because of
attenuation bias.8 In such cases, when H0 : γ = 0 is rejected, we can still say that we have
found evidence of a causal effect of D on y, adding the caveat that that effect is biased
toward zero (or, alternatively, that we have estimated the lower bound in absolute value
on the true effect). Sometimes, the same can be said with systematic measurement error
on D, as there are cases where you know the estimate bγ of γ is biased toward zero because
of systematic measurement error, but that is much less common.
8As a colleague noted, if D is binary, any measurement error cannot be classical, for it the observed D
will be negatively correlated with the true value of D.
16
--- END PAGE 16 ---