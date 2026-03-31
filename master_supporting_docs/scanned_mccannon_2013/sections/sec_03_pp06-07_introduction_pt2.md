# Section: Introduction (Part 2)
**PDF pages:** 6–7
**Split method:** headers
**Note:** This is part of a longer section, sub-split to ensure deep reading.

---

--- PAGE 6 ---
700 
McCannon
The slip opinions of the Fourth Department of western New York are collected for
the years 2009, 2010, and 2011.5 A total of 1,874 observations, then, make up the data set.'
The observations are spread over 22 counties. From each slip opinion, a number of
observable variables can be created. There is a rich literature conducting content analysis
of judicial opinions. See Hall and Wright (2008) for an overview describing debates and
techniques, Evans et al. (2007) for a discussion of methods, and Edwards and Livermore
(2009) for potential pitfalls.
First, the primary dependent variable of interest is whether the appellate court
upholds the lower court's decision. Let UPHELD equal 1 if no change to the lower court's
decision is made. Table A3 in the Appendix provides information on the adjustments made
by the appellate justices. Typically, the convicted defendant makes the appeal. Rarely,
though, the prosecutor's office files an appeal. These appeals are typically based on pretrial
dismissals.' Let APPELLANT equal 1 if the appellant is the defendant.
To measure the complexity of the case, a straightforward proxy is employed. Let PAGES
be the number of pages of a slip opinion. Presumably, a more complicated case requires
more justification, citations, footnotes, and the like by the appellate justices. Since the
formatting of the slip opinions is consistent, the number of pages is expected to correlate with
the number of issues to be addressed, the complexity of the issues, and whether concurrence
opinions are added. More complicated cases are expected to experience a lower rate of being
upheld, independent of incentives and distortions of the prosecutor.
Similarly, the length of time between the lower court conviction and the appellate
decision can be taken into account. Define GAP as the number of months between the two
decisions. It seems reasonable to believe that frivolous appeals more likely occur soon after
the conviction and the decision is upheld.
Control variables for which type of court the conviction came from along with the
number ofjustices used in the appellate decision can be included. Define SUPREME as being
equal to 1 if the conviction came from the Supreme Court and let MISSING5 equal I if only
four justices are used. Furthermore, dummy variables controlling for which four/five
appellate court justices ruled on each case are created as well.
Table 1 provides some descriptive statistics.
Table 1 reveals that the lower court's conviction is upheld 83 percent of the time
and the defendant is the appellant in 98.5 percent of the convictions. The slip opinions
frequently consist of only one or two pages (42.5 percent and 43.2 percent of the sample,
respectively). The average duration between conviction and appeal is just less than two-
and-a-half years. The mean value for SUPREME is less than one-half. Some counties utilize
the County Courts for criminal cases and the Supreme Court only for civil cases.
'hey 
can be found at the New York Official Reports website, <http://www.courts.state.ny.us/reporter/slipidx/
aidxtablc_4.shtnl>. There are 667, 621, and 586 appeals in the three years, respectively.
6Only criminal convictions are considered. Also, cases of ex relatione and those that request reargument, reconsidera-
tion, or error coram nobis and are quickly denied are excluded (due to the lack of information available).
7The main results of the article persist if observations with APPELLANT =0 are dropped.
--- END PAGE 6 ---

--- PAGE 7 ---
Prosecutor Elections, Mistakes, and Appeals
Table 1: 
Descriptive Statistics
Variable 
Mean 
SD 
Min 
Max
UPHELD 
0.830 
0.376 
0 
1
APPELLANT 
0.985 
0.123 
0 
1
PAGES 
1.765 
0.858 
1 
8
GAP 
29.02 
18.00 
5 
260
SUPREME 
0.252 
0.434 
0 
1
MISSING5 
0.137 
0.344 
0 
1
SOURcE: Data collected by the author from information provided by the
New York Official Reports.
Along with this basic information, most slip opinions also provided information on
which crime was committed. Thirty-two dummy variables are created to control for the
various crimes committed. In situations where multiple crimes are committed, each is
coded. The controls do not differentiate between degrees or class. Over 95 percent of the
slip opinions provide information on the crime. The list of crimes and their descriptive
statistics are presented in the Appendix.
Additionally, the slip opinions provide information on the grounds of the appeal.
Numerous dummy variables are created. The method used to measure the grounds for the
appeal is as follows. For each slip opinion, only one ground for appeal (or 0) is coded.
Often, it is clear what the argument made by the appellant was. In these cases, only one
point was addressed by the justices and this was coded. Sometimes, though, multiple points
were discussed by the justices. Typically, the most relevant and important argument made
was addressed first and in more detail. When there is more than one point to be discussed,
the first one brought up by the justices in the appeal is the one used. A typical situation
would be where one dominant argument was addressed by the justices. In the last para-
graph, the justices will quickly dismiss the other points made. Other times, language such
as there being "no nonfrivolous points remaining" was used or that remaining points "lack
merit." Thirteen grounds dummy variables are created. Their list, along with the descriptive
statistics, is presented in the Appendix.
Also, there is variation in the type of defense employed by the defendant. Some
counties in western New York have created a public defender office. Low-income individ-
uals are eligible for this free legal defense. In the larger cities in the area (Buffalo,
Rochester, and Syracuse), legal aid organizations have been developed. Absent publicly
provided defense, a defendant may use a private attorney. It is worth pointing out, though,
that in rural counties that have not created a public defender office, the county is required
by state law to provide free legal assistance to low-income individuals. In these circum-
stances, a private attorney is also used. Six defense dummy variables are created to differ-
entiate the types of defense. Of these, 41.8 percent of the cases had private representation,
28.2 percent utilize public defenders, while the remaining defendants take advantage of
legal aid societies.
As stated, the primary concern is whether the appellate court upholds the lower
court's decision. The outcome provided in the slip opinion, though, is not binary. The
701
--- END PAGE 7 ---