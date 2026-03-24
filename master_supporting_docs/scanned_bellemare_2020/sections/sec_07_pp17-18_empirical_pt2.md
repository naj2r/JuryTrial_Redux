# Section: Empirical (Part 2)
**PDF pages:** 17–18
**Split method:** headers
**Note:** This is part of a longer section, sub-split to ensure deep reading.

---

--- PAGE 17 ---
If you are fortunate enough (i) to have experimental variation in your treatment vari-
able, and (ii) balance tests suggest the experimental assignment of observations to treat-
ment and control groups was truly random, your identiﬁcation strategy section can be
mercifully short, as your results are causally identiﬁed by virtue of experimental assign-
ment. In other words, you can estimate what Pearl (2009) denotes E(y|do(x)), i.e., the
(causal) effect of treatment x on outcome y.
If you have (i) experimental variation in your treatment variable but (ii) balance tests
suggest the experimental assignment of observations to treatment and control groups
was not truly random, your identiﬁcation strategy section can also be short, as you only
need to explain how you will add in control x on the right-hand side of your equation of
interest to help rectify the situation, but only somewhat as unobservables are also likely
to be unbalanced when the observables are unbalanced.
If you do not have experimental variation in your treatment variable, there is yet more
work to be done. In the interest of brevity, this paper cannot and will not provide a deep
dive into causal identiﬁcation with observational data (for a complete introduction, see
Morgan and Winship 2015). There nevertheless are certain things that can be discussed
as being necessary items in any good identiﬁcation strategy section:
• Explain intuitively why your results have a shot at causal identiﬁcation. Practically
speaking, this means that you have to tell your reader why your results bring us
closer than ever before to making a causal statement about the relationship of inter-
est. In the best-case scenario, this will be because you have a research design (e.g.,
a strictly exogenous instrumental variable such as a lottery) which clearly allows
thinking of treatment as if it were randomly assigned. In less-than-ideal scenarios
(e.g., an instrumental variable that is only plausibly exogenous; cf. Conley et al.
2012), you need to explain why, even though your research design does not yield
clean and clear causal identiﬁcation, your results are the best in the literature.9
9This presumes that your research design is the best thing out there. In cases where your research design
17
--- END PAGE 17 ---

--- PAGE 18 ---
• Discuss in turn the three following sources of statistical endogeneity:10 (i) reverse
causality, (ii) unobserved heterogeneity, and (iii) measurement error, explaining
whether each of those sources of statistical endogeneity is a concern in your ap-
plication, how it is dealt with in your application. Here, if there are issues, admit to
them, and explain how they might bias your estimate of the coefﬁcient of interest.
Do not lie about what your paper can and cannot do!
• Once that is done, there is one more source of problems to be considered, viz. viola-
tions of the stable unit treatment value assumption (SUTVA). What SUTVA means
is speciﬁc to each application, but in short, if you observe the effect of a treatment
Dit on outcome yit, where i denotes an individual unit of observation and t denotes
a time period, it has to be the case that the value of Dit does not affect the value y−it,
yi,−t, or y−i,−t. In other words, there cannot be any spillovers from one unit being
treated to another unit’s outcome, and there cannot be any spillovers from one unit
being treated at a given point in time to that same unit’s outcome in the future, nor
can there be any spillovers from one unit being treated at a given point in time to
other unit’s outcome in the present or in the future. The SUTVA can be extremely
difﬁcult to satisfy. That said, one can often test for SUTVA violations; see Burke et
al. (2019) for an example of a paper where the authors deal with SUTVA violations
very well.
• Again, because this is extremely important: If your results are not causally iden-
tiﬁed, do not lie about what they can and cannot do! And generally, do not make
claims that are not backed up by your research designs of your results, no matter
is second- (or third-, or nth-) best, unless you signiﬁcantly improve on external validity, you will need to
adjust your set of target journals downward.
10I talk explicitly of statistical endogeneity—what makes Cov(D, ϵ|x) ̸= 0—because many research
economists still confuse theoretical and statistical exogeneity. Theoretical exogeneity is when a given vari-
able is determined outside of a given theoretical framework (e.g., prices and income in the typical utility-
maximization problem). Statistical exogeneity is when Cov(D, ϵ|x) = 0 in the regression framework we
have been considering. Though the two share the same “exogeneity” and “endogeneity” terminology,
there is little overlap in their respective meanings. It is a poor applied economist who says her results are
causally identiﬁed because her treatment variable is (theoretically) exogenous!
18
--- END PAGE 18 ---