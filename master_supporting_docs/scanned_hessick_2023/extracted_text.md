# Extracted Text: hessick2023_uncontested_elections.pdf

**Pages:** 47
**Extracted:** 2026-03-24 19:42:54

--- PAGE 1 (PDF page 1) ---
UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS 
Carissa Byrne Hessick,*  Sarah Treul,** and Alexander Love***  
ABSTRACT 
Prosecutors are very powerful players in the criminal justice system. One of 
the few checks on their power is their periodic obligation to stand for election. 
But very few prosecutor elections are contested, and even fewer are competitive. 
As a result, voters are not able to hold prosecutors accountable for their deci-
sions. The problem with uncontested elections has been widely recognized, but 
little understood. The legal literature has lamented the lack of choice for voters, 
but any suggested solutions have been based on only anecdote or simple descrip-
tive analyses of election data. 
Using a logistic regression analysis, this Article estimates the individual 
effects of a number of variables on prosecutor elections. It finds that several fac-
tors that have been previously identified as contributing to an uncontested elec-
tion are not, in fact, what drives uncontested elections for prosecutors. Instead, 
the factors with the largest effect are whether an incumbent runs and the popula-
tion of the district. It also identifies two features of state election law that contrib-
ute to the dearth of contested elections. The Article concludes by noting that 
these factors suggest specific policy changes that could help to increase the num-
ber of contested and competitive elections—thus ensuring that voters can help 
guide important criminal justice decisions in their communities.    
INTRODUCTION . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
32  
I. PROSECUTORS AND THEIR ELECTIONS . . . . . . . . . . . . . . . . . . . . . . . . . 
36  
A. The Power of Prosecutors . . . . . . . . . . . . . . . . . . . . . . . . . . . 
39  
B. The Election of Prosecutors . . . . . . . . . . . . . . . . . . . . . . . . . 
44  
II. LESSONS FROM THE POLITICAL SCIENCE LITERATURE. . . . . . . . . . . . . . . 
47  
A. Brief Note on the Incumbency Advantage. . . . . . . . . . . . . . . . 
48  
B. Uncontested Elections. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
50  
C. Competitive Elections . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
53  
III. A STATISTICAL ANALYSIS OF PROSECUTOR ELECTIONS. . . . . . . . . . . . . . 
56  
A. Identifying Relevant Variables. . . . . . . . . . . . . . . . . . . . . . . . 
56  
1. Open Seats . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
57  
2. Partisan Mismatch and General Elections . . . . . . . . . . . . 
57 
* Ransdell Distinguished Professor of Law and Director of the Prosecutors and Politics Project, University of 
North Carolina School of Law. © 2023, Carissa Byrne Hessick, Sarah Treul, and Alexander Love. 
** Bowman and Gordon Gray Term Professor of Political Science, University of North Carolina at Chapel 
Hill. 
*** Ph.D. student in the department of Political Science, University of North Carolina at Chapel Hill. 
31
--- END PAGE 1 ---

--- PAGE 2 (PDF page 2) ---
3. Partisan Match and Primary Elections . . . . . . . . . . . . . . . 
57  
4. Length of Incumbent Tenure. . . . . . . . . . . . . . . . . . . . . . 
58  
5. “Professionalization” of the Office and Attractiveness of 
Position. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
58  
6. Supply of Lawyers . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
59  
7. Differences in Election Law . . . . . . . . . . . . . . . . . . . . . . 
59  
8. Crime and Prison Admission Trends . . . . . . . . . . . . . . . . 
60  
B. Description of Data and Summary Statistics. . . . . . . . . . . . . . 
61  
C. Lawyer Supply Hypothesis . . . . . . . . . . . . . . . . . . . . . . . . . . 
69  
D. Crime and Prison Admission Trends . . . . . . . . . . . . . . . . . . . 
70 
CONCLUSION. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
74 
APPENDIX: SUPPLEMENTARY ANALYSIS . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
77 
INTRODUCTION 
The United States is the only country in the world that elects its prosecutors.1 
Whether elections are an optimal method for selecting prosecutors has been a mat-
ter of some debate.2 The reason for that debate is that we want our prosecutors to 
be both accountable and independent. In other words, we want them to be answer-
able to the public for their decisions, while at the same time able to exercise their 
professional judgment free from political pressure. 
These two goals are in tension. Electing prosecutors ensures that they are ac-
countable, but it limits their independence. In contrast, appointing prosecutors 
increases independence, but it does so at the expense of accountability. 
Regardless, whether elections or appointments are the best methods for selecting 
prosecutors, elections in the United States generally fail to capture the accountabil-
ity benefits of elections because so many prosecutor elections are uncontested and 
uncompetitive.3 An uncontested election does not provide citizens with the oppor-
tunity to hold their elected prosecutors accountable because there is no alternative 
on the ballot. At the same time, because they continue to face elections, prosecu-
tors are still subject to political pressure. Several social science studies have found 
1. DARRYL K. BROWN, FREE MARKET CRIMINAL JUSTICE: HOW DEMOCRACY AND LAISSEZ FAIRE UNDERMINE 
THE RULE OF LAW 28 (2016). As Michael Ellis notes, “[t]he Swiss cantons of Geneva, Basel-City, and Tessin 
elect judges who have a prosecutorial function, but they are not public prosecutors in the common-law sense of 
the office.” Michael J. Ellis, The Origins of the Elected Prosecutor, 121 YALE L.J. 1528, 1530 n.1 (2012). 
2. See, e.g., BROWN, supra note 1, at 59; Angela J. Davis, The American Prosecutor: Independence, Power, 
and the Threat of Tyranny, 86 IOWA L. REV. 393, 438–43 (2001); Daniel C. Richman, Accounting for 
Prosecutors, in PROSECUTORS AND DEMOCRACY: A CROSS-NATIONAL STUDY 40 (Ma´ximo Langer & David Alan 
Sklansky eds., 2017); David Alan Sklansky, Unpacking the Relationship between Prosecutors and Democracy in 
the United States, in PROSECUTORS AND DEMOCRACY: A CROSS-NATIONAL STUDY 276 (Ma´ximo Langer & David 
Alan Sklansky eds., 2017); Michael Tonry, Prosecutors and Politics in Comparative Perspective, in 
PROSECUTORS AND POLITICS: A COMPARATIVE PERSPECTIVE 27–28 (Michael Tonry ed., 2012). 
3. Carissa Byrne Hessick & Michael Morse, Picking Prosecutors, 105 IOWA L. REV. 1537, 1570–71 (2020) 
(comparing the costs and benefits of electing and appointing prosecutors and concluding that “elections without 
contestation are the worst of both worlds”). 
32                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 2 ---

--- PAGE 3 (PDF page 3) ---
that prosecutors change their behavior in election years4
See Siddhartha Bandyopadhyay & Bryan C. McCannon, The Effect of the Election of Prosecutors on 
Criminal Trials, 161 PUB. CHOICE 141, 142 (2014); Andrew Dyke, Electoral Cycles in the Administration of 
Criminal Justice, 133 PUB. CHOICE 417, 419 (2007); Bryan C. McCannon, Debundling Accountability: 
Prosecutor and Public Defender Elections in Florida 2–3 (Feb. 3, 2018) (unpublished manuscript), https://papers. 
ssrn.com/sol3/papers.cfm?abstract_id=3204623; Melissa R. Nadel, Samuel J. A. Scaggs & William D. Bales, 
Politics in Punishment: The Effect of the State Attorney Election Cycle on Conviction and Sentencing Outcomes 
in Florida, 42 AM. J. CRIM. JUST. 845, 847 (2017). There are, however, studies that do not identify an election 
effect on prosecutorial behavior. See Carissa Byrne Hessick, Prosecutors and Voters, in THE OXFORD 
HANDBOOK OF PROSECUTORS AND PROSECUTION 399, 404 (Ronald F. Wright, Kay L. Levine & Russell M. Gold, 
eds., 2021) for an extended discussion of the literature. 
—suggesting that political 
pressure overcomes their professional judgment—and at least one study has found 
that these election-year changes affect prosecutors irrespective of whether they are 
facing a challenger in their elections.5 In other words, uncontested elections may 
be the worst of both worlds—prosecutors are neither held accountable nor are they 
independent. 
The prevalence of uncontested prosecutor elections has been a topic of concern 
for several years.6 But because comprehensive data about prosecutor elections is 
4. 
5. See Siddhartha Bandyopadhyay & Bryan C. McCannon, Re-election Concerns and the Failure of Plea 
Bargaining, 3 THEORETICAL ECON. LETTERS 40, 40 (2013). But see Melissa R. Nadel et al., supra note 4, at 859 
(finding a difference between prosecutor behavior in face of contested versus uncontested elections in some 
cases). 
6. See, e.g., JOHN F. PFAFF, LOCKED IN: THE TRUE CAUSE OF MASS INCARCERATION AND HOW TO ACHIEVE 
REAL REFORM 134 (2017) (“[B]y and large, district attorneys are reelected with unfailing regularity. It’s hard to 
view elections as a way to systematically regulate prosecutorial behavior.”); id. at 139 (“Almost all prosecutors 
are elected, but those elections often seem like foregone conclusions. Incumbents rarely face challengers, and 
when they do they usually win.”); Shima Baradaran Baughman, Subconstitutional Checks, 92 NOTRE DAME L. 
REV. 1071, 1103 (2017) (“[I]ncumbent prosecutors rarely face real accountability. . . . [N]inety-five percent of 
the incumbents who want to return to prosecutorial office are reelected.” (footnotes omitted)); Stephanos Bibas, 
Restoring Democratic Moral Judgment within Bureaucratic Criminal Justice, 111 NW. U. L. REV. 1677, 1690 
(2017) (“Prosecutorial elections are notoriously uncompetitive . . . .”); Stephanos Bibas & William W. Burke- 
White, International Idealism Meets Domestic-Criminal-Procedure Realism, 59 DUKE L.J. 637, 660 (2010) 
(“[Prosecutor] races are distorted by huge incumbency advantages and driven by occasional scandals and 
unrepresentative, high-profile celebrity trials.”); R. Michael Cassidy, Character and Context: What Virtue 
Theory Can Teach Us about a Prosecutor’s Ethical Duty to “Seek Justice,” 82 NOTRE DAME L. REV. 635, 657 
(2006) (“It is exceptionally rare in this country for an incumbent prosecutor to be voted out of office.”); Roger A. 
Fairfax, Jr., Prosecutorial Nullification, 52 B.C. L. REV. 1243, 1269 (2011) (“Prosecutorial reelection rates are 
high and the vast majority of incumbents go unchallenged.”); Eric S. Fish, Against Adversary Prosecution, 103 
IOWA L. REV. 1419, 1478 (2018) (“Several studies suggest that prosecutorial elections are low-information 
affairs in which incumbency is an overwhelming advantage (indeed, many are uncontested), and in which 
conviction rates and other metrics of adversarial success bear little apparent relationship to electoral success.”); 
Janet C. Hoeffel & Stephen I. Singer, Elections, Power, and Local Control: Reining in Chief Prosecutors and 
Sheriffs, 15 U. MD. L.J. RACE, RELIGION, GENDER & CLASS 319, 323 (2015) (“Unlike sitting mayors, governors, 
and state and local legislators, the vast majority of incumbent prosecutors and sheriffs run unopposed.”); Bidish 
Sarma, Using Deterrence Theory to Promote Prosecutorial Accountability, 21 LEWIS & CLARK L. REV. 573, 592 
(2017) (“Prosecutorial elections are historically low-information, low-turnout affairs. Often times, there are no 
opponents to vote for; even when other candidates materialize, incumbents win so often that ‘retention 
rates . . . would make a candidate for the Supreme Soviet blush.’” (footnotes omitted) (quoting Ronald F. Wright 
& Marc L. Miller, The Worldwide Accountability Deficit for Prosecutors, 67 WASH. & LEE L. REV. 1587, 1606 
(2010))); Note, Restoring Legitimacy: The Grand Jury as the Prosecutor’s Administrative Agency, 130 HARV. L. 
REV. 1205, 1220 (2017) (“[I]ncumbent prosecutors win reelection the vast majority of the time . . . .”). 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
33
--- END PAGE 3 ---

--- PAGE 4 (PDF page 4) ---
difficult to obtain, people have been left to speculate about the reasons why so 
many of these elections are uncontested. Some have speculated that uncontested 
prosecutor elections are attributable to a lack of interested candidates7 or the small 
pool of eligible candidates.8 Others have posited that the problem may be that the 
office is local, which leads to prosecutor elections being drowned out in the media 
coverage of state and national elections. The focus on state and national elections 
makes it difficult for would-be challengers to raise money or get attention for their 
platforms.9 Indeed, this incumbent advantage appears to be confirmed by the corre-
lation between the length of an incumbent’s time in office and contested elec-
tions.10 And some have hypothesized that variation in state election laws and 
processes may increase or decrease the likelihood of contested elections—such as 
whether the state aggregates counties into prosecutorial districts or whether they 
hold non-partisan elections.11 
Although the empirical literature on prosecutor elections is limited, some 
insights can be gleaned from the rich political science literature on legislative and 
judicial elections.12 That literature shows that incumbents enjoy a significant 
advantage in elections, and challengers tend to be strategic about when they will 
run for office. For example, in judicial elections, candidates were more likely to 
challenge incumbents who had been appointed and were standing for their first 
election. 
The political science literature on legislative and judicial elections frequently 
relies on logistic regression analysis to assess what factors result in contested and 
competitive elections. In contrast, the legal literature on prosecutor elections has 
7. Ron Wright studied fifty-four contested elections and created professional profiles of the challengers. He 
discovered that twenty percent of challengers worked in the incumbent’s office at the time of the election, while 
the rest largely worked as defense attorneys. As Wright noted, these challengers would “pay a price well beyond 
election day” if they failed to defeat the incumbent: Those working in the incumbent’s office would either have 
to leave the office or face professional stagnation, while those working as defense attorneys run the risk of getting 
less favorable treatment from the incumbent in plea negotiations and other matters. Ronald F. Wright, Public 
Defender Elections and Popular Control over Criminal Justice, 75 MO. L. REV. 803, 808 (2010). 
8. Carissa Hessick and Michael Morse gathered residency information for lawyers in ten states because, in 
order to run for local prosecutor, candidates must be lawyers with active bar memberships and meet residency 
restrictions. They found that “many districts have an insufficient supply of qualified candidates for local 
prosecutor” and that contested elections in small-population districts is correlated with the number of lawyers 
living in those districts. Hessick & Morse, supra note 3, at 1574–78. 
9. Stephanos Bibas explained the hypothesis as follows: “Nationwide and statewide races may drown out 
county elections in the media. District attorneys enjoy access to press conferences and name recognition. Little- 
known challengers find it difficult to raise money and get the public’s attention. Incumbent district attorneys thus 
enjoy huge advantages.” Stephanos Bibas, Prosecutorial Regulation versus Prosecutorial Accountability, 157 
U. PA. L. REV. 959, 988 (2009). 
10. Hessick and Morse found that incumbents who had been in office for less than five years were challenged 
at a higher rate. Hessick & Morse, supra note 3, at 1568 tbl.7. 
11. See id. at 1578–81 (hypothesizing that consolidating small-population counties into larger districts could 
lead to more contested elections); Ronald F. Wright, Beyond Prosecutor Elections, 67 SMU L. REV. 593, 602–03 
(2014) (noting that “incumbents in non-partisan states . . . face opposition more often” and hypothesizing that 
party affiliation may serve “to prevent some challengers from entering the race”). 
12. See infra Part II. 
34                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 4 ---

--- PAGE 5 (PDF page 5) ---
relied only on anecdotes or simple claims about correlation.13 This Article aims to 
remedy that shortcoming. 
This Article, the first of its kind,14 offers a comprehensive statistical analysis of 
prosecutor elections. Using a national dataset of prosecutor elections that was only 
recently made available,15 
The dataset was collected by the Prosecutors and Politics Project at the University of North Carolina. It 
was made publicly available in 2019, and it can be found here: https://dataverse.unc.edu/dataset.xhtml? 
persistentId=doi:10.15139/S3/ILI4LC. 
it is able to identify several factors which make con-
tested elections more likely. 
Our findings confirm that, like legislative and judicial elections, open elections are 
more likely to draw multiple high-quality candidates. The other major factor that 
affects the rate of contested elections is the population of the district. We also discov-
ered that state election laws contribute to the dearth of contested prosecutor elections. 
In particular, state laws that make local prosecutors a non-partisan office and laws 
that exempt uncontested primary elections from having to appear on the ballot both 
increase the rate of uncontested elections.16 
There are, however, more unexpected results from our analysis. Perhaps most sur-
prising is that under our regression model, there is no statistically significant correla-
tion between either crime rates or prison admission rates with election contestation.17 
Since these are presumably the factors that voters care about the most in a criminal- 
justice-related election,18 it is surprising that there is not a clearer relationship between 
them and whether an election is contested. It is also surprising that an incumbent’s 
length of term in office had no statistically significant effect. Nor did the number of 
lawyers in a jurisdiction.19 
To be sure, we were not able to examine every factor that may have affected contes-
tation and competition. For example, negative media coverage may encourage chal-
lengers to enter the fray or may take votes away from an incumbent.20 But national 
data about media coverage was not available, so we could not include it in our analysis. 
13. See Bibas, supra note 9, at 984–88 (providing anecdotes); Hessick & Morse, supra note 3, at 1557–70 
(making claims based on correlation); Wright, supra note 11, 598–604 (2014) (making claims based on 
correlation); id. at 592–97 (making claims based on correlation). 
14. An unpublished Ph.D. dissertation from 2002 looked at whether prosecutors who made efforts to seem 
more responsive to their constituents enjoyed more public support, and it made some observations about factors 
that affected vote share in contested prosecutor elections. Gerard A. Rainville, Differing Incentives of Appointed 
and Elected Prosecutors and the Relationship Between Prosecutor Policy and Votes in Local Elections 85–99 
(Dec. 3, 2002) (Ph.D. dissertation, American University) (on file with author). But the dissertation examined only 
a limited number of elections and did not examine and the phenomenon of uncontested elections. 
15. 
16. See infra tbl. 3 and text accompanying notes 228–30. 
17. Data limitations on crime rates and prison admissions did not allow us to draw definitive conclusions 
about the relationship between these factors and contestation or competition. See infra notes 241–42 and 
accompanying text. 
18. See generally Sanford C. Gordon & Gregory A. Huber, Citizen Oversight and the Electoral Incentives of 
Criminal Prosecutors, 46 AM. J. POL. SCI. 334 (2002) for the importance of conviction rates in prosecutor elections. 
19. See infra tbl. 6 and text accompanying notes 238–39. 
20. See Rainville, supra note 14, at 99 (noting a relationship between incumbent vote share and scandals 
reported in the media during the time period leading up to an election). 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
35
--- END PAGE 5 ---

