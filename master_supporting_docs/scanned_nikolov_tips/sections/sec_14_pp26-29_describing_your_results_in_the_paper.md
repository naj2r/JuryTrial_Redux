# Section: Describing Your Results In The Paper
**PDF pages:** 26–29
**Split method:** headers

---

--- PAGE 26 ---
24 
 
o Make sure your variable labels and data in the Tables are consistent with any 
references in the text. 
• Do not worry about repeating yourself in the text and the notes.  
o This kind of repetition will often be necessary so the reader can understand your table 
without looking back at the text. 
o You should present enough information so that a researcher can replicate your results.  
▪ For very complex projects, this may require a data appendix.  
 
After presenting the main results, you may include and discuss additional robustness checks 
performed. Robustness checks refer to additional analyses exploring the stability of the main results. 
• The third and fourth columns of Table 1 are robustness checks. They show that the effect 
of including ability in the regression is the same whether or not we include state-level 
fixed effects.  
• Another robustness check would be to consider the inclusion of the ability variable if we 
subset only on male household heads or if we restrict the sample to the 1990s. Here, we 
may check whether the estimate of the education effect is lower.  
• Sometimes all that is necessary is to let the reader know in the text that you performed 
these tests and that the main results were unaffected.  
• For a single robustness check, this information can even appear in a footnote keyed to the 
relevant portion of the text.  
• However, if there are many robustness checks, you may want to present these results in 
another, more parsimonious table. 
o Papers often include a separate section called “Robustness Checks.”  
o In the Robustness Checks section, the authors explore several aspects of the 
stability of the main results 
 
C. Describing Your Results in the Paper 
 
After you decide how to make your tables, graphs, and figures, you should clearly and precisely 
describe them in the text. Establish the main point of the table in the topic sentence of a paragraph. 
Consider the following example of a brief description of the main results and takeaways:  
 
Table 1 shows that including a measure of ability in the wage equation lowers the 
predicted effect of education on earnings. In Column (1), we do not include the 
proxy measures of ability; the results reported in the Column indicate that a year 
of education raises wages by 9.1 percent. In Column (2), we add the proxy 
measures of ability, and the education effect drops to 3.1 percent. Columns (3) and 
(4) report the results from the same specifications with the inclusion of state fixed 
effects; the pattern of the results reported in these columns was that this general 
pattern is consistent with the results from Columns (1) and (2). The estimates in 
Table 1 are consistent with the hypothesis that an upward ability bias plagues the 
naïve OLS estimates. 
Note that the first and last sentences in the paragraph describing the results are “big picture” 
statements. They describe how the overall results fit into the paper’s overall story.
--- END PAGE 26 ---

--- PAGE 27 ---
25 
 
Authors frequently do not pay close attention to the narrative regarding their results. Some 
authors opine that the results are already in the table. However, there is an excellent argument to 
frame the focus on results central to your thesis and frame your narrative, particularly as it relates to 
the paper’s main punchlines. To this end, you should guide the reader. Steer his or her attention on 
the most important results from your analysis, and in the right order.  
• Remember, no empirical paper ever turns out perfectly. 
• Usually, the data do not resoundingly support each hypothesis or proposed idea.  
• It is especially critical that you discuss your results as honestly and carefully as possible 
in such cases.  
 
Let us consider another hypothesis research question. Assume you are studying the effect of the 
population share of lawyers in a city on the city’s subsequent population growth. Some theoretical 
models posit that cities with lots of lawyers will grow more slowly. However, the same theoretical 
model posits that this relationship does not hold for cities with many other highly educated 
professionals, such as doctors. You obtain data on the population percentage of doctors and lawyers 
in cities in 1950 and the cities’ growth rates from 1950 to 1990. Table 2 reports the results of this 
particular analysis. 
 
Table 2: The Effect of Lawyers on City Growth 
 
Dependent variable: City’s Population 
Growth Rate, 1950-1990 
 
(1) 
(2) 
(3) 
Share of Lawyers in 
Population, 1950 
-0.09  
(0.01) 
 
-0.08 
(0.03) 
-0.07 
(0.05) 
Share of Doctors In Population, 
1950 
 
0.05 
(0.03) 
0.05 
(0.05) 
Region FE 
No 
No 
Yes 
R2  
 
 
 
 
 
 
 
No. of Observations 
25 
25 
25 
Notes: Standard errors are in parentheses. The shares of doctors and lawyers are taken from the Five Percent 
Public Use Micro Sample of the 1950 U.S. Census and are defined as the share of each profession among 
employed persons in the population aged 25–64. A “city” is defined as Standard Metropolitan Statistical Area; 
constant SMSA definitions are used from 1950 to 1990. Region dummies correspond to the 10 “major regions,” 
as defined by the Census Bureau. 
 
