# Section: Results Section
**PDF pages:** 24–25
**Split method:** headers

---

--- PAGE 24 ---
22 
 
VII. 
Results Section 
A. Main Elements  
 
This section needs to highlight the main results of your analysis as carefully and clearly as any other 
part of the paper. In light of these essential aspects, one needs to make several decisions: 
• 
What empirical results to report. 
• 
How many empirical results to report. 
• 
Which results go in the main body of the paper and which belong to an appendix 
• 
How to describe the results in the body of the paper 
B. How Many Results Should I Report?  
 
A good rule to follow regarding reporting results is that less is usually better. Novice researchers 
(or graduate students) tend to over-include or report many secondary parameter estimates from most 
regression specifications.  
Although such a “kitchen sink” approach has some merits (e.g., it shows the audience the 
extensive analysis performed or that the researcher has examined various aspects regarding the 
stability of the results), this particular approach has a significant drawback. Pages of parameter 
estimates usually muddy the main message and story of the paper. It can significantly detract from 
the comprehensiveness of your central contribution, which is most important in your paper. 
• The reader will get either lost, bored, or annoyed.  
• Present only results and parameter estimates that directly bolster your main takeaway and 
story. 
• Do not present secondary analyses or relegate such analyses to an Online Appendix if 
needed. 
 
Let us consider an example. Suppose you are considering the so-called Mincer equation, which 
labor economists use to estimate the wage returns to education. Your primary regression (based on 
the Mincer equation) will place an individual’s earnings on the left-hand side. Any regressors, such 
as education, race, gender, work experience, and geographic fixed effects, will be on the right-hand 
side. Suppose that you believe that the key regressor of interest (i.e., education) is strongly correlated 
with the error term of the wage equation. For example, this could be because people who exhibit 
higher than average ability earn higher wages at their jobs. These same people also obtain more 
schooling. This correlation between the error term and the education variable will most certainly 
result in a biased estimate of the parameter estimate in front of the education variable (a 
phenomenon called “ability bias”). The measured effect of education in the regression will reflect 
the true causal effect of education on wages and some of the effect of ability on wages.  
Labor economists have adopted several approaches to circumvent this “ability bias,” one of 
which relies on using a proxy measure for ability (if data on such proxy measures are available). We 
can assume that the main storyline relates to the presence and the magnitude of the ability bias. 
Then, your narrative on the main results should focus on the estimates of the education effect and the 
ability effect in the revised specifications, including the imperfect proxies of ability.
--- END PAGE 24 ---

--- PAGE 25 ---
23 
 
Your regression results will likely look like the results reported in Table 1 below: 
Table 1: The Effect of Education on Wages (OLS) 
 
Dependent Variable: Log of Yearly Earnings 
 
(1) 
(2) 
(3) 
(4) 
Education 
0.091 
(0.001) 
0.031 
(0.003) 
0.086 
(0.002) 
0.027 
(0.005) 
Ability dummy 
 
0.251 
(0.010) 
 
0.301 
(0.010) 
State FE 
No 
No 
Yes 
Yes 
R2  
0.50 
0.55 
0.76 
0.79 
 
 
 
 
 
No. of Observations 
35,001 
35,001 
19,505 
19,505 
No. of Persons 
5,505 
5,505 
4,590 
4,590 
Notes: Standard errors are in parentheses. The analysis dataset covers the years 1985 to 1995. The shares of doctors 
and lawyers are taken from the Five Percent Public Use Micro Sample of the 1950 U.S. Census and are defined as the 
share of each profession among employed persons in the population aged 25–64. A “city” is defined as Standard 
Metropolitan Statistical Area; constant SMSA definitions are used from 1950 to 1990. Region dummies correspond to 
the 10 “major regions,” as defined by the Census Bureau. 
 
Notice a few aspects of how Table 1 reports the results:  
• The table does not report parameter estimates of all independent variables (e.g., marital 
status, gender), only the principal variable (education). 
• The table also has a footnote section marked with the Notes heading.  
• The Notes: this footnote is an important place for clarifications and secondary details, 
enabling the audience to make sense of your results.  
• The Notes to a table should be self-explanatory. However, they should be extensive enough 
so that an intelligent reader will not have to return to the text to understand the results 
reported in the table. 
• For example, in the Notes, one could state their definition of labor market experience. 
Additionally, one could explain why the third and fourth regressions have fewer observations 
than the first and second regressions. Any clarifications about important measurement issues 
or other caveats that will help the reader understand your results better belong in this section. 
• Finally, the notes to the table should indicate whether you are reporting standard errors or t-
statistics in the parentheses underneath the coefficients.  
o In general, the preferred approach is to report standard errors. In this way, your 
readers can more easily choose the statistical method they would like to use in 
evaluating your numbers. However, since published papers adopt both approaches, 
you must be clear about which approach you are using. 
 
Your variables and their associated labels must also be clear to the reader. 
• Do not use variable abbreviations from your Stata or SAS program (YEDUCT2011 or 
ABIL8225A) as variable names.  
o Make sure you label your variables in the Tables so that they are easy to interpret and 
will not cause any confusion for your audience
--- END PAGE 25 ---