--- PAGE 6 (PDF page 6) ---
Despite these limitations, our findings are likely to change the conversation sur-
rounding prosecutor elections. For example, because population size has a signifi-
cant effect on contestation and competition, it may bolster efforts to aggregate 
low-population counties into larger prosecutorial districts.21 
See, e.g., Carissa Byrne Hessick & Cayla Rodney, Opinion, Give Nebraskans a Choice in County Attorney 
Elections, OMAHA WORLD-HERALD (May 16, 2020), https://omaha.com/opinion/midlands-voices-give-nebraskans-a- 
choice-in-county-attorney-elections/article_3fc84a3f-5220-580a-951f-8e453cedc4fe.html. 
And because open 
races are more likely to be contested, it may prompt calls for term limits, which al-
ready enjoy significant public support.22 
See, e.g., Lydia Saad, Americans Call for Term Limits, End to Electoral College, GALLUP (Jan. 18, 2013), 
https://news.gallup.com/poll/159881/americans-call-term-limits-end-electoral-college.aspx (reporting that “three- 
quarters of Americans say that, given the opportunity, they would vote ‘for’ term limits for members of both houses of 
Congress”). 
How to ensure meaningful choices in prosecutor elections has taken on new im-
portance in recent years, as criminal justice reform advocates have sought to elect 
candidates who will use their power to curb mass incarceration.23 But voters cannot 
elect reform prosecutors until and unless they have at least two candidates on the 
ballot. Consequently, understanding what leads to contested elections is an impor-
tant task for those seeking to reform the criminal justice system. 
This Article seeks to improve that understanding. It proceeds in three parts. Part 
I provides context about the power that prosecutors yield, and it explains how elec-
tions are essentially the only check on that power. Part I ends by explaining why 
uncontested prosecutor elections are so troubling and describing the existing legal 
literature on prosecutor elections. 
Part II surveys the political science literature about elections. Although political 
scientists have not studied prosecutor elections, their findings about legislative and 
judicial elections provide helpful insights into the possible reasons why there are 
so few contested prosecutor elections—and even fewer competitive ones. 
Part III uses those insights from the political science literature and the descrip-
tive accounts of prosecutor elections from Part I to assess which factors are likely 
to result in contested prosecutor elections. After developing the list of factors, Part 
III describes the regression models we developed and presents our findings. 
I. PROSECUTORS AND THEIR ELECTIONS 
America incarcerates more of its inhabitants than any other country in the world. 
It has both the highest incarceration rate24 
Sintia Radu, Countries with the Highest Incarceration Rates, U.S. NEWS & WORLD REPORT (May 13, 2019), 
https://www.usnews.com/news/best-countries/articles/2019-05-13/10-countries-with-the-highest-incarceration-rates 
(citing data from the World Prison Brief, an online database hosted by the Institute for Criminal Policy Research at 
the University of London). 
and the largest absolute number of peo-
ple confined in prisons and jails.25 
The 10 countries with the most prisoners, MARKETWATCH (Nov. 24, 2015), https://www.marketwatch. 
com/story/the-10-countries-with-the-most-prisoners-2015-11-24. 
The incarceration explosion is a relatively recent 
21. 
22. 
23. See infra notes 37–41 and accompanying text. 
24. 
25. 
36                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 6 ---

--- PAGE 7 (PDF page 7) ---
phenomenon. As recently as the early 1970s, America’s incarceration rate was not 
particularly high; it was comparable to most European countries. But then the rate 
increased precipitously—from 93 per 100,000 in 1972 to 536 per 100,000 in 
2008.26 
Many institutions and actors played a role in America’s mass incarceration prob-
lem.27 Legislators passed new laws, which criminalized broad swaths of conduct 
and lengthened sentences.28 Police increased their arrest rates.29 Prosecutors 
brought more criminal charges30 and pressured a larger percentage of defendants 
to accept plea bargains.31 Judges failed to meaningfully constrain legislatures, 
police, or prosecutors.32 And the American public appeared to repeatedly affirm its 
desire for such outcomes at the ballot box.33 
See generally, e.g., RACHEL ELISE BARKOW, PRISONERS OF POLITICS: BREAKING THE CYCLE OF MASS 
INCARCERATION (2019) (arguing that America’s harsh criminal justice policy reflects voter fears that have been 
stoked by politicians seeking to win election); Luis Ferre´-Sadurnı´ & Jesse McKinley, How ‘Defund the Police’ 
Roiled Competitive Races in New York, N.Y. TIMES (Nov. 6, 2020), https://www.nytimes.com/2020/11/06/ 
nyregion/election-nyc-defund-police.html (reporting that “several Republican candidates in New York appeared 
to find success by characterizing moderate Democrats in swing districts as anti-law enforcement”). 
Recently, criminal justice reformers have sought to reverse these trends. They 
have rallied against overcriminalization,34 
See, e.g., JOHN-MICHAEL SEIBLER & JONATHAN ZALEWSKI, HERITAGE FOUNDATION, OVERCRIMINALIZATION 
IN THE 115TH CONGRESS (Mar. 1, 2019), https://www.heritage.org/crime-and-justice/report/overcriminalization- 
the-115th-congress; ACLU Report Finds Justice Reinvestment Undermined by Expansion of the “Statehouse-to- 
Prison Pipeline” in 2018, ACLU (Dec. 18, 2018), https://www.aclu.org/press-releases/aclu-report-finds-justice- 
reinvestment-undermined-expansion-statehouse-prison. 
argued in favor of reducing the footprint 
of police activity,35 
See, e.g., Claire Bushey, Defund the Police: How a Protest Slogan Triggered a Policy Debate, FIN. TIMES 
(Apr. 20, 2021), https://www.ft.com/content/76a8080c-cca9-48cd-be81-891a75676adf. 
and more generally appealed to the American public to use 
tools other than the criminal justice system to solve social problems.36 The most 
26. PFAFF, supra note 6, at 1–2. The rate has decreased somewhat since 2008. Id. at 2. 
27. Jeffrey Bellin, The Power of Prosecutors, 94 N.Y.U. L. REV. 171, 171 (2019). 
28. See, e.g., Erik Luna, The Overcriminalization Phenomenon, 54 AM. U. L. REV. 703, 703–11 (2005); Paul 
H. Robinson & Michael T. Cahill, The Accelerating Degradation of American Criminal Codes, 56 HASTINGS L.J. 
633, 635–38 (2005). 
29. See, e.g., BUREAU OF JUSTICE STATISTICS, DEPARTMENT OF JUSTICE, ARREST IN THE UNITED STATES, 
1980–2009 15 tbl.2 (2011) (documenting the rise in arrests from 1980 to 2009). Much of that increase appears 
attributable to drug arrests. OFFICE OF JUSTICE PROGRAMS, DEPARTMENT OF JUSTICE, CRIME AND JUSTICE ATLAS 
2000 40–41 (2000) (documenting increase in arrest rates for drug crimes). 
30. See, e.g., PFAFF, supra note 6, at 71–72; Michael Edmund O’Neill, Understanding Federal Prosecutorial 
Declinations: An Empirical Analysis of Predictive Factors, 41 AM. CRIM. L. REV. 1439, 1444–45 (2004). 
31. See, e.g., Jennifer L. Mnookin, Uncertain Bargains: The Rise of Plea Bargaining in America, 57 STAN. L. 
REV. 1721, 1722–23 (2005); Ronald F. Wright, Trial Distortion and the End of Innocence in Federal Criminal 
Justice, 154 U. PA. L. REV. 79, 88–91 (2005). 
32. See, e.g., District of Columbia v. Wesby, 138 S. Ct. 577, 593 (2018) (stating that, even if police officers 
lacked probable cause to make an arrest, they had qualified immunity from arrestees’ § 1983 false arrest claims); 
Ewing v. California, 538 U.S. 11, 30–31 (2003) (plurality opinion) (refusing to strike down state recidivism law 
that imposed life sentence for stealing three golf clubs); Bordenkircher v. Hayes, 434 U.S. 357 (1978) (permitting 
a prosecutor to threaten a defendant with life in prison in order to pressure the defendant into pleading guilty). 
33. 
34. 
35. 
36. See, e.g., MARK UMBREIT & MARILYN PETERSON ARMOUR, RESTORATIVE JUSTICE DIALOGUE: AN 
ESSENTIAL GUIDE FOR RESEARCH AND PRACTICE 1–33 (2010) (discussing restorative justice as a social 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
37
--- END PAGE 7 ---

--- PAGE 8 (PDF page 8) ---
visible progress that these reformers have made is the election of a new type of 
prosecutor: prosecutors who view their role not simply as an enforcer of criminal 
laws but also as an official who must work to shrink the number of people held in 
prison and jail.37 Dozens of these reform prosecutors—who are sometimes called 
progressive prosecutors—have been elected in the past decade.38 
See Cheryl Corley, Newly Elected DAs Vow to Continue Reforms, End Policies Deemed Unfair, NPR 
(Nov. 26, 2020), https://www.npr.org/2020/11/26/938425725/newly-elected-das-vow-to-continue-reforms-end- 
policies-deemed-unfair; Paige St. John & Abbie VanSickle, Prosecutor Elections Now a Front Line in the 
Justice Wars, MARSHALL PROJECT (May 23, 2018), https://www.themarshallproject.org/2018/05/23/prosecutor- 
elections-now-a-front-line-in-the-justice-wars. 
These reform prosecutors have proven what academics have long argued— 
namely, that because the criminal justice system delegates enormous power to 
prosecutors, a prosecutor’s decisions about how to wield that discretion can 
have a significant impact on the criminal justice system.39 For example, 
Brooklyn’s district attorney, Eric Gonzalez, instituted a new bail policy that 
decreased the number of people held in jail before trial by fifty-eight percent.40 
ERIC GONZALEZ, JUSTICE 2020: AN ACTION PLAN FOR BROOKLYN (2019), http://www.brooklynda.org/wp- 
content/uploads/2019/03/Justice2020-Report.pdf. 
And when Durham, North Carolina elected reform-prosecutor Satana Deberry, 
she reduced the population of her county jail by twelve percent within the first 
six months of taking office.41 
Thomasi McDonald, Six Months in, Satana Deberry Talks about How She’s Changing Durham’s 
Criminal Justice System, INDYWEEK (July 26, 2019), https://indyweek.com/news/durham/satana-deberry-six- 
month-report/. 
Despite the recent attention to prosecutor elections featuring reform candi-
dates,42 
E.g., Jonah E. Bromwich, Can a Progressive Prosecutor Survive a 40% Spike in Homicides?, N.Y. TIMES 
(May 17, 2021), https://www.nytimes.com/2021/05/17/us/philadelphia-prosecutor-election-Larry-Krasner.html; Matt 
Ferner, George Soros, Progressive Groups to Spend Millions to Elect Reformist Prosecutors, HUFFPOST (May 12, 
2018), https://www.huffpost.com/entry/george-soros-prosecutors-reform_n_5af2100ae4b0a0d601e76f06; Liane 
Jackson, Change Agents: A New Wave of Reform Prosecutors Upends the Status Quo, A.B.A. J. (June 1, 2019), 
https://www.abajournal.com/magazine/article/change-agents-reform-prosecutors; Juleyka Lantigua-Williams, Are 
Prosecutors the Key to Justice Reform?, ATLANTIC (May 18, 2016), https://www.theatlantic.com/politics/archive/ 
2016/05/are-prosecutors-the-key-to-justice-reform/483252/. 
prosecutor elections remain a sleepy affair in most of the country. The vast  
movement); David R. Karp, Community Justice: Six Challenges, 27 J. CMTY. PSYCH. 751, 751–52 (1999) 
(discussing various community justice approaches to crime that eschew traditional criminal justice models). 
37. See Benjamin Levin, Imagining the Progressive Prosecutor, 105 MINN. L. REV. 1415, 1419–25 (2021) 
(describing the “progressive prosecutor” movement); see also Note, The Paradox of “Progressive Prosecution,” 
132 HARV. L. REV. 748, 758–68 (2018) (describing and critiquing the movement). 
38. 
39. For a sampling of academic literature about the power of prosecutors, see generally PFAFF, supra note 6; 
Bibas, supra note 9; Davis, supra note 2; Russell M. Gold, Promoting Democracy in Prosecution, 86 WASH. L. 
REV. 69 (2011); Marc L. Miller, Domination & Dissatisfaction: Prosecutors as Sentencers, 56 STAN. L. REV. 
1211 (2004); David Alan Sklansky, The Nature and Function of Prosecutorial Power, 106 J. CRIM. L. & 
CRIMINOLOGY 473 (2016); William J. Stuntz, The Pathological Politics of Criminal Law, 100 MICH. L. REV. 505 
(2001). 
40. 
41. 
42. 
38                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 8 ---

--- PAGE 9 (PDF page 9) ---
majority of prosecutor elections are uncontested.43 And even when they face a 
challenger, most incumbent prosecutors win their elections.44 
Even if voters would not elect reform-minded prosecutors, uncontested prosecu-
tor elections are troubling. The power that is delegated to prosecutors is largely 
unreviewable within the criminal justice system—either as a matter of law or as a 
matter of practice. The only real check on that power is democracy—the ability of 
voters to hold their local prosecutors accountable for their decisions. But when 
prosecutors face no challenger, how they wield their discretion often goes unno-
ticed, leaving the public in the dark about some of the most consequential decisions 
in the criminal justice system. 
A. The Power of Prosecutors 
To understand the powers that prosecutors wield, it is first necessary to under-
stand that not everyone who is arrested is charged with a crime, that most cases are 
disposed of through plea bargaining, and that prosecutors’ decisions about charg-
ing and plea bargaining are largely not subject to judicial review. The combination 
of these three facts gives prosecutors a significant amount of discretion, and that 
discretion gives them power.45 
When someone commits a crime, a prosecutor must decide whether to pursue crim-
inal charges. To some extent, that decision initially lies with police because they are 
the officials who make arrests. But whether to pursue criminal charges against a per-
son who has been arrested is an independent decision made by a person in the local 
prosecutor’s office.46 That is to say, the mere fact that a person is arrested for commit-
ting a crime does not mean that the person will face criminal charges. 
A prosecutor’s decision whether to bring charges will depend, at least in part, on 
whether the prosecutor believes her office can prove the charges beyond a reasona-
ble doubt. As a legal matter, prosecutors may bring charges if they have probable  
43. Hessick & Morse, supra note 3, at 1563 & tbl.5 (finding that only thirty percent of elected prosecutors 
faced an opponent in either a primary or a general election). 
44. Id. at 1561–64 & tbl.4 (finding that incumbent prosecutors facing challengers win 66% of general 
elections and 51% of primary elections); Wright, supra note 11, at 600–01 & tbl.1 (finding that incumbent 
prosecutors facing challengers win 70% of general elections and 64% of primary elections); Ronald F. Wright, 
Jeffrey L. Yates & Carissa Byrne Hessick, Electoral Change and Progressive Prosecutors, 19 OHIO ST. J. CRIM. 
L. 125, 144 (2021) (finding that the “victory rate for incumbent candidates was 91%” and that incumbents “were 
more likely to win than challengers, even after controlling for district population, extra candidates in a race, and 
candidate demographics”). 
45. See Davis, supra note 2, at 400–38 (equating prosecutors’ discretion with power); Peter L. Markowitz, 
Prosecutorial Discretion Power at Its Zenith: The Power to Protect Liberty, 97 B.U. L. REV. 489, 490–91 (2017) 
(defining prosecutorial discretion as “the power of the Executive to determine how, when, and whether to initiate 
and pursue enforcement proceedings” and explaining that prosecutors can use this discretion “to achieve goals 
that they could not otherwise realize through the legislative process”). 
46. See Davis, supra note 2, at 408–10 (describing the importance of prosecutorial charging decisions and 
noting that, in some offices, the decision merely formalizes law enforcement’s decision to make an arrest). 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
39
--- END PAGE 9 ---