Let us consider two alternative approaches to describe the results in Table 2.  
• One approach (not the best approach!) to describe the table’s results is as follows:  
o The first column of Table 2 shows the main effect predicted by theory. The 
second Column shows that doctors do not have the same effect on city growth. 
Finally, including regional dummy variables do not significantly affect the main 
point estimates, though statistical precision is lost. 
• A second approach (a much better approach!) is as follows:
--- END PAGE 27 ---

--- PAGE 28 ---
26 
 
o Table 2 reports that a higher share of lawyers in a city’s population leads to 
slower city growth. However, when we account for other determinants of 
city growth, the estimated effect is less precise. Column (1) shows that a ten 
percentage-point increase in the lawyer share of population decreases the 
future city growth by about .9 percentage points. In contrast, Column (2) 
shows that a higher share of doctors in the population improves the city’s 
growth. Specifically, the point estimate associated with the doctor share 
coefficient is positive, although imprecisely estimated. The estimates in 
Column (2) are less precise than those in Column (1). This increase in the 
associated standard errors in Column (2) is likely driven by possible positive 
multicollinearity, as the doctor and lawyer share variables are strongly 
(positively) correlated. Turning out attention to results reported in Column 
(3), the issue of statistical precision becomes even more salient. When the 
analysis accounts for Census region fixed effects, the associated standard 
errors of the estimated coefficients go up. Adding additional regressors in 
the specification increases the standard errors to the point that the effect of 
more lawyers in the city becomes statistically indistinguishable from zero. 
One possible interpretation of Column (3) results is that more lawyers in a 
city might negatively affect city growth. However, the point estimate is 
robust to including additional control variables; the effect size is imprecisely 
estimated. 
 
Below, I point out several important considerations in reporting your results.  
 
a. How Many Decimal Places?  
Do not report all the decimal places displayed by your software package. Doing this is called 
false precision. Figuring out how many decimal places should be reported is a difficult question.  
• Studies rely on rounding numbers primarily to enhance readability.  
o Decisions regarding what to display hinge on creating tables that are pleasing to 
the eye. For example, every number is reported to the same relatively small 
number of decimal places.  
o While not necessarily logical, it is the best of many imperfect options.  
Enhancing readability leads to a suggestion to avoid coefficients with many leading or trailing 
zeroes.  
• A number such as 0.00123456 could be reported as 1.23456 as long as the units of the 
variable are appropriately adjusted.  
 
b. Using Standard Errors as a Benchmark 
 
Another approach regarding how many decimal points to report is letting standard errors (SE) be 
a benchmark (as commonly used in the hard sciences). The idea behind this particular approach is 
that the standard error measures the precision of an estimated coefficient.
--- END PAGE 28 ---

--- PAGE 29 ---
27 
 
The rule for using SE as a benchmark is: Find the first non-zero digit in the SE. If the digit is 
greater than one, then this digit determines the decimal place to which coefficients are reported. 
Round the SE to this decimal place and round the estimated coefficient to the same decimal place. 
Then report both numbers accordingly. 
Here is an example:  
• 
0.00456789 +/- 0.0089 → 0.005 +/- 0.009.  
• 
The first non-zero digit in the SE is 8. We round the SE to 0.009. We report the 
coefficient rounded to that decimal place, 0.005.  
If the first non-zero digit in the SE is a one, then you apply the same rules to the next decimal 
place in the SE.  
Here is another example: 
• 
12345.6789 +/- 12.3456789 → 12346 +/- 12.  
• 
The first non-zero digit in the SE is 1, so we go to the next digit, 2, and round the SE 
to 12.  
• 
Then we use the rounding decimal of our SE as our guide to rounding the coefficient. 
Note that this rule means that 12345.6789 +/- 1234.56789 should be reported as 
12300 +/- 1200.  
 
If the first non-zero digit in the SE is a 1 that rounds up to a 2, keep the next digit, e.g., if the SE 
is 0.196, report the SE as 0.20. 
Here is a small modification to the scientific rule of thumb. Follow the same rule, as noted 
above, but add one additional decimal place to the results you report beyond what the above rule 
would give you.  
Here is an example: 
• 
12345.6789 +/- 12.3456789 → 12345.7 +/- 12.3  
• 
12345.6789 +/- 1234.56789 → 12346 +/- 123.  
This modification is useful to tackle a potential disadvantage of the scientific rule: it is 
challenging to compute accurate t-statistics when only a limited number of decimal places are 
reported.  
It is essential to underscore that no consensus exists on this issue. However, it is also clear that 
reporting fifteen to twenty decimal places is silly. Do not do this. 
 
c. Discussing Policy Implications and Normative Issues  
 
Many of the topics that economics research explores have real-world policy implications. Your 
research may also report robust findings of the effects of existing or new policies. Providing 
normative statements in your papers is a tricky business. It is best to avoid making value 
judgments and rely on positive analyses, which can speak for themselves. Your analyses will 
rarely consider all relevant aspects of new policies. Your audience can consider the analysis of 
additional aspects. 
  
 
In the discussion of your result, you can and should also point out the limitations of your 
research
--- END PAGE 29 ---