--- PAGE 10 (PDF page 10) ---
cause to believe that a defendant has committed a crime.47 That is a much lower 
standard than proof beyond a reasonable doubt. But pursuing charges when only 
probable cause exists runs afoul of best practices.48 As a result, if a witness seems 
unreliable or physical evidence was not collected, then the prosecutor is likely to 
decline to prosecute the case.49 
But not all declination decisions are about evidence. Some are about policy— 
policies about assessing individual cases or policies about categories of cases. 
Prosecutors may, for example, decide not to bring charges in individual cases 
when mitigating facts are present or when the defendant’s conduct doesn’t seem to 
fit within the core of the crime.50 
Some decisions not to prosecute are categorical. Put differently, some prosecu-
tors have adopted policies about when to decline prosecution for certain categories 
of cases.51 For example, in 2013, the Department of Justice issued a memorandum 
to federal prosecutors identifying the circumstances under which prosecutors 
should decline to bring drug charges that carry mandatory minimum sentences.52 
Memorandum from Eric H. Holder, U.S. Att’y Gen., on Dep’t Policy on Charging Mandatory Minimum 
Sentences and Recidivist Enhancements in Certain Drug Cases 2 (Aug. 12, 2013), https://www.justice.gov/sites/ 
default/files/oip/legacy/2014/07/23/ag-memo-department-policypon-charging-mandatory-minimum-sentences- 
recidivist-enhancements-in-certain-drugcases.pdf. 
And when she was elected district attorney in Boston, Massachusetts, Rachael 
Rollins established an office policy declining to bring charges in certain low-level 
cases.53 
47. E.g., Bordenkircher v. Hayes, 434 U.S. 357, 364 (1978) (“[S]o long as the prosecutor has probable cause 
to believe that the accused committed an offense defined by statute, the decision whether or not to prosecute, and 
what charge to file or bring before a grand jury, generally rests entirely in his discretion.”). 
48. See A.B.A. CRIMINAL JUSTICE STANDARDS FOR THE PROSECUTION FUNCTION 3-4.3(a) (Ronald D. Rotunda 
& John S. Dzienkowski eds., 4th ed. 2017) (“A prosecutor should seek or file criminal charges only if the 
prosecutor reasonably believes that the charges are supported by probable cause, that admissible evidence will be 
sufficient to support conviction beyond a reasonable doubt, and that the decision to charge is in the interests of 
justice.”). 
49. See Fairfax, supra note 6, at 1254–56 (stating that “[p]rosecutors often decline prosecution because they 
do not have the evidence they feel is necessary to secure a conviction on a given charge” and describing 
evidentiary concerns that might lead a prosecutor to decline to prosecute); Richard S. Frase, The Decision to File 
Federal Criminal Charges: A Quantitative Study of Prosecutorial Discretion, 47 U. CHI. L. REV. 246, 262 (1980) 
(reporting the most common reasons for federal declination of charges include “insufficient evidence of a 
criminal act”). 
50. See, e.g., Frase, supra note 49, at 262 (identifying “small amount of loss by the victims[,] . . . small 
amount of contraband, such as drugs or guns[,] . . . [and] the isolated nature of the defendant’s act” as common 
reasons for declination of charges); Kay L. Levine, The Intimacy Discount: Prosecutorial Discretion, Privacy, 
and Equality in the Statutory Rape Caseload, 55 EMORY L.J. 691, 705–06 (2006) (documenting nonenforcement 
or early disposition of statutory rape cases when the victim and offender are in a romantic relationship). 
51. See W. Kerrel Murray, Populist Prosecutorial Nullification, 96 N.Y.U. L. REV. 173, 248–52 (2021) 
(collecting examples); Jessica A. Roth, Prosecutorial Declination Statements, 110 J. CRIM. L. & CRIMINOLOGY 
477, 489 n.35 (2020) (same). 
52. 
53. Andrea Estes & Shelley Murphy, Stopping Injustice or Putting the Public at Risk? Suffolk DA Rachael 
Rollins’s Tactics Spur Pushback, BOS. GLOBE (July 6, 2019), https://www.bostonglobe.com/metro/2019/07/06/ 
stopping-injustice-putting-public-risk-suffolk-rachael-rollins-tactics-spur-pushback/IFC6Rp4tVHiVhOf2t97bFI/ 
story.html. 
40                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 10 ---

--- PAGE 11 (PDF page 11) ---
Although some offices may articulate official enforcement criteria—that is, ei-
ther bright-line rules that must be satisfied or multiple factors that a prosecutor 
must consider and weigh before bringing charges—other offices rely on word-of- 
mouth or informal norms.54 Even when offices adopt formal policies, there is no 
legal requirement that such criteria be communicated to the public.55 Nor is there 
any requirement that the same criteria be applied across cases.56 
Decisions not to prosecute are often driven by resources. Prosecutors do not 
have the resources or the manpower to investigate and charge every possible crimi-
nal case.57 Indeed, interviews with prosecutors indicate that a lack of support staff 
within their offices impedes their ability to prepare or investigate cases—especially 
cases involving witnesses or victims—thus affecting decisions about what cases to 
pursue.58 
Courts do not review prosecutors’ declination decisions. “[T]he decision 
whether or not to prosecute, and what charge to file or bring before a grand jury, 
generally rests entirely in [the prosecutor’s] discretion.”59 The Supreme Court has 
justified giving prosecutors “‘broad discretion’ as to whom to prosecute”60 by stat-
ing that “the decision to prosecute is particularly ill-suited to judicial review.”61 As 
the Court explained in Wayte v. United States: 
Such factors as the strength of the case, the prosecution’s general deterrence 
value, the Government’s enforcement priorities, and the case’s relationship to 
the Government’s overall enforcement plan are not readily susceptible to the 
kind of analysis the courts are competent to undertake. Judicial supervision in 
this area, moreover, entails systemic costs of particular concern. Examining 
the basis of a prosecution delays the criminal proceeding, threatens to chill 
law enforcement by subjecting the prosecutor’s motives and decisionmaking 
to outside inquiry, and may undermine prosecutorial effectiveness by 
54. Compare Don Stemen & Bruce Frederick, Rules, Resources, and Relationships: Contextual Constraints 
on Prosecutorial Decision Making, 31 QUINNIPIAC L. REV. 1, 27–28 (2013) (discussing office-wide bright-line 
rules), with id. at 19 (discussing informal norms). 
55. See, e.g., Nat’l Ass’n of Crim. Def. Laws. v. Dep’t of Just. Exec. Off. for U.S. Att’ys, 844 F.3d 246, 252 
(D.C. Cir. 2016) (denying defense attorneys’ Freedom of Information Act request for a copy of the Department 
of Justice’s Federal Criminal Discovery Blue Book on grounds that would similarly exempt enforcement and 
nonenforcement policies from disclosure). 
56. See Carissa Byrne Hessick, The Myth of Common Law Crimes, 105 VA. L. REV. 965, 1001 (2019) 
(“Prosecutors regularly make decisions on an ad hoc basis. . . . There is no formal legal requirement that 
prosecutors act consistently in different cases, nor are there any effective practical mechanisms to make 
consistency a political requirement.” (footnotes omitted)). 
57. Robert H. Jackson, The Federal Prosecutor, 31 J. AM. INST. CRIM. L. & CRIMINOLOGY 3, 5 (1940) (“One 
of the greatest difficulties of the position of prosecutor is that he must pick his cases, because no prosecutor can 
even investigate all of the cases in which he receives complaints. If the Department of Justice were to make even 
a pretense of reaching every probable violation of federal law, ten times its present staff would be inadequate.”). 
58. Stemen & Frederick, supra note 54, at 39–40. Notably, cases involving witnesses or victims tend to be 
cases of property crime and violent crime. Drug cases “were less affected.” Id. 
59. Bordenkircher v. Hayes, 434 U.S. 357, 364 (1978). 
60. Wayte v. United States, 470 U.S. 598, 607 (1985). 
61. Id. 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
41
--- END PAGE 11 ---

--- PAGE 12 (PDF page 12) ---
revealing the Government’s enforcement policy. All these are substantial con-
cerns that make the courts properly hesitant to examine the decision whether 
to prosecute.62 
A prosecutor’s power to decline to bring charges is nearly absolute.63 If a prose-
cutor decides to bring charges, then some limitations on the charging power begin 
to appear. Most notably, a prosecutor must have probable cause to support any 
charges brought.64 And even if she has probable cause, a prosecutor is not permit-
ted to bring charges that are motivated only by a defendant’s race, religion, or other 
protected status.65 But judges have severely undercut this limitation on prosecuto-
rial charging powers by refusing to allow most defendants to obtain discovery to 
uncover evidence of discriminatory motivations.66 
In theory, a prosecutor’s decision to bring charges should be reviewed by a jury 
at trial—the jury will hear the evidence and decide whether the defendant is guilty. 
But that rarely happens in the modern criminal justice system. In about 97% of fed-
eral cases, a defendant will plead guilty rather than proceed to trial.67 When a de-
fendant pleads guilty, a jury does not decide whether the prosecutor has proven 
each element of the crime charged beyond a reasonable doubt; instead, the prose-
cutor and the defense attorney will negotiate an outcome—usually that the defend-
ant pleads guilty in return for the prosecutor dismissing other charges, agreeing to 
a certain sentence, or making a favorable sentencing recommendation to the  
62. Id. at 607–08. 
63. See Heckler v. Chaney, 470 U.S. 821, 832 (1985) (“[A]n agency’s refusal to institute proceedings shares 
to some extent the characteristics of the decision of a prosecutor in the Executive Branch not to indict—a 
decision which has long been regarded as the special province of the Executive Branch, inasmuch as it is the 
Executive who is charged by the Constitution to ‘take Care that the Laws be faithfully executed.’” (quoting U.S. 
CONST. art. II, § 3)). 
64. Bordenkircher v. Hayes, 434 U.S. 357, 364 (1978). 
65. See Steven Alan Reiss, Prosecutorial Intent in Constitutional Criminal Procedure, 135 U. PA. L. REV. 
1365, 1372 (1987) (collecting cases). 
66. See United States v. Bass, 536 U.S. 862, 863 (2002); United States v. Armstrong, 517 U.S. 456, 458 
(1996); United States v. Washington, 869 F.3d 193, 215 (3d Cir. 2017). The court in Washington commented that 
Armstrong/Bass has proven to be a demanding gatekeeper. In developing it, the Supreme Court 
sought to “balance[] the Government’s interest in vigorous prosecution and the defendant’s inter-
est in avoiding selective prosecution” by creating a standard that, while difficult to meet, derived 
from “ordinary equal protection standards” and was not “insuperable.” The lived experience, how-
ever, has resembled less a challenge and more a rout, as practical and logistical hurdles abound— 
especially to proving a negative. The government itself concedes that “neither the Supreme Court 
nor this Court has ever found sufficient evidence to permit discovery of a prosecutor’s decision- 
making policies and practices.” 
Id (alteration in original). See also Richard H. McAdams, Race and Selective Prosecution: Discovering the 
Pitfalls of Armstrong, 73 CHI.-KENT L. REV. 605, 623 (1998) (“[F]or many crimes, Armstrong makes discovery 
impossible even where the defendant is a victim of selective prosecution.”). 
67. CARISSA BYRNE HESSICK, PUNISHMENT WITHOUT TRIAL: WHY PLEA BARGAINING IS A BAD DEAL 24 
(2021). 
42                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 12 ---

--- PAGE 13 (PDF page 13) ---
judge.68 When they negotiate with defendants, prosecutors have the upper hand. 
Defendants rarely have any leverage in those negotiations, and so they often must 
agree to whatever terms the prosecutor is offering.69 Turning down a plea offer 
would require the defendant to proceed to trial. Trials are unattractive alternatives 
to guilty pleas because defendants who are convicted at trial receive much longer 
sentences: they are unable to reduce their exposure by getting charges with manda-
tory minimum sentences dismissed as part of a plea deal, and judges routinely 
impose a “trial penalty” in the form of a higher sentence on defendants who insist 
on a trial.70 
See generally NAT’L ASS’N OF CRIM. DEF. LAWS., THE TRIAL PENALTY: THE SIXTH AMENDMENT RIGHT 
TO TRIAL ON THE VERGE OF EXTINCTION AND HOW TO SAVE IT (2018), https://www.nacdl.org/getattachment/ 
95b7f0f5-90df-4f9f-9115-520b3f58036a/the-trial-penalty-the-sixth-amendment-right-to-trial-on-the-verge-of- 
extinction-and-how-to-save-it.pdf (explaining the phenomenon of the trial penalty); see also Nancy J. King, 
David A. Soule, Sara Steen & Robert R. Weidner, When Process Affects Punishment: Differences in Sentences 
after Guilty Plea, Bench Trial, and Jury Trial in Five Guidelines States, 105 COLUM. L. REV. 959, 973–75 
(2005) (finding the trial penalty effect in data from five states). 
When a defendant and a prosecutor negotiate for an outcome, judges have the 
power to reject these plea bargains.71 But they rarely do: most judges are content to 
allow the prosecutor and the defense attorney to come to an agreement.72 Only in 
rare cases will judges reject those agreements—and when they do so, it is almost 
always because they believe the agreement is too lenient.73 
Plea bargains not only allow prosecutors to evade juries, but also can constrain 
judges’ sentencing power. Prosecutors can limit judges’ sentencing power by 
negotiating over the precise sentence or sentencing range to be imposed if the 
judge accepts the bargain.74 Judges do not have to accept the agreed upon sentence 
because they can reject the plea bargain.75 But as previously mentioned, judges are 
rarely willing to do that. And even if a defendant does not agree to a particular 
68. In modern American plea bargaining, “[p]rosecutors and defendants negotiate over both the offense of 
conviction (‘charge bargaining’), and the sentence (‘sentence bargaining’).” William Ortman, Second-Best 
Criminal Justice, 96 WASH. U. L. REV. 1061, 1071 (2019). 
69. See, e.g., Susan R. Klein, Enhancing the Judicial Role in Criminal Plea and Sentence Bargaining, 84 TEX. 
L. REV. 2023, 2037–38 (2006) (describing the “enormous power of federal prosecutors to persuade suspects to 
accept guilty pleas”); Ronald Wright & Marc Miller, Honesty and Opacity in Charge Bargains, 55 STAN. L. REV. 
1409, 1415 (2003) (noting that the guilty pleas may be the result of “prosecutorial domination”). 
70. 
71. See, e.g., United States v. Smith, 417 F.3d 483, 487 (5th Cir. 2005); United States v. Gamboa, 166 F.3d 
1327, 1330 (11th Cir. 1999); United States v. Carrigan, 778 F.2d 1454, 1462 (10th Cir. 1985); United States v. 
Moore, 637 F.2d 1194, 1196 (8th Cir. 1981). 
72. See, e.g., Stuntz, supra note 39, at 596 (“Even when sentencing was everywhere discretionary, judges 
tended to defer to bargained-for sentencing recommendations.”). 
73. See Darryl Brown, The Judicial Role in Criminal Charging and Plea Bargaining, 46 HOFSTRA L. REV. 63, 
81 (2017) (explaining why judges have more discretion to reject proposed plea bargains that are too lenient than 
those that are too harsh). 
74. See Stephanos Bibas, Regulating the Plea-Bargaining Market: From Caveat Emptor to Consumer 
Protection, 99 CALIF. L. REV. 1117, 1142 (2011) (distinguishing between two different types of sentencing-based 
plea bargains: a “stipulated-sentence agreement,” which “binds the judge to a particular sentence if the judge 
accepts the agreement,” and a “nonbinding” sentence bargain, which “leave[s] judges free to impose different 
sentences”). 
75. See, e.g., FED. R. CRIM. P. 11(c)(5). 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
43
--- END PAGE 13 ---

--- PAGE 14 (PDF page 14) ---
sentence as part of the plea bargain, the prosecutor can narrow the judge’s sentenc-
ing options by selecting the specific charge of conviction—after all, different 
charges contain different sentencing ranges,76 and the Supreme Court has said that 
states are free to enact overlapping crimes with different sentencing ranges.77 
Overlapping crimes basically allow prosecutors to choose how much punishment a 
defendant will receive. 
As the preceding paragraphs indicate, prosecutors wield significant power in the 
criminal justice system. To be clear, prosecutors are not the only officials with 
power. Legislatures can change laws, police can decline to arrest, and judges could 
exercise more oversight over charging and plea bargaining.78 But the fact that other 
officials also have power does not diminish how much power prosecutors have. 
And because prosecutors have largely unlimited power not to prosecute people, 
criminal justice reformers have begun to pay more attention to prosecutor elections 
and to support candidates who promise to use their power to incarcerate less. 
B. The Election of Prosecutors 
The United States is unique in its decision to elect its prosecutors. Forty-five of 
the fifty states elect local prosecutors who bear the primary responsibility for bring-
ing felony prosecutions in their jurisdictions.79 Many states elect one prosecutor 
per county, but some consolidate their counties into larger prosecutorial districts.80 
These local prosecutor elections accomplish two important objectives. First, 
they provide democratic accountability for prosecutorial decisions. Because prose-
cutors’ charging and plea-bargaining decisions are largely insulated from judicial 
review,81 it is important that voters have the opportunity to choose a prosecutor 
who shares their priorities about which crimes to pursue most vigorously.82 
Allowing constituents a voice (albeit an indirect one) in those decisions also gives 
the decisions more legitimacy.83 
76. Bibas, supra note 9, at 971; Darryl K. Brown, Judicial Power to Regulate Plea Bargaining, 57 WM. & 
MARY L. REV. 1225, 1233 (2016). 
77. United States v. Batchelder, 442 U.S. 114, 123 (1979). 
78. See Bellin, supra note 27, at 191–208 (discussing the power of non-prosecutorial institutions to reduce 
mass incarceration). 
79. Hessick & Morse, supra note 3, at 1550–51 & 1550 tbl.1 (describing the method of selection for local 
prosecutors in each state and identifying those states that do not elect their local prosecutors). 
80. Id. at 1553–54 & 1550 tbl.1 (identifying states that consolidate counties). 
81. See Bibas, supra note 9, at 969–75 (describing the lack of judicial review). 
82. Id. at 991 (stating that “in a democracy, voters are prosecutors’ principals” and thus voters “have the right 
to influence prosecutorial policy in their locale”); Gold, supra note 39, at 71 (“Because prosecutors act on the 
public’s behalf, their decisions should reflect their constituents’ preferences.”). 
83. As a general matter, democratic accountability is seen as conferring legitimacy on institutions and 
decisions, see Eric Stein, International Integration and Democracy: No Love at First Sight, 95 AM. J. INT’L L. 
489, 494 (2001), while democratic deficits are seen as hurdles to legitimacy, see David J. Arkush, Direct 
Republicanism in the Administrative Process, 81 GEO. WASH. L. REV. 1458, 1471 (2013). But see Kenneth S. 
Klein, Weighing Democracy and Judicial Legitimacy in Judicial Selection, 23 TEX. REV. L. & POL. 269, 292–94 
(2018) (arguing that, when it comes to judges, elections and politicization actually undermine legitimacy). 
44                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 14 ---

--- PAGE 15 (PDF page 15) ---
The second objective of prosecutor elections is local control. Letting a county or 
a district select its own prosecutor allows local communities to help shape prosecu-
torial policies.84 For example, a community that wants more aggressive prosecu-
tion of drug crimes can elect a prosecutor who promises to more actively pursue 
such cases. And a community that wants to rely on treatment rather than prison for 
drug users can elect a prosecutor who promises to establish diversion programs 
and other alternatives. 
To be clear, local control of criminal justice policy is limited. Most obviously, 
in all states, the state legislature determines what qualifies as a felony for every 
prosecutorial district. Some states further limit local control by centralizing all 
criminal appeals85 or by providing a mechanism for state officials to remove partic-
ular cases from the local prosecutor.86 But even in those states, the vast majority of 
charging and plea-bargaining decisions are made by the local prosecutor, who is 
answerable only to her constituents. 
Democratic accountability and local control may be the objectives of electing 
local prosecutors, but it is not clear that local elections actually accomplish either 
of those objectives in a meaningful way. In order for local communities to have 
input, they must have a choice in their prosecutor election. Yet the majority of 
local prosecutor elections are uncontested. According to a recent national study, 
only thirty percent of elected prosecutors faced a challenger in either their primary 
or their general election.87 The rest were elected without voters ever having any 
choice in the matter. 
Even when voters have a choice in an election, they may not have sufficient in-
formation to cast an informed ballot. Many charging and bargaining decisions are 
made outside of the public’s view.88 And historically, the media coverage of prose-
cutor elections has tended to focus on topics other than office policies about how to 
wield prosecutorial discretion.89   
84. See generally Murray, supra note 51 (arguing that local elections provide democratic legitimacy for 
prosecutorial nonenforcement decisions). 
85. For example, in New Mexico, the “appellate section of the attorney general office represents the state in 
all criminal appeals.” Thomas B. Marvell, Abbreviate Appellate Procedure: An Evaluation of the New Mexico 
Summary Calendar, 75 JUDICATURE 86, 87 (1991). See also Scott M. Matheson, Jr., Constitutional Status and 
Role of the State Attorney General, 6 U. FLA. J.L. & PUB. POL’Y 1, 24 (1993) (“In many states, the majority of 
criminal investigation and prosecution through trial is carried out at the local government level with the state 
attorney general’s office handling most of the criminal appeals.”). 
86. See Tyler Quinn Yeargain, Comment, Discretion Versus Supersession: Calibrating the Power Balance 
Between Local Prosecutors and State Officials, 68 EMORY L.J. 95, 110–26 (2018) (describing different 
approaches in various states). 
87. Hessick & Morse, supra note 3, at 1563 tbl.5. 
88. See Lauren M. Ouziel, Prosecution in Public, Prosecution in Private, 97 NOTRE DAME L. REV. 1071, 
1084–1107 (2022) (cataloguing key prosecutorial decisions that are made in secrecy). 
89. Bibas, supra note 9, at 984–87; Ronald F. Wright, How Prosecutor Elections Fail Us, 6 OHIO ST. J. CRIM. 
L. 581, 597–603 (2009). 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
45
--- END PAGE 15 ---

--- PAGE 16 (PDF page 16) ---
Media coverage of prosecutor elections may have improved in recent years— 
especially in races featuring a reform candidate.90 
For examples of recent, substantive coverage, see Larry Altman, Los Angeles DA Candidates Lacey, 
Gascon Clash on Police Racism, Death Penalty at Debate, L.A. DAILY NEWS (Oct. 4, 2020), https://www. 
dailynews.com/2020/10/04/los-angeles-da-candidates-lacey-gascon-swap-barbs-at-debate/; Noah Goldberg, 
Queens DA Candidates Spar over Experience, Policy at Eagle Forum, QUEENS DAILY EAGLE (June 14, 2019), 
https://queenseagle.com/all/queens-da-candidates-spar-over-experience-policy-at-eagle-forum; Deanna Paul, 
Manhattan District Attorney Election: A Guide to the Eight Democratic Candidates, WALL ST. J. (May 17, 
2021), https://www.wsj.com/articles/manhattan-district-attorney-election-a-guide-to-the-eight-democratic-
candidates-11621252802
 
; Michael Tanenbaum, Philadelphia District Attorney Primary between Larry 
Krasner and Carlos Vega Puts Reform and Results on Trial, PHILLY VOICE (May 14, 2021), https://www. 
phillyvoice.com/2021-primary-philly-district-attorney-larry-krasner-carlos-vega-democrats/. 
The rate of contested elections 
may also have increased—at least in larger jurisdictions—but it remains quite 
low.91 And the rate of competitive elections is lower still.92 
The lack of contested and competitive elections means that voters have few 
opportunities to act as a check on the enormous power that their local prosecutors 
yield. The check that voters provide is not merely theoretical: previous studies of 
U.S. congressional elections and state judicial elections establish that electoral 
contestation and competition create clear links between citizens and their govern-
ment.93 Numerous studies show that competitive elections make legislators more 
likely to defer to constituent opinion when casting votes.94 And there is evidence 
that competitive elections make state court justices less likely to dissent on key 
issues like the death penalty.95 The reason for this responsiveness is simple—if 
elected officials fail to account for constituent opinion, they risk defeat at the ballot 
box.96 
There is also evidence that uncontested and uncompetitive elections negatively 
impact both the performance of elected officials and the relationship between those 
officials and their constituents. For example, state legislators who are not chal-
lenged in elections are more likely to miss roll call votes and less likely to 
90. 
91. See Wright et al., supra note 44, at 147 (“The elections in the years 2012–2015 left incumbents unopposed 
in 79% of the primaries and in 72% of their general elections. In the latest four years, 2017–2020, the percentage 
of incumbents who ran unopposed dropped to 70% in the primaries and 55% in the general elections.”). 
92. See Hessick & Morse, supra note 3, at 1563 tbl.5. 
93. See Robert S. Erikson, Constituency Opinion and Congressional Behavior: A Reexamination of the 
Miller-Stokes Representation Data, 22 AM. J. POL. SCI. 511, 532 (1978); Chris W. Bonneau & Melinda Gann 
Hall, Predicting Challengers in State Supreme Court Elections: Context and the Politics of Institutional Design, 
56 POL. RSCH. Q. 337, 346 (2003); Brandice Canes-Wrone, David W. Brady & John F. Cogan, Out of Step, Out 
of Office: Electoral Accountability and House Members’ Voting, 96 AM. POL. SCI. REV. 127, 137 (2002); Warren 
E. Miller & Donald E. Stokes, Constituency Influence in Congress, 57 AM. POL. SCI. REV. 45, 45 (1963). 
94. E.g., Austin Bussing, Will Patton, Jason M. Roberts & Sarah A. Treul, The Electoral Consequences of 
Roll Call Voting: Health Care and the 2018 Election, 44 POL. BEHAV. 157, 160 (2020); cf. Brendan Nyhan, Eric 
McGhee, John Sides, Seth Masket & Steven Greene, One Vote Out of Step? The Effects of Salient Roll Call Votes 
in the 2010 Election, 40 AM. POL. RSCH. 844, 844 (2012) (arguing that Congress members in 2010 whose votes 
are perceived as displaying ideological differences with constituents suffered heavy electoral damage as a result). 
95. See, e.g., Melinda Gann Hall & Paul Brace, Integrated Models of Judicial Dissent, 55 J. POLITICS 914, 929 
(1993) (“[T]he probability of a justice dissenting from a conservative decision of the court is a function of 
electoral politics and a concern with constituency preferences on the issue of the death penalty.”). 
96. See, e.g., Canes-Wrone et al., supra note 93, at 137; Bussing et al., supra note 94, at 160. 
46                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 16 ---

--- PAGE 17 (PDF page 17) ---
introduce bills.97 In Congress, those members who are not contested at the ballot 
box are less effective than their colleagues who are challenged.98 Additionally, 
even research that argues in favor of noncompetitive elections finds that voters 
hold less favorable views of incumbents when they are elected in uncontested 
elections.99 
In sum, prosecutors wield enormous power in the criminal justice system. 
Elections are one of the few checks on that power. And so, it is important to under-
stand why so few prosecutors run unopposed. That is the task taken up in the 
remaining Parts of this Article. 
II. LESSONS FROM THE POLITICAL SCIENCE LITERATURE 
Although the academic literature on prosecutor elections is quite thin,100 elec-
tions more generally have long been a subject of academic study. There is a rich 
political science literature on what leads to contested and competitive elections. 
The vast majority of that literature focuses on federal elections, but state legisla-
tures and state judicial elections have also garnered a share of the attention. The 
findings from that literature, which are described more fully below, helped inform 
the hypotheses and analyses of prosecutor elections presented in Part III. 
Contestation and competition are related but distinct concepts. We define an 
uncontested race as one in which the winning candidate was the only candidate on 
the ballot. In uncontested elections, the result is known even before a single ballot 
is cast. An uncompetitive election, on the other hand, is one in which there is tech-
nically a choice—that is to say, there were at least two candidates on the ballot— 
but the losing candidate offered only token opposition to the winner. All uncon-
tested races are, by definition, uncompetitive. But a contested election in which the 
losing candidate receives less than twenty percent of votes cast is uncompetitive 
because the winning candidate’s victory was essentially assured.101 
97. See, e.g., David M. Konisky & Michiko Ueda, The Effects of Uncontested Elections on Legislator 
Performance, 36 LEGIS. STUD. Q. 199, 200 (2011). 
98. See, e.g., CRAIG VOLDEN & ALAN E. WISEMAN, LEGISLATIVE EFFECTIVENESS IN THE UNITED STATES 
CONGRESS: THE LAWMAKERS 44, 46 (2014). 
99. See, e.g., Thomas L. Brunell & Justin Buchler, Ideological Representation and Competitive 
Congressional Elections, 28 ELECTORAL STUD. 448, 448, 454 (2009). 
100. The legal empirical literature on the topic is limited to Hessick & Morse, supra note 3, which is based on 
a national dataset, Wright, supra note 11, which updated a 15-state dataset originally discussed in Wright, supra 
note 89, and Wright et al., supra note 44, which examines the largest 200 jurisdictions, some for multiple election 
cycles. In addition, there is a distinct, but related non-legal literature on the behavior of prosecutors in the time 
period preceding elections. See, e.g., supra note 4. 
101. Literature in political science suggests contested races can be classified as uncompetitive if the losing 
candidate captures less than ten to twenty-five percent of the vote. See, e.g., Barry C. Burden, Candidate 
Positioning in US Congressional Elections, 34 BRIT. J. POL. SCI. 211, 221 (2004) (suggesting less than ten 
percent is uncompetitive); Caitlin E. Jewitt & Sarah A. Treul, Ideological Primaries and Their Influence in 
Congress, in ROUTLEDGE HANDBOOK OF PRIMARY ELECTIONS 214 (Robert G. Boatright ed., 2018) [hereinafter 
Ideological Primaries] (suggesting less than twenty-five percent is uncompetitive); see also Caitlin E. Jewitt & 
Sarah A. Treul, Competitive Primaries and Party Division in Congressional Elections, 35 ELECTORAL STUD. 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
47
--- END PAGE 17 ---

--- PAGE 18 (PDF page 18) ---
Contestation and competition are frequent topics of study in political science 
because a lack of meaningful choice at the ballot box is seen as normatively con-
cerning. When elections are uncontested or uncompetitive, they no longer serve as 
a democratic accountability mechanism. A large number of uncontested elections 
might suggest that constituents do not have a means by which to express their pref-
erences or to influence the direction of policy and government more generally. As 
Cain notes, “[a]t a minimum, democracy requires contestation for critical offices, 
meaning that voters get a choice and can hold office holders accountable for their 
actions and decisions by voting them out of office.”102 
As the rest of this Part explains, the political science literature has identified a 
strong advantage for incumbents and strategic entry behavior by potential candi-
dates as major explanations for the lack of contestation or competition in elections. 
The strategic behavior of potential challengers leads them to wait for elections 
when incumbents appear weak or—better yet—when there is no incumbent in the 
race. These strategic entry decisions limit both contestation and competition, as the 
best candidates wait to make a bid for office. State judicial races suggest that other 
factors, including the supply of viable candidates, such as the number of lawyers in 
the jurisdiction, may also play a role. 
A. Brief Note on the Incumbency Advantage 
Any discussion of the empirical literature on elections must be understood 
against the backdrop of the incumbency advantage. The incumbency advant-
age is the well-documented edge that incumbents who are running for reelec-
tion hold over their challengers. The incumbency advantage has been 
documented across many different types of elections and across different time 
periods. 
At the federal level, incumbents are often challenged, but many of these chal-
lengers do not have a realistic chance of unseating the incumbent. As noted above, 
the best challengers typically wait to run until an incumbent steps down. When it 
comes to congressional elections, incumbency may be the number one predictor of 
candidate success.103 For the last two decades, incumbent reelection rates in con-
gressional elections have exceeded ninety percent in all but the year 2010, when 
140, 143 (2014) (defining competitiveness in terms of margin of victory). For more on thresholds and why we 
selected twenty percent, see infra note 207. 
102. Bruce E. Cain, More or Less: Searching for Regulatory Balance, in RACE, REFORM, AND REGULATION OF 
THE ELECTORAL PROCESS: RECURRING PUZZLES IN AMERICAN DEMOCRACY 263, 266 (Guy-Uriel E. Charles, 
Heather K. Gerken & Michael S. Kang eds., 2011). 
103. See, e.g., Jamie L. Carson, Erik J. Engstrom & Jason M. Roberts, Candidate Quality, the Personal Vote, 
and the Incumbency Advantage in Congress, 101 AM. POL. SCI. REV. 289, 297 (2007); Gary W. Cox & Jonathan 
N. Katz, Why Did the Incumbency Advantage in U.S. House Elections Grow?, 40 AM. J. POL. SCI. 478, 478 
(1996); Robert S. Erikson, Malapportionment, Gerrymandering, and Party Fortunes in Congressional Elections, 
66 AM. POL. SCI. REV. 1234, 1244 (1972); David R. Mayhew, Congressional Elections: The Case of the 
Vanishing Marginals, 6 POLITY 295, 313 (1974). 
48                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 18 ---

--- PAGE 19 (PDF page 19) ---
the reelection rate was eighty-five percent.104 Recognizing this, a voluminous liter-
ature developed to measure and understand the reasons for the incumbency 
advantage. 
Initially, scholars attributed the incumbency advantage to institutional features 
such as mailings, staff, and salary;105 legislative casework;106 and redistricting.107 
Other work suggests the advantage results from the member’s home style—her 
behavior back home in the district,108 the strategic entry and exit decisions of can-
didates,109 and the personal vote.110 Whatever the precise reasons for the incum-
bency advantage, the experience of running for and holding office clearly matters 
to electoral success. 
For non-incumbents, the number one predictor of electoral success has been pre-
vious experience in elective office.111 These “quality candidates” have several 
attributes that contribute to their success: they know how to raise funds and run a 
successful campaign;112 they are adept at choosing when to seek office;113 and they 
start most races with a high level of name recognition.114 Although defeating an in-
cumbent is rare, the combination of strategic entry decisions and campaign acumen 
has traditionally given such candidates the best chance to knock off vulnerable 
incumbents or emerge successful in open seat contests. 
In some sense, the attributes of these quality candidates reinforce the incum-
bency advantage theory. These candidates may not already hold the office for 
which they are running, but they have previously held another elected office. That 
104. See GARY C. JACOBSON & JAMIE L. CARSON, THE POLITICS OF CONGRESSIONAL ELECTIONS 37 (10th ed. 
2019). 
105. Albert D. Cover, One Good Term Deserves Another: The Advantage of Incumbency in Congressional 
Elections, 21 AM. J. POL. SCI. 523, 536–37 (1977). 
106. Morris P. Fiorina, The Case of the Vanishing Marginals: The Bureaucracy Did It, 71 AM. POL. SCI. REV. 
177, 179 (1977). 
107. Erikson, supra note 103, at 1244; Cover, supra note 105, at 528. 
108. Richard F. Fenno, Jr., U.S. House Members in Their Constituencies: An Exploration, 71 AM. POL. SCI. 
REV. 883, 890 (1978). The “home style” refers to incumbents spending time in the district—how they present 
themselves to and connect with constituents, how often they travel to the district, and how they remind voters of 
the good they are doing for the district in Washington. 
109. Cox & Katz, supra note 103, at 478. Cox & Katz argue that one reason incumbents do not lose elections 
is that when it appears likely they will lose, they no longer run for reelection. 
110. Carson et al., supra note 103, at 291. The personal vote refers to voters’ willingness to support 
incumbents—perhaps even of a different political party—because of the good they are doing for the district. This 
could be casework (i.e., helping constituents navigate the bureaucracy) or it could be getting money and things 
for the district through the legislative process. 
111. Gary C. Jacobson, Strategic Politicians and the Dynamics of U.S. House Elections, 1946–86, 83 AM. 
POL. SCI. REV. 773, 781–82 (1989). 
112. Alan I. Abramowitz, Incumbency, Campaign Spending, and the Decline of Competition in U.S. House 
Elections, 53 J. POLITICS 34, 37 (1991); Cox & Katz, supra note 103, at 483; see also Janet M. Box- 
Steffensmeier, A Dynamic Analysis of the Role of War Chests in Campaign Strategy, 40 AM. J. POL. SCI. 352, 
359 n.9 (1996) (mentioning the treatment of political experience in the literature). 
113. Jacobson, supra note 111, at 776. 
114. Gary C. Jacobson, Incumbents’ Advantages in the 1978 U.S. Congressional Elections, 6 LEGIS. STUD. Q. 
183, 187 (1981). 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
49
--- END PAGE 19 ---

--- PAGE 20 (PDF page 20) ---
prior experience gives them both name recognition and political insights of the 
type ordinarily enjoyed by incumbents. 
B. Uncontested Elections 
The number of uncontested elections has been decreasing as of late in the U.S. 
Congress, but state legislatures are seeing an increase in the number of uncontested 
elections.115 Uncontested election rates in the U.S. House have fallen to around 
five percent, whereas uncontested election rates in the lower chambers of state 
legislatures have risen to over thirty percent.116 This divergent pattern suggests 
that, despite frequent complaints about an unresponsive and unrepresentative 
Congress, federal elections appear to be healthier than those at the state-level—at 
least as measured by contested elections. Of course, this says nothing of the true 
level of competition in those elections, which is discussed below. 
The literature on uncontested elections in the U.S. Congress tends to focus on 
the emergence decisions of challengers.117 This scholarship examines when “qual-
ity” candidates decide to run for office.118 There is good reason for the focus on 
quality candidates: these experienced candidates are the ones most likely to run a 
competitive campaign and therefore are the most likely to unseat an incumbent. 
Research on quality candidates finds they are strategic about when they stand for 
election—typically choosing not to challenge an incumbent, but rather waiting for 
an open seat.119 Scholarship also finds that non-quality (i.e., inexperienced) candi-
dates are also strategic in their entry decisions. The best opportunity for non-qual-
ity candidates to emerge is when quality challengers do not run.120 This research 
115. Barry C. Burden & Rochelle Snyder, Explaining Uncontested Seats in Congress and State Legislatures, 
49 AM. POL. RSCH. 247, 250 (2021). 
116. Id. at 255. 
117. See, e.g., Jamie L. Carson, Strategic Interaction and Candidate Competition in U.S. House Elections: 
Empirical Applications of Probit and Strategic Probit Models, 11 POL. ANALYSIS 368, 369 (2003); Robert E. 
Hogan, Challenger Emergence, Incumbent Success, and Electoral Accountability in State Legislative Elections, 
66 J. POLITICS 1283, 1283–84 (2004); Cherie D. Maestas, Sarah Fulton, L. Sandy Maisel & Walter J. Stone, 
When to Risk It? Institutions, Ambitions, and the Decision to Run for the U.S. House, 100 AM. POL. SCI. REV. 
195, 206 (2006). An “emergence decision” is the decision whether and when to run for office. 
118. As indicated above, political science uses the term “quality” candidates to refer to those candidates who 
have previous experience in elective office. See supra notes 111–114 and accompanying text. It is a dichotomous 
measure. This means that if a candidate for elective office has previously won another elected position, she is 
considered a quality candidate henceforth. For example, if a candidate is running for the U.S. Congress and 
previously had been elected mayor of her town, she would be classified as a quality candidate. If a candidate was 
running for state legislature and had previously won an election to school board, she would be classified as a 
quality candidate. If, however, a candidate was running for the U.S. Congress and had previously been appointed 
to a position, but never elected, she would not be a quality candidate. For example, former senator Kelly Loeffler 
was not a quality candidate when she ran for the U.S. Senate in 2020 despite serving in the U.S. Senate at the 
time. She only held that position because she had been appointed in 2019 by Georgia governor Brian Kemp. 
119. See, e.g., JACOBSON & CARSON, supra note 104, at 37; Jacobson, supra note 111, at 778. 
120. Jeffrey S. Banks & D. Roderick Kiewiet, Explaining Patterns of Candidate Competition in 
Congressional Elections, 33 AM. J. POL. SCI. 997, 1000–02 (1989). 
50                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 20 ---

--- PAGE 21 (PDF page 21) ---
suggests that the incumbency advantage combined with strategic decision making 
by candidates explains why so many elections go uncontested. 
Studies about state legislative elections show similarly strategic behavior. 
Jewell found that “quality candidates are more likely to run against incumbents 
who are perceived to be weak or to run for open seats. Strong, entrenched incum-
bents usually draw weak challengers, or none at all.”121 This is reinforced by Van 
Dunk, who found that “the likelihood of quality challengers running is related to 
the previous electoral appeal of the incumbent, the personal characteristics of the 
incumbent, state partisan conditions, and statewide economic conditions.”122 All of 
this leads to the conclusion that whether a challenger chooses to emerge is highly 
correlated with their perceived belief that they will be successful. 
The political science scholarship has identified other outside factors that influ-
ence when and whether congressional candidates decide to run. These factors 
range from the political environment, including economic conditions and partisan-
ship,123 to the demanding nature of filing requirements and campaign finance 
law.124 Incumbent “war chests” can also deter challengers from emerging.125 
While most political science studies have treated the question of contested elec-
tions as a discrete strategic choice by potential challengers, more recent work by 
Burden and Snyder sought to identify other factors that likely contribute to the rela-
tively high rate of uncontested elections for state legislatures.126 Their work sug-
gests that factors such as regional differences, the professionalization of the 
legislature, redistricting, and the partisanship of the district all play a role in 
whether elections are contested.127 Burden and Snyder conclude that how competi-
tive the legislature is plays a big role in the rate of contested elections.128 That is, 
when majority control of the legislature is on the line, candidates from both parties 
are more likely to run for office. 
The literature on state supreme court elections reinforces these findings from con-
gressional and state legislature elections.129 Bonneau and Hall examined whether 
state supreme court races were contested, as well as whether any challenger who 
121. Malcolm E. Jewell, State Legislative Elections: What We Know and Don’t Know, 22 AM. POL. Q. 483, 
488 (1994). 
122. Emily Van Dunk, Challenger Quality in State Legislative Elections, 50 POL. RSCH. Q. 793, 798 (1997). 
123. See, e.g., Greg D. Adams & Peverill Squire, Incumbent Vulnerability and Challenger Emergence in 
Senate Elections, 19 POL. BEHAV. 97, 100 (1997); Banks & Kiewiet, supra note 120, at 998–99; William T. 
Bianco, Strategic Decisions on Candidacy in U.S. Congressional Districts, 9 LEGIS. STUD. Q. 351, 351–53, 361– 
62 (1984); Jacobson, supra note 111, at 775, 778. 
124. Stephen Ansolabehere & Alan Gerber, The Effects of Filing Fees and Petition Requirements on U.S. 
House Elections, 21 LEGIS. STUD. Q. 249, 250 (1996). 
125. Robert E. Hogan, Campaign War Chests and Challenger Emergence in State Legislative Elections, 54 
POL. RSCH. Q. 815, 815 (2001). 
126. Burden & Snyder, supra note 115, at 247. 
127. Id. at 248–49. 
128. Id. at 255. 
129. Bonneau & Hall, supra note 93, at 339, however, remarked that unlike legislative races, “data on judicial 
elections have not been gathered in any systemic fashion.” 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
51
--- END PAGE 21 ---

--- PAGE 22 (PDF page 22) ---
emerged was a quality challenger.130 Of the state supreme court elections which 
were contested, only half of them attracted quality challengers.131 One noteworthy 
difference between state legislative and state court elections is that some state court 
elections are partisan while others are not.132 Bonneau and Hall found that partisan 
elections attract much higher levels of contestation and competition than do non- 
partisan elections. 
Bonneau and Hall also examined what types of incumbent justices were more 
likely to attract a challenger, as well as whether the challenger that they drew was 
viewed as a “quality” challenger. Generally, they find that about half of the con-
tested races for state supreme courts attract quality challengers.133 They found that 
incumbents who were appointed and are now seeking their first electoral victory 
are more likely to encounter a challenge.134 Somewhat surprisingly, they also 
found that the probability of drawing any challenger is not related to an ideological 
mismatch between the incumbent and the electorate.135 This differs from work on 
congressional and state legislative elections, in which incumbents elected from dis-
tricts populated with voters of the opposite party were more likely to draw a quality 
challenger.136 
Although their findings on partisan mismatch were different than the literature 
on legislative elections, the other factors that Bonneau and Hall identified were 
consistent with the legislative literature. They found that the state political climate 
influenced the likelihood of drawing a challenge.137 They found that overall parti-
san composition of the state and the size of the pool of lawyers available have an 
effect on whether the incumbent draws a challenger.138 They also found that insti-
tutional factors like the attractiveness of the job, including higher salaries and lon-
ger tenure, lead to more contested elections.139 
To date, prosecutor elections have not been the subject of sustained political sci-
ence study. A small number of law review articles have examined prosecutor elec-
tions. Those articles have reported that, when incumbent prosecutors seek 
reelection, they win about ninety-four percent of the time.140 This is consistent 
with the political science literature on federal and state legislative elections.141 But 
unlike those legislative elections, open seat elections for prosecutors—that is, elec-
tions in which there is no incumbent on the ballot—were also often uncontested 
130. Id. at 340. 
131. Id. at 343. 
132. Id. at 341. 
133. Id. at 343. 
134. Id. at 344. 
135. Id. at 343–44. 
136. See, e.g., Jacobson, supra note 111, at 778. 
137. Bonneau & Hall, supra note 93, at 344. 
138. Id. at 344. 
139. Id. 
140. Hessick & Morse, supra note 3, at 1544; Wright, supra note 89, at 600. 
141. See, e.g., JACOBSON & CARSON, supra note 104, at 37; Jacobson, supra note 111, at 778. 
52                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 22 ---

--- PAGE 23 (PDF page 23) ---
with only a single candidate running for the office.142 In legislative elections, open 
seats tend to be some of the most contested.143 
When prosecutor elections are contested, there are similar reasons for challenger 
emergence. Hessick and Morse found that larger jurisdictions are more likely to 
have contested elections, fitting with previous literature on this question.144 They 
also find that there are certain types of prosecutorial districts that are likely to have 
contested elections, including suburban or urban areas.145 They suggest one of the 
reasons for this might be that there simply are not enough potential candidates in 
some of the more rural areas. Similar to the scholarship on state supreme court 
elections,146 they hypothesize that the increased likelihood of contested elections 
in suburban and urban areas might be because the pool of attorneys to draw from is 
greater in these areas.147 
C. Competitive Elections 
Although elections to the U.S. Congress tend to be contested, those elections are 
often not competitive, especially when an incumbent is on the ballot.148 
Noncompetitive elections are also more likely when legislative districts have been 
gerrymandered to ensure the victory of a political party, or when a challenger with-
out resources or name recognition offers only token opposition. It matters whether 
elections are competitive, and not merely contested, because uncompetitive elec-
tions do not provide voters with a meaningful opportunity to hold their officials ac-
countable, and the officials in turn need not worry about losing their position. 
Competition in elections for the U.S. House of Representatives has been declin-
ing for well over fifty years.149 One simple measure of competition in elections to 
the U.S. Congress is the incumbent reelection rate. The incumbent reelection rate 
in the House of Representatives from 1946 to 1950 was 87%; it increased to 94% 
from 1952 to 1980; and then it increased again to over 97% from 1982 to 2004.150 
The rate has declined somewhat in the past few election cycles,151 averaging 92% 
from 2008 to 2020.152 
142. Hessick & Morse, supra note 3, at 1544. 
143. JACOBSON & CARSON, supra note 104, at 145. 
144. Hessick & Morse, supra note 3, at 1545, 1571. 
145. Id. at 1545. 
146. See, e.g., Bonneau & Hall, supra note 93. 
147. Hessick & Morse, supra note 3, at 1545. 
148. See, e.g., Jacobson, supra note 114, at 183 (“During the past three decades, more than [ninety] percent of 
the House incumbents sought reelection; fewer than two percent lost primary contests; and only six percent were 
defeated in general elections.”). 
149. Alan I. Abramowitz, Brad Alexander & Matthew Gunning, Incumbency, Redistricting, and the Decline 
of Competition in U.S. House Elections, 68 J. POLITICS 75, 75 (2006). 
150. Id. 
151. Gary C. Jacobson, It’s Nothing Personal: The Decline of the Incumbency Advantage in US House 
Elections, 77 J. POLITICS 861, 861 (2015). 
152. JACOBSON & CARSON, supra note 104, at 37. 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
53
--- END PAGE 23 ---

--- PAGE 24 (PDF page 24) ---
As noted above, part of the reason for these high reelection rates is that the qual-
ity challengers (i.e., those with prior experience in elective office) wait to run until 
there is an open seat.153 Research on the incumbency advantage and its effect on 
competition suggests that very few incumbents face tough competition even in 
those districts where the partisan makeup of their constituency could make them 
vulnerable. One of the reasons for this is that potential, competitive challengers 
cannot compete with the financial resources of the incumbent.154 Notably, the cost 
of running a viable congressional campaign has more than doubled in the last three 
decades.155 Furthermore, congressional redistricting can make challenging an in-
cumbent tough, as state legislators routinely try to draw lines that favor their 
party’s House candidates.156 By drawing safe districts, state legislatures stifle com-
petition in US congressional elections. For example, on the heels of a 2010 census 
and a 2010 midterm election that was a resounding victory for Republicans in state 
legislatures across many states, Republican legislators shored up some of their 
more marginal congressional districts by adding Republican voters to those 
districts.157 
State legislative elections are not much better when it comes to competition. 
According to Richard Forgette et al., the average margin of victory in a state legis-
lative election during the years 1968 to 2002 was over twenty-five percentage 
points.158 State legislative research, like research on congressional races, suggests 
that statutorily-defined redistricting processes affect the level of competition.159 
That is, the drawing of district maps is shown to be at least a part of the reason for 
the lack of competition at the state legislative level.160 
Another factor affecting the lack of competition at the state level is legislative 
professionalism—that is, “the extent to which a house provides the resources and 
tasks to make legislating a full-time job.”161 Studies analyzing professionalism 
show mixed results. Greater professionalism increased competition in some studies 
of state legislative elections,162 and brought out more challengers in recent 
153. See Jacobson, supra note 111, at 778 (“Unopposed candidates for open seats naturally win every time, 
and high-quality candidates are most common in these races.”); cf. Alan I. Abramowitz, Explaining Senate 
Election Outcomes, 82 AM. POL. SCI. REV. 385, 390 (1988) (“[C]andidates’ qualifications and financial resources 
may have a stronger impact on the outcome of a contest for an open seat than . . . on the outcome of a contest 
involving an incumbent.”). 
154. Abramowitz et al., supra note 149, at 82. 
155. JACOBSON & CARSON, supra note 104, at 90. 
156. Id. at 13. 
157. Id. at 14. 
158. Richard Forgette, Andrew Garner & John Winkle, Do Redistricting Principles and Practices Affect U.S. 
State Legislative Electoral Competition?, 9 STATE POL. & POL’Y Q. 151, 156 (2009). 
159. Id. at 166. 
160. Id. 
161. THAD KOUSSER, TERM LIMITS AND THE DISMANTLING OF STATE LEGISLATIVE PROFESSIONALISM 12 
(2005). 
162. See Hogan, supra note 125, at 827; Hogan, supra note 117, at 1292–93. 
54                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 24 ---

--- PAGE 25 (PDF page 25) ---
elections.163 
Steven Rogers, Accountability in American Legislatures 34 (2021) (unpublished manuscript), http:// 
www.stevenmrogers.com/www/bookproject.html. 
But another study showed no statistically significant correlation 
between professionalism and margin of victory.164 
In addition to legislative professionalism, studies have shown some effects of 
other external factors on competition, including national forces such as the state of 
the economy, presidential popularity,165 and the competitiveness (or perceived 
competitiveness) of parties at the state level.166 There is also limited evidence that 
district population or term limits influence competition in legislative elections.167 
Turning to state judicial elections, Hall and Bonneau found that, unlike legisla-
tive elections, the probability of competition is not related to ideological differen-
ces between the incumbent and the electorate.168 Ideological differences seemed 
especially unimportant when past electoral performance of the incumbent was 
accounted for because it proved to be a better indicator of incumbent vulnerabil-
ity.169 Additionally, and similar to findings on contested elections, the size of the 
candidate pool (i.e., the number of lawyers in the constituency) affects whether 
there is competition.170 The institutional arrangement of the position also has an 
effect on competition; if the job is more attractive, competition is more likely. 
More specifically, higher salaries and longer terms increase the likelihood of com-
petition in state supreme court elections.171 
Research on open-seat elections for state supreme courts finds that the winner is 
typically a candidate with judicial experience and the one who has spent more 
money.172 Also worth noting is that institutional arrangements matter in that dis-
trict-based elections are more competitive than their statewide counterparts,173 and 
the longer the term on the court, the less competitive an open-seat election is.174 
The existing literature on prosecutorial elections follows some of these same 
trends. Hessick and Morse provided the first look at competitiveness in prosecuto-
rial elections.175 A few of their findings stand out: first, the larger the jurisdiction, 
the more likely there is to be competition; second, urban and suburban districts are 
more likely to draw competition; and third, those places with high incarceration 
rates are less likely to have competitive prosecutorial elections.176 Each of these 
163. 
164. Forgette et al., supra note 158, at 164. 
165. Rogers, supra note 163, at 43. 
166. Burden & Snyder, supra note 115, at 255–56; Rogers, supra note 163, at 47. 
167. Burden & Snyder, supra note 115, at 248. 
168. Bonneau & Hall, supra note 93, at 343–44. 
169. Id. at 343. 
170. Id. at 344. 
171. Id. 
172. Chris W. Bonneau, Vacancies on the Bench: Open-Seat Elections for State Supreme Courts, 27 JUST. 
SYS. J. 143, 143 (2006). 
173. Id. at 156. 
174. Id. 
175. Hessick & Morse, supra note 3, at 1545. 
176. See id. at 1566–67, 1573–74. 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
55
--- END PAGE 25 ---

--- PAGE 26 (PDF page 26) ---
findings is normatively concerning, as they suggest that there might be a dearth of 
qualified candidates in those places most in need of electoral choices. In particular, 
those jurisdictions with the fewest attorneys—and thus the fewest possible candi-
dates for prosecutor—are least likely to have competitive or even contested elec-
tions. And the lack of competitive elections means that those communities likely 
are not having public debates about how to conduct their criminal justice policies. 
Although Hessick and Morse provide a thorough discussion of prosecutorial 
elections utilizing national data,177 
That data set has been made available through the Prosecutors and Politics Project, a research initiative at 
the University of North Carolina at Chapel Hill. See Local Prosecutor Elections, 2012–2017, PROSECUTORS AND 
POLITICS PROJECT DATAVERSE, UNC DATAVERSE (Feb. 19, 2020), https://dataverse.unc.edu/dataset.xhtml? 
persistentId=doi:10.15139/S3/ILI4LC. 
they were unable to provide a systematic analy-
sis of what leads to the lack of contestation and competition. Their analysis was 
purely descriptive and did not attempt to engage in a sophisticated statistical analy-
sis of which factors were likely to lead to contested or competitive elections. 
That is the task that we take up in the next Part. 
III. A STATISTICAL ANALYSIS OF PROSECUTOR ELECTIONS 
This Part identifies relevant variables that might affect prosecutor elections, 
describes our methodology, and summarizes our findings. Our main findings are 
that larger population and open races are the factors most likely to result in con-
tested and competitive elections. Certain variations in state election law also affect 
the rate of contested elections. After presenting our main findings, this Part digs 
deeper into the question of whether the number of lawyers in a jurisdiction effects 
prosecutor elections, as well as whether crime rates and prison admissions on pros-
ecutor elections have an effect. 
A. Identifying Relevant Variables 
In order to determine what causes contested and competitive elections, we must 
first identify the variables to study. Relying on the political science literature 
reviewed in the previous Part, as well as the hypotheses in the legal literature on 
prosecutor elections, we identified several factors that might help to explain why 
some prosecutor elections are meaningfully contested, while others are either 
uncontested or feature a candidate with no realistic chance of winning. 
Those factors are as follows: whether the election features an incumbent or is 
for an open seat, whether the incumbent shares the party affiliation of the majority 
of voters in the district, how long the incumbent has been in office, factors that sug-
gest greater “professionalization” (such as office budget and part-time status), the 
number of lawyers living in a district, various state election laws, and crime and 
prison admission trends. Each factor is described in more detail below. 
177. 
56                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 26 ---

--- PAGE 27 (PDF page 27) ---
1. Open Seats 
Both the political science literature and the legal literature suggest that contested 
and competitive elections are more likely in open-seat elections—that is, those 
elections in which there is no incumbent running for reelection. The political sci-
ence literature on open-seat elections finds more contestation and competition.178 
It is also consistent with the descriptive observations of Hessick and Morse.179 To 
test this variable, we must determine whether, all else being equal, an election 
without an incumbent is more likely to be both contested and competitive. If that is 
true, then it suggests would-be quality candidates strategically time their decision 
to run for office when there is no incumbent on the ballot. 
2. Partisan Mismatch and General Elections 
The political science literature suggests that, if the incumbent is not of the 
party that received the majority of votes in the recent presidential election, then 
contestation and competition are more likely in a general election.180 So, for exam-
ple, if the district attorney is a registered Democrat in a county that voted over-
whelmingly for Donald Trump in 2016, then he should be more likely to face a 
challenger (all else being equal) than an incumbent who is a registered Republican. 
The theory is that these incumbents are likely to be seen as more vulnerable 
because their party affiliation does not match the partisan preference of their con-
stituents. That vulnerability encourages quality candidates to run for the office. 
3. Partisan Match and Primary Elections 
The political science literature suggests that, if the incumbent is of the party that 
received the majority of votes in the recent presidential election, then contestation 
and competition are more likely in the primary election.181 For example, an incum-
bent district attorney in a county that voted for Hillary Clinton in 2016 is more 
likely to face a primary challenger if she is a Democrat than if she is a Republican, 
all else being equal. 
This factor is similar to, but distinct from, the previous factor. It is similar to the 
previous factor in that it suggests an incumbent’s party affiliation can predict when 
contested and competitive elections are more likely. Incumbents who share the po-
litical affiliation with most voters in their districts are more likely to be challenged 
in their primary election, whereas incumbents who do not share the political affilia-
tion of the voters in their district are more likely to be challenged in the general 
election. But while a partisan mismatch suggests incumbent weakness, a partisan 
match obviously does not. Thus, the theory behind this factor is that potential 
178. See, e.g., JACOBSON & CARSON, supra note 119, at 37; Jacobson, supra note 111, at 778. 
179. See Hessick & Morse, supra note 3, at 1563 tbl.5. 
180. See, e.g., Jacobson, supra note 111, at 778. 
181. See, e.g., id. 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
57
--- END PAGE 27 ---

--- PAGE 28 (PDF page 28) ---
challengers are more likely to run when their political affiliation that matches the 
preferences of most voters in their district because they assume the district is most 
likely to elect a candidate of that particular party. 
4. Length of Incumbent Tenure 
The legal literature suggests that incumbents who have served less time in office 
are more likely to face a challenger than incumbents who have served for a longer 
period of time. Specifically, Hessick and Morse found a correlation between an in-
cumbent prosecutor serving five or fewer years in office and contested elections.182 
The political science literature arguably supports this factor as well. The litera-
ture finds that justices who had previously been appointed to their position were 
more likely to draw a challenger.183 Appointments to an elective office ordinarily 
occur because of a vacancy part-way through a term—such as when the previous 
office holder resigns or dies while in office. As a result, those incumbents who 
have been appointed will ordinarily serve a shorter term than incumbents who have 
been elected to the office. 
The theory behind this factor is that all else equal, incumbents who have served 
less time in office have less name recognition and have had less time to tout their 
accomplishments. These newer prosecutors are likely to be perceived as more vul-
nerable and less entrenched. 
5. “Professionalization” of the Office and Attractiveness of Position 
As noted above, the political science literature indicates that more professional-
ized institutions are likely to generate more contested and competitive elections, as 
are positions that are more attractive to candidates.184 As a general matter, meas-
ures of professionalism attempt to capture the capacity of institutions and the con-
stituent members of those institutions to perform their functions well. Legislative 
professionalism is generally measured by looking at factors such as member 
pay, number of staffers per legislator, and the number of days in session.185 
Attractiveness of the position is measured by higher salary and longer terms.186 
Assessing the professionalism and the attractiveness of a particular prosecutor 
position can be difficult. There is simply not enough variation in some of the tradi-
tional professionalism metrics. For example, for term length, forty of the forty-five 
states that elect their prosecutors have four-year terms for the office; one state has 
a shorter term, and four states have longer terms.187 
182. Hessick & Morse, supra note 3, at 1568 tbl.7. 
183. See supra note 134 and accompanying text. 
184. See supra note 162–63 and accompanying text. 
185. Peverill Squire, Legislative Professionalization and Membership Diversity in State Legislatures, 17 
LEGIS. STUD. Q. 69, 71 (1992). 
186. See supra text accompanying note 161. 
187. Hessick & Morse, supra note 3, at 1550 tbl.1, 1553. 
58                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 28 ---

--- PAGE 29 (PDF page 29) ---
However, when it comes to other measures of professionalization, there is more 
variation between districts. Specifically, we were able to collect data about whether 
an office is full-time or part-time, the salary of the elected prosecutor, the number 
of staff employed, and the size of the office budget.188 
The Bureau of Justice Statistics has periodically conducted a census of state court prosecutors. We relied 
on the data from the most recent census, which was conducted in 2007. See generally STEVEN W. PERRY & 
DUREN BANKS, U.S. DEPARTMENT OF JUSTICE, PROSECUTORS IN STATE COURTS, 2007 – STATISTICAL TABLES 
(2011), https://bjs.ojp.gov/content/pub/pdf/psc07st.pdf. It is possible that some of the data changed between 
2007 and the elections in our dataset, most of which were held in 2014 and 2016. 
We use these as a proxy for 
professionalization. It is possible that these factors may affect elections—specifi-
cally, that full-time offices with higher salaries, larger staffs, and larger budgets 
will be seen as more prestigious or more desirable, and thus that elections for those 
offices will have higher rates of contested and competitive elections, as they are 
more coveted positions. 
6. Supply of Lawyers 
There is support in both the political science literature and the legal literature 
for the idea that districts with more lawyers will have higher rates of contesta-
tion and competition as compared to districts with fewer lawyers. The state 
supreme court literature found a relationship between the number of lawyers 
and the rate of contested elections.189 And Hessick and Morse found a correla-
tion between the number of lawyers living in a district and the rate of contested 
elections—districts with a smaller supply of lawyers were less likely to have 
contested elections.190 
Unlike most other elected offices, there is a significant limitation on who may 
run as candidates for judicial or prosecutorial office: the candidate must be a law-
yer. Thus, the number of lawyers in a district represents the total supply of possible 
candidates. Districts with more lawyers have a larger supply of potential candi-
dates, as compared to districts with fewer lawyers. 
7. Differences in Election Law 
Although forty-five states elect their prosecutors, they do not necessarily use the 
same legal rules to conduct those elections. Some of those rules may affect when 
would-be candidates decide to enter a race or how well the candidates fare against 
one another. 
First, some states exclude uncontested elections from their ballots;191 candidates 
who face no opponent simply do not have to stand for election. This practice could 
potentially result in fewer contested prosecutorial elections because voters (and 
188. 
189. Bonneau & Hall, supra note 93, at 344. 
190. Hessick & Morse, supra note 3, at 1574–81. Their observation was limited to ten states because those 
were the only states from which they collected lawyer residency data. 
191. See infra tbl. 2. 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
59
--- END PAGE 29 ---

--- PAGE 30 (PDF page 30) ---
potential challengers) are not reminded on election day that this is an elected office 
and that there is not much choice.192 
Second, while local prosecutor is a partisan office in the majority of states, a mi-
nority of states classify it as a non-partisan office, and they do not indicate the po-
litical party affiliation of prosecutorial candidates on the ballot. Five states hold 
non-partisan prosecutorial elections, and two additional states permit counties to 
determine whether to hold partisan or non-partisan elections.193 The existing litera-
ture on prosecutor elections is split about whether this rule affects contested elec-
tions: Wright’s study of prosecutor elections in fifteen states observed that states 
with non-partisan elections observed higher rates of contested elections.194 Hessick 
and Morse did not observe a correlation between non-partisan elections and 
increased contestation.195 The political science literature, on the other hand, has 
shown that non-partisan elections “feature even less competition, that voter turnout 
is substantially lower, that incumbents are safer and that there is no indication that 
candidates engage in any substantial policy competition.”196 
Third, some states allow voters to vote the party, rather than the individual candidates 
that they wish to support across the entire ballot.197 This so-called “straight ticket voting” 
has been shown to nudge voters to vote in a partisan manner in a general election.198 
Such a variable could have an effect on the competitiveness of general elections with a 
partisan mismatch: an incumbent’s advantage could be undermined by voters who select 
this option since the majority of voters are from the opposing party. Therefore, a chal-
lenger may be more likely to emerge and a competitive election is more likely in a state 
that utilizes straight ticket voting and when there is a partisan mismatch. Put differently, 
in a district where the general election electorate’s partisanship does not match that of 
the incumbent prosecutor, the incumbent might be at more of a disadvantage in the gen-
eral election if those voters utilize the straight ticket voting option. 
8. Crime and Prison Admission Trends 
Since prosecutors’ main role is to prosecute those who commit crimes, it seems 
logical that variables associated with crime could have an effect of prosecutor elec-
tions. There are two relatively easy to obtain statistics associated with crime: crime 
rates and prison admission rates. If crime rates go up, voters might blame their 
local prosecutor, prompting a challenger to declare her candidacy and thereby 
increasing the likelihood of the election being more competitive. Alternatively, 
192. Hessick & Morse, supra note 3, at 1557. 
193. See id. at 1552. 
194. Wright, supra note 11, at 603 tbl. 3. 
195. Hessick & Morse, supra note 3, at 1565–66. 
196. David Schleicher, Why Is There No Partisan Competition in City Council Elections?: The Role of 
Election Law, 23 J. L. & POL. 419, 421 & n.13 (2007) (collecting sources). 
197. See infra tbl. 2. 
198. ERIK J. ENGSTROM & JASON M. ROBERTS, THE POLITICS OF BALLOT DESIGN: HOW STATES SHAPE 
AMERICAN DEMOCRACY 136 (2020). 
60                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 30 ---

--- PAGE 31 (PDF page 31) ---
voters could respond to the prison admission rate per crime, since this is a metric 
the prosecutor has more control over than the actual crime rate.199 Voters might 
think that the prosecutor is sending too many or too few people to prison. 
Of course, voters alone do not determine whether there is a challenger—because 
only lawyers can stand for election, a dissatisfied voter may not have a choice at 
the polls. But potential challengers might see crime rates or prison admission rates 
as a weakness for the incumbent prosecutor. In other words, these numbers might 
incentivize quality candidates to run for the office. 
B. Description of Data and Summary Statistics 
For this study, we rely on data collected by the Prosecutors and Politics 
Project.200 These data include vote share information about each candidate that ran 
in a district prosecutor election for forty-five states, each sampled in one year rang-
ing from 2012–2017.201 We combine these data with additional district-level infor-
mation including presidential election results,202 
MIT Election Data Science Lab, County Presidential Election Returns, HARVARD DATAVERSE, https:// 
dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/VOQCHQ (last visited Oct. 23, 2022). 
demographic information from 
the U.S. Census, prison admissions information from National Corrections 
Reporting Program through the National Archive of Criminal Justice Data,203 
Danielle Kaeble, Bureau of Justice Statistics, National Corrections Reporting Program, U.S. DEP’T OF 
JUST. (2019), https://bjs.ojp.gov/data-collection/national-corrections-reporting-program-ncrp#publications-0. 
and 
information about the size, salary, budget, staff, and full- or part-time statues of 
prosecutors’ offices from the Bureau of Justice Statistics.204 We also included the 
various state election law rules discussed in the previous subsection.205 
Here, a contested election is defined as a race with more than one candidate run-
ning for the office of prosecutor. A competitive race is defined in accordance with 
political science literature that suggests a competitive race is one in which there is 
more than “token opposition.”206 We code a race as competitive if the winning can-
didate received less than eighty percent of the vote in the election.207 
199. The prosecutor’s charging and plea bargaining decisions have a direct effect on how many people are 
admitted to prison, while crime rates depend on many variables, some of which are unknown. Cf. Bibas, supra 
note 9, at 986 (“Crime rates are often driven by exogenous factors, such as the crack-cocaine boom or increased 
police hiring, for which prosecutors deserve little credit or blame.”). 
200. See supra note 177. For more information about how the data was collected, see Hessick & Morse, supra 
note 3, at 1558–61. 
201. Different jurisdictions are sampled in different years because not all prosecutor elections are held in the 
same year. 
202. 
203. 
204. See Perry et al., supra note 188. 
205. See supra notes 191–98 and accompanying text. 
206. Burden, supra note 101, at 221. 
207. Different studies use different thresholds. For example, Burden uses ninety percent as an indication of 
competitiveness, Burden, supra note 101, at 221, while Jewitt and Treul use seventy-five percent, Ideological 
Primaries, supra note 101, at 214. We use the eighty percent threshold as it allows us to capture more opposition 
than the seventy-five percent threshold and given low levels of contestation to start with, this allows us to classify 
as many elections as competitive, while still remaining within the bounds of what is considered acceptable in 
political science literature. 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
61
--- END PAGE 31 ---

--- PAGE 32 (PDF page 32) ---
Table 1 presents summary statistics about the incidence of contestation and 
competition: 
Table 1: Contestation and Competition in Prosecutorial Elections by 
Election Type 
Type of Challenge 
Contested 
Competitive  
General Election 
17.78% 
17.26% 
Primary Election 
13.85% 
13.72% 
Both Primary & General 
3.45% 
3.37%  
208. Logistic regression relies on a logistic distribution to model binary outcomes (dependent variables). 
They are used to predict the likelihood of one outcome happening opposed to the other based on certain factors 
(independent variables). For a detailed discussion of logistic regression, see ANDREW GELMAN & JENNIFER HILL, 
DATA ANALYSIS USING REGRESSION AND MULTILEVEL/HIERARCHICAL MODELS 79–86 (2006). 
209. Id. 
210. The precise specification of the multilevel mode is Pr yi ¼ 1
ð
Þ ¼ logit 1
; for i
1; :::; n; where 
X is the matrix of individual level predictors (defined below), j i½  indexes the state where district i is contained, yi is 1 if 
the election was contested (or competitive) and 0 otherwise, and b is the vector of predictors of length i. The second part 
62                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31 
Table 1 shows that 17.78% of general elections attract a challenger and 17.26% 
of general elections are competitive using the 80% standard discussed above. This 
indicates that almost all challengers in general elections offer more than token 
opposition. This is also the case for primary elections, where the gap between con-
testation and competition rates—13.85% and 13.72%, respectively—is even 
smaller. 
The last row reflects the frequency with which an election is contested or com-
petitive in both the primary and the general election. This is quite rare at less than 
4% for both contested and competitive elections, which means that if an incumbent 
is going to face a competitive election, it is likely to be in the general or the pri-
mary stage, but not both. 
To test the various factors identified, we fit two logistic regression models208 
with state-level varying intercepts. This method allows us to estimate the individ-
ual effect of district-level characteristics—the independent variables—on the inci-
dence of contestation or competition—the dependent variable.209 For example, 
regression analysis can tell us how district population (an independent variable) is 
related to the likelihood of a prosecutor’s race being contested (the dependent vari-
able), controlling for the effects of other independent variables. 
To account for unobserved state-level variation, we estimate a multilevel model. 
This type of model allows us to assume that states may have different baseline lev-
els of contestation and competition due to features that we cannot observe and 
therefore include in the model, but the independent variables in the model affect 
the individual states in a consistent way.210
--- END PAGE 32 ---

--- PAGE 33 (PDF page 33) ---
We include a number of independent variables that we expect to be relevant 
to contestation and/or competition. At the state level, the model includes three 
variables that correspond to three different legal rules surrounding elections in 
different states. The first of those variables, Exclude Uncontested, refers to the 
practice in some states of excluding uncontested elections from their ballots. 
The second variable, Partisan Election, refers to those states that indicate the 
political party affiliation of prosecutorial candidates on the ballot. The third 
variable, Straight Ticket Option, refers to the practice of states allowing voters 
to vote for a party across the entire ballot. 
In addition to these state-level variables, we also include multiple county- 
level variables. Budget per Capita reflects the dollars spent per person by the 
district’s prosecutors’ office. The variable Partisan Mismatch represents 
cases where the incumbent prosecutor is not representing the party that 
received the majority of votes in the 2016 presidential election. Open Race 
identifies cases where there is no incumbent running. Incumbent Tenure cap-
tures the number of years the incumbent has held the office of district prose-
cutor. To capture district level electoral context, the model also includes the 
percent change in the crime rate (Change in Crime) from four years preced-
ing the election year to the election year211 as well as the district’s Prison 
Admissions which show how many people from a district were admitted to 
prison in a given year.212 
See Josh Keller & Adam Pearce, U.S. State Prison Admissions by County, GITHUB.COM (Sept. 13, 2016), 
https://github.com/TheUpshot/prison-admissions. 
It also controls for the districts’ Population. In later 
models, we capture the effects of lawyer supply by specifying models with 
an independent variable for Number of Lawyers as well as Lawyers per 
Capita. 
Table 2 shows a description of each independent variable included in the 
model.   
of the model is defined as: aj 
a ; for j
1; :::; 44: Where U is the matrix of state-level predictors, g 
is the vector of coefficients for the state-level regression, and s a is the standard deviation of the unexplained 
state-level errors. See id. at 301–20. 
211. We chose four years because that is overwhelmingly the most common term length for local prosecutors. 
See Hessick & Morse, supra note 3, at 1550. 
212. 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
63
--- END PAGE 33 ---

--- PAGE 34 (PDF page 34) ---
Table 2: Descriptions of Variables 
Independent Variable 
Description  
Straight Ticket 
Option 
1 if the state has an option for party-based straight ticket 
voting 
Multi-County 
District 
1 if the prosecutorial district contains multiple counties 
Exclude 
Uncontested 
1 if the state does not include uncontested prosecutorial races 
on the ballot 
Budget per 
Capita 
Dollars in the 2007 prosecutorial budget per person in 
the district 
Partisan 
Election 
1 if the prosecutor is a partisan office 
log(Population) 
Natural log of the 2010 Census Population for the district 
Partisan 
Mismatch 
1 if the incumbent is not representing the party that received 
the majority of votes in the 2016 presidential election 
Open Race 
1 if the incumbent is not running for re-election 
Incumbent 
Tenure 
The number of years the incumbent has held the office of 
prosecutor 
Number of 
Lawyers 
Number of lawyers in the district 
Lawyers per 
Capita 
The number of lawyers in a district divided by the population 
of the district multiplied by 1000 
Change in 
Crime 
The change in crime rate for a district between four years 
prior to the election year and the election year 
Prison Admissions 
The number of people from a prosecutorial district admitted 
to prison in one year  
213. See infra tbl. A.1. 
214. Each statistically significant covariate in the contestation model is also significant and has the same sign 
in the competition model. 
64                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31 
Below, Table 3 reports the results of four models. In all models the dependent 
variable is 1 if there was more than one candidate in the prosecutorial race. The 
results of our models for whether the election is competitive are included in the ap-
pendix below.213 The results are largely similar.214
--- END PAGE 34 ---

--- PAGE 35 (PDF page 35) ---
The first two models represent general elections and the last two represent pri-
mary elections. For each election type, we run one model for all races and one 
model that only includes races where an incumbent is running, which allows us to 
include the independent variables Partisan Mismatch and Incumbent Tenure. The 
leftmost column shows the various independent variables and other control varia-
bles that we are interested in. For each model and variable, Table 3 reports two sta-
tistics. In the first, it reports the model coefficient which represents the effect of a 
one-unit change of the independent variable on the input of the logistic function. 
Positive numbers indicate the independent variable increases the likelihood of con-
tested elections while negative numbers indicate the variable decreases the likeli-
hood of contested elections. 
Each coefficient estimated has an amount of variation associated with it. This 
variation, called the standard error, is the second statistic reported in parentheses. 
The higher the error, the less confident we can be that the estimated coefficient is 
the true coefficient. Using the standard error, we are able to quantify how likely it is 
that the effect we detect is representative of a true effect rather than random noise. 
If a coefficient estimate is less than five percent likely to be found because of ran-
dom noise,215 it is designated as statistically significant with an asterisk (p<.05). 
The last two rows of the table report the number of observations (prosecutorial 
races) used in the regression model and the Akaike Information Criterion, which 
represents how well the model fits the data;216 lower values mean that the model is 
a better fit for the data than higher values. 
In these first two models, open race, larger populations,217 and partisan mis-
match all have the effect of increasing the likelihood of both contestation and com-
petition. In other words, these models show strong and consistent support for the 
conclusion that these factors have a significant effect on whether voters will have a 
choice at the polls and whether that choice will be meaningful. 
Open seat races—that is, races without an incumbent—are almost three times as 
likely to have a contested election as those with an incumbent.218 This finding is 
entirely consistent with the literature about the power that incumbents have to 
maintain their office if they desire.219 Additionally, since this effect is similar 
across contestation and competition,220 this suggests that incumbents are successful 
in “scaring-off” not only quality challengers but also any potential challengers at 
all. 
215. JEFFREY M. WOOLDRIDGE, INTRODUCTORY ECONOMETRICS: A MODERN APPROACH 124 (5th ed. 2013) 
(describing five percent confidence level as “the most popular choice” for regression). 
216. GELMAN & HILL, supra note 208, at 525. 
217. The variable population is included to capture the fact that there might be differences in contestation and 
competition based on the size of the prosecutorial district. We utilize the natural-logged form of this measure to 
standardize the units of measure and aid with interpretation. See WOOLDRIDGE, supra note 215, at 41–43. 
218. This number comes from transforming the log-odds reported in Table 3 to an odds ratio by taking the 
inverse natural log: e1:068 ¼ 2:89; e1:091 ¼ 2:98  .
219. See supra Part II.A. 
220. See infra tbl. A.1. 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
65
--- END PAGE 35 ---

--- PAGE 36 (PDF page 36) ---
Table 3: Contestation in Prosecutorial Elections  
 
Dependent variable: 
Any Challenger  
General Elections 
Primary Elections  
All Races 
Only 
Incumbents 
All Races 
Only 
Incumbents  
Straight Ticket
Option 
 
0.213 (0.293) 
0.345 (0.442) 
0.450 (0.240) 
0.700 (0.393) 
Multi-County 
District 
0.123 (0.226) 
0.439 (0.338) 
0.142 (0.185) 
0.268 (0.355) 
Exclude 
Uncontested 
0.097 (0.398) 
0.394 (0.582) 
0.578* (0.236) 
0.831* (0.381) 
Budget per  
Capita 
0.071 (0.057) 
0.149 (0.084) 
0.012 (0.059) 
0.037 (0.129) 
Partisan Election 
1.080* (0.391) 
1.337* (0.604)   
 
 
log(Population) 
0.259* (0.047) 
0.273* (0.064) 
0.267* (0.046) 
0.139 (0.086) 
Open Race 
1.068* (0.135)  
 
1.091* (0.129)  
 
Partisan 
Mismatch  
 
0.481* (0.189)  
 
0.804* (0.284) 
Incumbent 
Tenure  
 
0.034 (0.085)  
 
0.075 (0.123) 
Constant 
5.601* (0.620) 
6.119* (0.922) 
5.825* (0.534) 
3.510* (0.975) 
Observations 
2,316 
1,277 
4,307 
1,013 
Akaike Inf. 
Crit. 
1,977.809 
1,050.973 
2,156.754 
636.861 
State-Level 
Random Effects? 
Yes 
Yes 
Yes 
Yes 
Note: * p<.05.  
221. However, as we note below, once we control for population, differences in budget (and, by inference, 
staff) show no detectable effect. 
66
AMERICAN CRIMINAL LAW REVIEW
[Vol. 60:31 
Larger populations also encourage contested elections. This could indicate a 
preference among potential prosecutorial candidates for larger districts, which are 
generally accompanied by larger budgets, staff, and more responsibility.221
--- END PAGE 36 ---

--- PAGE 37 (PDF page 37) ---
Alternatively, this could be evidence of a supply problem, wherein there are not 
enough interested, eligible candidates in small districts to challenge incumbents. 
The possibility of a supply problem is discussed in the next Part. 
The incumbent’s party also had the predicted effect on elections. In cases of a 
partisan mismatch—that is, districts in which the incumbent’s party did not win 
the majority of the district’s presidential vote—contested general elections were 
more likely. This suggests that shifting district-level party alignments can serve as 
a signal to potential challengers of the incumbent’s electoral weakness, prompting 
more challengers. 
When examining the effect of an incumbent’s party in primary elections, we 
also see the expected result. Incumbents who come from the district’s majority 
party are more likely to face a challenger in the primary election than those incum-
bents who are out of step with the partisan identification of the district. This sug-
gests that potential candidates recognize the value of identifying with the party that 
gets the majority of district support in presidential elections.222 
Of course, because the incumbent will either belong to the majority party or the 
minority party in her district, a partisan election will necessarily feature a partisan 
match or a partisan mismatch.223 
The one exception to this would occur if an incumbent prosecutor ran as a third-party candidate or was 
unaffiliated with a party. But that was relatively rare in our dataset. We identified only fifty-three incumbents 
who ran as Independents. See PROSECUTORS AND POLITICS PROJECT, NATIONAL STUDY OF PROSECUTOR 
ELECTIONS 59, 88, 93, 95, 100–11, 165, 183, 186, 203, 206, 217, 243, 258, 271–72, 274–75, 279–82, 314–28, 
343, 350 (2020), https://law.unc.edu/wp-content/uploads/2020/01/National-Study-Prosecutor-Elections-2020. 
pdf. 
Given this, what the models detect is actually 
when (i.e., what stage of the election) an election is likely to be contested—the pri-
mary election or the general election. It does not tell us whether there will be a con-
tested election. 
When comparing the contestation rates across elections with a partisan match 
and elections with a partisan mismatch—that is, the rate at which either the pri-
mary or the general election was contested—we do not see a meaningful differ-
ence. Nor do we find a relationship between the magnitude of the mismatch and 
challenger emergence in general elections when examining the size of the presi-
dential vote share for a given district. (For example, Democratic incumbents in 
heavily Republican districts do not face more challenges than Democratic incum-
bents in slightly Republican districts.) 
Interestingly, neither incumbent tenure nor any of the professionalism and desir-
ability of position factors have a measurable impact on the predicted probability of 
a contested election. In other words, these factors do not have the expected effects. 
It is unclear why incumbent tenure does not affect contestation.224 After all, 
recently elected incumbents have had less time to establish themselves within the 
222. Presidential elections are frequently used to measure the partisanship of various electoral units because 
turnout is so high. 
223. 
224. We report the regression results for the competition model in Table A.1, infra. For each variable of 
interest, the results are substantively similar. 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
67
--- END PAGE 37 ---

--- PAGE 38 (PDF page 38) ---
local power structure and less time to build name recognition—some of the impor-
tant benefits that incumbency is thought to confer. It is possible that an incumbent 
who more recently won her election may represent the district better ideologically, 
and the coalitions that mobilized to elect her are more likely to still exist. But when 
we adjusted the model to isolate only those incumbents who had served less than a 
term—that is, those incumbents who likely had been appointed to their position— 
there was still no detectable effect in our main model.225 This suggests the incum-
bency advantage may be even stronger for prosecutors than for judges.226 
As for the professionalism and desirability of office factors, it is hard to know 
whether these factors are simply irrelevant to potential candidates or whether the 
relationship between these factors and population obscures meaningful differences 
from the candidates’ point of view. The size of the office staff and the overall size 
of the office budget fluctuate significantly based on the population of a district.227 
It may be that, for example, potential candidates do not respond to funding relative 
to the population, but rather find offices with a higher level of absolute funding 
more attractive. Of course, the level of absolute funding is highly correlated with 
population (.902), since offices receive funding mostly commensurate with the 
number of cases that they will process. Given the high level of correlation, we are 
unable to conclude if it is larger populations or higher budgets and larger staffs that 
encourage contestation. 
For our state-level variables, the Straight Ticket Option does not appear to have 
an effect on the likelihood of contestation.228 
At the time this data was collected, twelve states offered a straight ticket voting option. Those states are: 
Alabama, Indiana, Michigan, Kentucky, Oklahoma, South Carolina, Utah, Pennsylvania, Michigan, Iowa, and 
Texas. See Straight Ticket Voting, NATIONAL CONFERENCE OF STATE LEGISLATURES (July 11, 2022), https:// 
www.ncsl.org/research/elections-and-campaigns/straight-ticket-voting.aspx. 
Partisan Election, however, does sig-
nificantly increase the likelihood of a contested general election.229 Additionally, 
the practice of Excluding Uncontested from ballots does not appear to have an 
effect in general elections, but it does have an effect in primary elections. Those 
states that exclude uncontested elections from their primary ballots are less likely 
to have contested or competitive primary elections.230 
225. We identified 217 incumbents who ran for reelection after serving less than a full term. Some of these 
candidates had obtained their position by running in special elections. But others were appointed to fill vacancies. 
226. That is because, as noted, above, judges who have been previously appointed to the position were more 
likely to draw a challenger, see supra note 134 and accompanying text, but we do not observe a similar pattern 
for prosecutors. 
227. There is also a clear relationship between full-time and part-time status. Part time offices are found only 
in small population districts. 
228. 
229. This finding is contrary to the correlation that Wright observed, see Wright, supra note 11 at 603 tbl. 3, 
but it is consistent with the political science literature, see supra note 193–96 and accompanying text. The 
following states hold states nonpartisan prosecutor elections: Arkansas, California, Minnesota, North Dakota, 
and Oregon. Hessick & Morse, supra note 3, at 1550 tbl.1. In addition, Hawaii and Montana allow counties to 
decide whether the office is partisan or nonpartisan. Id. at 1552. 
230. Six states exclude uncontested races from the general election ballot, and fifteen states exclude 
uncontested races from the primary ballot. Hessick & Morse, supra note 3, at 1554–55. 
68                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 38 ---

--- PAGE 39 (PDF page 39) ---
C. Lawyer Supply Hypothesis 
This subsection addresses the supply of qualified candidates. Candidates for 
local prosecutor must not only satisfy any relevant residency requirements, but 
they must also be active members of the state bar in good standing.231 Hessick and 
Morse show that there are less than five lawyers in many districts, and they suggest 
this constraint on the supply of candidates as a potential explanation for the lack of 
contested prosecutorial elections.232 To investigate this question, we examine a 
sample of ten states233 and identify the number of lawyers living in each district. 
Importantly, it is not a random sample. Half of the states in the sample were 
selected because they made their lawyer residency data easy to obtain; the other 
half were specifically chosen because they included districts that were unable to 
field even a single candidate for at least one prosecutor election.234 Because the 
sample is not random, it may not be representative. 
We begin by presenting descriptive statistics below, in Table 4: 
Table 4: Summary Statistics for Number of Lawyers in a District 
Min 
0  
Max 
69,235 
Median 
31 
Mean 
643.22  
231. Many states require that an individual live in the particular county or district in which they run; but some 
states have relaxed those requirements and allow candidates from adjacent counties to run. As a result of that 
relaxation, some districts with no lawyers living within their boundaries may still have a candidate stand for 
election, rather than having to resort to appointment of a local prosecutor. See Hessick & Morse, supra note 3, at 
1575–76, 1578 (discussing residency requirements). 
232. Id. at 1574–78. 
233. The states in our sample are Arizona, California, Kentucky, Missouri, Nebraska, New York, North 
Dakota, South Carolina, South Dakota, and Utah. These are the same states that Hessick and Morse used. 
234. As they explained, they selected these ten states as follows: 
Because this data was often not readily available, we collected it only for a subset of states. We 
made a special effort to obtain this data in the six states with districts that did not have a single 
candidate run for local prosecutor, and we were ultimately able to obtain it for five of those six 
states. We supplemented this data with data from an additional five states that made the informa-
tion easy to obtain. 
Hessick & Morse, supra note 3, at 1576. 
235. For example, seventeen districts within Nebraska, North Dakota, and South Dakota have no lawyers. 
New York City’s Manhattan prosecutorial district contains 69,235 lawyers. 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
69 
Examining the data, it is glaringly obvious that many districts have significantly 
fewer eligible candidates for the office of prosecutor than is the case for almost any 
other office. This subsection empirically tests the claims of Hessick and Morse to 
see if this low supply does indeed result in fewer contested prosecutor elections.235
--- END PAGE 39 ---

--- PAGE 40 (PDF page 40) ---
Table 5 divides the districts in the ten states into quartiles based on how many 
lawyers live in the district.236 The first group of districts has the lowest number of 
lawyers residing in them (between zero and six lawyers), while the fourth group 
has the districts with the largest number of lawyers (between 120 and 69,235 law-
yers). As expected, it shows that, without controls, contested elections are signifi-
cantly less likely to occur in districts with a low number of lawyers than in districts 
with a large number of lawyers. 
Table 5: Percent of Contested Races by Number of Lawyers in a District 
Number of Lawyers 
(Quartiles) 
% of Contested 
Races  
1st 
6.71 
2nd 
11.68 
3rd 
18.12 
4th 
18.98  
236. Quartiles for number of lawyers are: [0, 6] (6, 31] (31, 120] (120, 69,235]. 
237. The correlation between number of lawyers and population is 0.73. 
238. The results do not change if we group districts into quartiles or quintiles. The number of lawyers still 
does not strongly predict contestation or competition. 
239. As noted above, most states in the sample were specifically selected because they appeared to have a low 
supply of lawyers. See supra notes 233–34. 
70                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31 
However, Table 5 does not establish that the number of lawyers, standing alone, 
explains why so many prosecutor elections are uncontested. Because the number 
of lawyers living in a district is correlated to that district’s population,237 we must 
perform a regression analysis to isolate the effect of the supply of lawyers. 
We employ the same logistic regression method detailed above, restricting the analy-
sis to the ten states with lawyer residency data. The results are reported below in Table 6. 
These results show that the number of lawyers is not a strong determinant of 
electoral contestation for prosecutorial elections.238 In other words, once we con-
trol for other variables, the number of lawyers in a jurisdiction does not appear to 
have a relationship with the likelihood of a contested election. While we cannot 
draw a definitive conclusion about the effect of lawyer supply given that ours is a 
nonrandom sample,239 these results suggest that population may have more influ-
ence on contestation and competition than lawyer supply. 
D. Crime and Prison Admission Trends 
As noted above, crime rates or prison trends might make an incumbent prosecu-
tor appear vulnerable, and thus these trends might encourage strategic would-be
--- END PAGE 40 ---

--- PAGE 41 (PDF page 41) ---
Table 6: Contestation in Prosecutorial Elections, including Number of Lawyers 
as a Predictor  
 
Any Challenger  
Number of Lawyers  
Straight Ticket Option   
0.467 (0.712) 
Multi-County Districts   
1.061 (0.827) 
Exclude Uncontested   
0.523 (0.802) 
Budget per Capita   
0.012 (0.016) 
Partisan Election   
1.760* (0.790) 
log(Population)   
0.270* (0.114) 
Partisan Mismatch   
0.184 (0.354) 
Open Race   
0.808* (0.327) 
Number of Lawyers   
0.074 (0.145) 
Constant   
6.217* (1.500) 
Observations 
550 
Akaike Inf. Crit. 
396.833 
State-Level Random Effects? 
Yes 
Note: * p<.05.  
240. See supra note 199 and accompanying text. 
241. We are missing data from 1064 districts, which represents 45.92% of all elections. 
242. We are missing data from 35.56% of elections. 
2023]
UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS
71 
challengers to enter a race.240 Unfortunately, we do not have complete crime and 
prison admission data—we are missing crime data for nearly half of the jurisdic-
tions,241 and we are missing prison admission data from more than one-third of the 
jurisdictions.242 That missing information limits our ability to draw firm conclu-
sions about the effect of these trends on prosecutor elections. We find that both var-
iables are weakly correlated with the number of competitive prosecutor elections, 
but the regression analysis cannot detect an effect, possibly due to a lack of data. 
Table 7 presents summary statistics, without controls, that illustrate how 
election contestation rates vary across different levels of crime. It compares 
districts where, in the four years before the prosecutor election, crime 
decreased versus those where crime increased. We do observe an increase in
--- END PAGE 41 ---

--- PAGE 42 (PDF page 42) ---
the percentage of contested prosecutor elections in districts where crime is 
higher in the election year than it was four years prior to the election. In other 
words, an increase in crime is correlated with a slightly increased likelihood of 
a contested election. 
Table 7: Contestation Rate by Change in Crime Rate 
4 Year Change  
in Crime 
% of Contested 
Races  
Decrease 
18.89 
Increase 
19.79  
Table 8 presents summary statistics using prison admission data. We calculated 
the number of prison admissions per crime committed for the year 2014. This can 
be viewed as a rough measure of prosecutorial harshness, where harsh prosecutors 
would have a higher ratio of admission to crimes than lenient prosecutors. We di-
vided the range of possible values into four equally sized quartiles243 with the first 
quartile representing districts with the fewest prison admissions compared to 
crimes and fourth quartile representing districts with the most prison admissions 
compared to crimes. 
Table 8 illustrates how rates of contested elections vary across those groups. It 
shows that districts with the lowest levels of admissions per crime have almost 
twice as many contested elections as districts with the highest levels of admissions 
per crime. Notably, but this relationship is not as strong for more marginal changes 
in the prison admission rate—the largest difference can be seen in those districts 
that send the fewest people to prison compared to their crime rate.   
Table 8: Contestation Rate by Prison Admission/Crime 
Prison Admissions/ 
Crimes (Quartiles) 
% of Contested 
Races  
1st 
18.98 
2nd 
18.32 
3rd 
19.05 
4th 
11.31  
243. Quartiles for prison admission rate are: [.0165, .114] (.114, .181] (.181, .296] (.296,1]. 
72                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 42 ---

--- PAGE 43 (PDF page 43) ---
Tables 7 and 8 show that both change in crime rate and prison admission rate are 
weakly correlated with contestation in prosecutorial races.244 If this correlation 
were to stand up in a regression model, it would tell us that prosecutor elections are 
sensitive to crime and punishment—specifically, a prosecutor is more likely to
face a challenger in an election if her district’s crime rate goes up and if her prison 
admission rate is low. 
But, as Table 9 reflects, that is not what the regression models show. 
Table 9: Crime Variables vs. Contestation in General Elections 
Any Challenger 
Change in Crime 
Admissions per Crime  
Straight Ticket Option 
0.107 (0.318) 
0.085 (0.370) 
Multi-County Districts 
0.139 (0.315) 
0.070 (0.325) 
Exclude Uncontested 
0.206 (0.443) 
0.008 (0.575) 
Budget per Capita 
0.005 (0.004) 
0.008 (0.006) 
Partisan Election 
1.056* (0.422) 
1.310* (0.509) 
log(Population) 
0.204* (0.058) 
0.154* (0.074) 
Open Race 
1.006* (0.181) 
1.021* (0.202) 
Change in Crime 
0.031 (0.114)  
 
Prison Admissions per Crime  
 
1.016 (0.688) 
Constant 
5.062* (0.765) 
4.780* (0.994) 
Observations 
1,252 
1,093 
Akaike Inf. Crit. 
1,154.168 
921.874 
Note: * p<.05.  
244. Interestingly, we found no correlation between population and crime rate (.05) or prison admission rates 
(.04). Indeed, based on the limited data we have, the factors were almost perfectly uncorrelated—that is to say, 
there is essentially no relationship between population and either crime rate or prison admission rate. 
2023]
UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS
73 
It is possible that our model did not detect an effect due to lack of data. The 
missing data limits the number of observations the model can make, and it also 
limits the statistical power of our analysis. 
But it is also possible that voters—and by extension, would-be challengers—do
not use crime rates or prison admission data to evaluate their local prosecutors. 
Indeed, given the evidence showing that voters are often misinformed about the
--- END PAGE 43 ---

--- PAGE 44 (PDF page 44) ---
crime rate,245 and the literature on the lack of voter knowledge generally,246 per-
haps it should be unsurprising if the behavior of voters or potential candidates is 
unresponsive to changes in crime or crime policy. 
CONCLUSION 
Elections that fail to afford voters a choice are a danger to democracy because 
they prevent voters from deciding who represents them. When it comes to prosecu-
tor elections, the large amount of discretionary power that prosecutors yield makes 
it important that voters have an opportunity to choose a prosecutor who shares their 
criminal justice policy preferences. Additionally, when prosecutors face no chal-
lenger, how they wield their discretion frequently goes unnoticed, leaving the pub-
lic uninformed about some of the most consequential decisions in the criminal 
justice system. 
Because elections are one of the few checks on prosecutor power,247 it is im-
portant to ensure that those elections are meaningful. Unfortunately, at pres-
ent, the vast majority of prosecutor elections do not offer voters a choice. And 
so, it is important to determine what changes can be made to the status quo to 
ensure that elections offer voters an opportunity to hold their prosecutors 
accountable. 
Consistent with the political science literature on other elected offices, our 
results indicate that when a seat is open (i.e., there is no incumbent) contesta-
tion and competition are significantly more likely. One of the frequently dis-
cussed options for creating more open seats in government is that of term 
limits. For prosecutorial elections, only the state of Colorado currently uses 
term limits, and even there the number of terms is inconsistent across districts 
because the state constitution allows individual districts to lengthen, shorten, 
or even eliminate them.248 Because the number of districts with term limits is 
so small—Colorado has only twenty-two prosecutorial districts—we could not 
systematically assess how term limits influence contestation or competition in 
prosecutor elections. 
Even if term limits would create more open seats, it is not always clear whether 
the benefits of such a policy change outweigh the potential drawbacks. Advocates 
for term limits argue that they would improve the effectiveness of our political 
245. See, e.g., Sara Sun Beale, The News Media’s Influence on Criminal Justice Policy: How Market-Driven 
News Promotes Punitiveness, 48 WM. & MARY L. REV. 397, 418–19 (2006). 
246. See generally, e.g., MICHAEL X. DELLI CARPINI & SCOTT KEETER, WHAT AMERICANS KNOW ABOUT 
POLITICS AND WHY IT MATTERS (1996); Christopher S. Elmendorf & David Schleicher, Informing Consent: 
Voter Ignorance, Political Parties, and Election Law, 2013 U. ILL. L. REV. 363 (2013); Ilya Somin, Political 
Ignorance and the Countermajoritarian Difficulty: A New Perspective on the “Central Obsession” of 
Constitutional Theory, 89 IOWA L. REV. 1287 (2004). 
247. See Wright, supra note 11, at 595–98 (describing the limited sources of accountability for prosecutors); 
Wright, supra note 89, at 585–590 (same). 
248. See COLO. CONST. art. XVIII, § 11(2); see also Hessick & Morse, supra note 3, at 1552 (“Only one 
state—Colorado—imposes term limits on its local prosecutors.”). 
74                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 44 ---

--- PAGE 45 (PDF page 45) ---
institutions, prevent elected officials from serving past their prime, and potentially 
bring in new policy ideas.249 Yet, skeptics of term limits argue that they too take 
power away from voters because they prevent some names from appearing on the 
ballot.250 Term limits also can decrease the quality of policy-making, as experience 
is thought to be an asset when it comes to making policy decisions (e.g., those with 
more criminal justice experience are likely to be better informed and thus better at 
making decisions about criminal justice issues).251 
Another method for increasing the number of open-seat elections would be to 
hold special elections when an office becomes vacant, rather than appointing 
someone to serve out the rest of the original term. It appears that a nontrivial 
number of incumbent prosecutors do not finish out their terms.252 We found that 
prosecutors who take office part-way through a term are no more likely to face a 
challenger than any other incumbent. Thus, requiring a special election would 
create an open-seat election, which is more likely to offer voters a choice on the 
ballot. 
Aside from attempting to create more open-seat elections, there appear to be a 
small number of legal changes that some states could adopt that would increase the 
rate of contested elections.253 We found that partisan elections had more contesta-
tion than non-partisan elections. And so, the five states that currently hold non-par-
tisan prosecutor elections should consider making this a partisan office. Similarly, 
excluding uncontested races from the primary ballot decreases the number of con-
tested elections. Fifteen states have adopted this practice, and they should change 
it. But there are limits on how much these election law changes can increase con-
testation in prosecutor elections. The majority of states already have these policies, 
so the benefits of partisan elections and including uncontested elections on the bal-
lot are already reflected in their contestation rates, and there is no policy change 
for these states to adopt. 
The most obvious policy change that states can adopt is to increase the popula-
tion of their prosecutorial districts. We found that the larger the population within 
the district, the more likely that an election will be both contested and competitive. 
We cannot be certain why larger populations lead to greater contestation and 
249. See e.g., Bruce E. Cain & Marc A. Levin, Term Limits, 2 ANNUAL REV. POL. SCI. 163, 167–72 (1999); 
Hendrik Hertzberg, Twelve is Enough, THE NEW REPUBLIC, May 14, 1990, at 23. 
250. See U.S. Term Limits, Inc. v. Thornton, 514 U.S. 779, 783 (1995) (stating that a state-imposed term limit 
“is contrary to the ‘fundamental principle of our representative democracy,’ embodied in the Constitution, that 
‘the people should choose whom they please to govern them’” (quoting Powell v. McCormack, 395 U.S. 486, 
547 (1969)). 
251. Cain & Levin, supra note 249, at 177; Erik H. Corwin, Limits on Legislative Terms: Legal and Policy 
Implications, 28 HARV. J. ON LEGIS. 569, 602, 604 (1991). 
252. See Hessick & Morse, supra note 3, at 1569 (observing that “about ten percent of local prosecutors 
resigned their office since the latest election”). 
253. Cf. Schleicher, supra note 196, at 423 (observing that some lack of electoral competition “is likely not a 
‘natural’ result of political forces, but is more likely the result of the legal regime and internal political party rules 
governing party competition” and thus “[t]he problem is legal, and not purely political”). 
2023]                      UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS                     
75
--- END PAGE 45 ---

--- PAGE 46 (PDF page 46) ---
competition. It may be that these large populations increase the power and the pro-
file of the prosecutorial office—the budgets and staff are larger, the caseload larger 
and more interesting, etc. And perhaps that increased profile and power are seen as 
a stepping stone to other government office.254 
See, e.g., Jed Shugerman, “The Rise of the Prosecutor Politicians”: Database of Prosecutorial 
Experience for Justices, Circuit Judges, Governors, AGs, and Senators, 1880-2017, SHUGERBLOG (July 7, 2017), 
https://shugerblog.com/2017/07/07/the-rise-of-the-prosecutor-politicians-database-of-prosecutorial-experience- 
for-justices-circuit-judges-governors-ags-and-senators-1880-2017/. 
Whatever the reason, the finding 
suggests that, in order to ensure more contested and competitive elections, states 
should seek to increase the size of their prosecutorial districts. 
The path to increasing the population size of districts is quite simple. Most states 
simply elect one prosecutor for each county; but more than a dozen states consoli-
date multiple counties into prosecutorial districts.255 More states could consolidate 
large numbers of low-population counties to create districts with large enough pop-
ulations to increase contestation and competition.256 
Prosecutors are very powerful actors in the criminal justice system, and so it is 
no surprise that reformers have sought to reverse mass incarceration trends by 
electing candidates who are committed to adopting progressive policies.257 But the 
urban and suburban areas that are electing reformers had already begun to reduce 
their reliance on incarceration—prison admissions in those areas have been falling 
for approximately the last decade. It is the rural areas of America—the areas that 
are least likely to have a contested or a competitive election—that continue to send 
large portions of their populations to prison.258 
In order to ensure that prosecutors are accountable to their communities, it is im-
portant to ensure that voters actually have a choice in prosecutor elections. Our 
analysis suggests that the best way to ensure that choice would be to increase the 
population of prosecutorial districts. 
It may seem like an esoteric policy change but consolidating rural counties into 
larger prosecutorial districts could ultimately have a significant effect on criminal 
justice reform. At a minimum, it would ensure that prosecutors could be held ac-
countable for the incredible amount of discretion that they wield. 
254. 
255. See Hessick & Morse, supra note 3, at 1553. 
256. See Hessick & Rodney, supra note 21 (suggesting that Nebraska move to a multi-county district model). 
257. See supra text accompanying notes 37–41. 
258. Hessick & Morse, supra note 3, at 1556–67 & tbl.6. 
76                                AMERICAN CRIMINAL LAW REVIEW                                
[Vol. 60:31
--- END PAGE 46 ---

--- PAGE 47 (PDF page 47) ---
APPENDIX: SUPPLEMENTARY ANALYSIS
Table A.1: Competition in Prosecutorial Elections  
 
Dependent variable: 
Challenger Vote Share <80%  
General Elections 
Primary Elections  
All Races 
Only Incumbents 
All Races 
Only Incumbents  
Straight Ticket 
Option   
0.217 (0.302)   
0.367 (0.451)   
0.451 (0.238)   
0.700 (0.393) 
Multi-County 
Districts   
0.071 (0.229)   
0.419 (0.340)   
0.121 (0.185)  
0.268 (0.355) 
Exclude Uncontested   
0.115 (0.408)   
0.418 (0.592)   
0.566* (0.235)   
0.831* (0.381) 
Budget per Capita   
0.073 (0.058)   
0.160 (0.085)  
0.014 (0.058)  
0.037 (0.129) 
Partisan Election   
1.048* (0.401)   
1.310* (0.614)  
 
 
log(Population)   
0.260* (0.047)   
0.272* (0.065)   
0.273* (0.046)  
0.139 (0.086) 
Open Race   
1.057* (0.136)    
 
1.076* (0.130)  
 
Partisan Mismatch  
 
0.518* (0.190)    
 
0.804* (0.284) 
Incumbent Tenure    
 
0.029 (0.086)    
 
0.075 (0.123) 
Constant   
5.633* (0.631)   
6.140* (0.933)   
5.889* (0.534)   
3.510* (0.975) 
Observations 
2,316 
1,277 
4,307 
1,013 
Akaike Inf. Crit. 
1,940.902 
1,036.058 
2,143.946 
636.861 
State-Level 
Random Effects? 
Yes 
Yes 
Yes 
Yes 
Note: * p<.05.  
2023]
UNDERSTANDING UNCONTESTED PROSECUTOR ELECTIONS
77
--- END PAGE 47 ---
