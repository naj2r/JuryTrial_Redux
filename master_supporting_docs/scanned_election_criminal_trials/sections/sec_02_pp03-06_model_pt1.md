# Section: Model (Part 1)
**PDF pages:** 3–6
**Split method:** headers
**Note:** This is part of a longer section, sub-split to ensure deep reading.

---

--- PAGE 3 ---
Public Choice (2014) 161:141–156
143
our theoretical model is that of Gordon and Huber (2002), who consider the moral hazard
problem arising when voters use observable signals of performance to monitor prosecutorial
effort. They do not consider adverse selection issues.
A qualitative analysis of the related matter of the retention of local prosecutors is Wright
(2009), who presents stylized facts concerning media coverage of prosecutor elections.
The model of this paper has similarities to incumbent-challenger models (Besley 2006),
which consider the agency issues involved in elections. Such models have been used to
analyze a host of situations, including political business cycles (Rogoff and Siebert 1988;
Rogoff 1990), the continuation of inefﬁcient policy (Majumdar and Mukand 2004), and the
persistence of conﬂict (Bandyopadhyay and Oak 2010). Our model predicts an excessive
use of trials, in line with most results in the literature.
The growing literature on how career concerns affect the behavior of public ofﬁcials bor-
rows the central insight that politicians manipulate outcomes before elections. Leaver (2009)
and Shotts and Wiseman (2010) both consider environments of asymmetric information on
the quality of regulators. Hanssen (1999, 2000), Shepherd (2009), Berdejo and Yuchtman
(2010), and Lim (2013) all provide empirical veriﬁcation of the hypothesis that the inde-
pendence and retention concerns of judges affect their decisionmaking. While not about
prosecutorial behavior, these papers demonstrate that retention motives affect outcomes of
the justice system.
2 Model
We now develop a model of prosecutorial decisionmaking that will allow us to investigate
the incentives created by elections. Consider a two-period model. In the ﬁrst period there
is a single prosecutor of unknown quality who is to decide how to handle cases brought
before her. She takes one of two quality types q ∈{H,L}, referred to as ‘high’ and ‘low’
respectively. She is high quality with probability γ ∈(0,1). Let the parameter θ be a sum-
mary measure of the strength of evidence she has against the defendant in any given case.
The parameter may also capture information the prosecutor has concerning the skill of the
defendant’s attorney. Assume that θ ∈[0,θM] where θM < ∞, with this being known to the
defendant as well. Observing θ for a particular case, the prosecutor may either take the case
to trial or engage in plea bargaining.2 Assume that a large number of cases come up in the
ﬁrst period, which we can think of as a term in ofﬁce.
Denote s as the sanction received if the prosecutor is successful in the courtroom. The
sanction is known and is exogenously set by, for example, sentencing guidelines.3 Alter-
natively, if there are judicial discretion, uncertain parole outcomes, or appeals, s is best
thought of as the expected sanction. We also take account of the probability that the prose-
cutor is successful at trial, a probability which depends on the quality of the prosecutor and
the evidence. A high-quality prosecutor wins at trial with probability pH(θ), while if she
is low quality she wins with probability pL(θ). Assume that 1 > pH(θ) > pL(θ) > 0 ∀θ,
pq(0) = 0, and dpq
dθ ≥0 ∀q. Finally, if she takes the case to trial and obtains a conviction, a
cost c > 0 is borne by the prosecutor and the defendant.4 For simplicity we assume that c
does not depend on the strength of the evidence or the prosecutor’s ability.
2We assume that the choices of whether to ﬁle charges and which charges to ﬁle have already been made.
3The analysis is unaffected if one assumes that s = s(θ), where ds
dθ ≥0.
4Assuming different costs of trials for the two parties does not make any substantive change in the analysis.
--- END PAGE 3 ---

--- PAGE 4 ---
144
Public Choice (2014) 161:141–156
With regard to plea bargaining, let g(θ) denote the agreed plea bargain sentence. We
ignore the possibility that the plea outcome depends on the quality of the prosecutor. As
the prosecutor’s type is assumed to be the private information to the defendant, we assume
the outcome under plea bargaining cannot be conditioned on type. One could alternatively
argue, however, that even though the skill of the incumbent is not known to the voting
public, defense attorneys may, in view of their repeated interaction, gain this information.
In that case, g would be a function of the prosecutor’s type as well as of θ. Extending the
environment to allow for type-dependent plea bargains simply adjusts the bounds of the
set of separating and pooling equilibrium. Being cumbersome, the analysis is not presented
here, but is available from the authors upon request.
How might the function g be determined? One way is to assume that a prosecutor makes
the best offer that the defendant will accept. Since trials are lengthy and the ﬁnal sanction
of a successful trial comes with a delay, compared with the outcome of plea bargain, which
is settled more quickly, the defendant will discount the future disutility of the cost of trial.
Thus, he or she will agree to a sanction no greater than δps +c where p = γpH +(1−γ )pL.
Alternatively, with optimism or self-serving bias (as is often assumed in the plea bargaining
literature; see Burke 2007 and Farmer and Pecorino 2002 for a discussion), a defendant may
believe that he will receive a sanction kps where k < 1, and so even with a take it or leave
it offer will not accept a sanction greater than kps + c. Consequently dpq
dθ s > dg
dθ ≥0 and
g(θ) > 0 ∀θ. Such results are consistent with the usual assumption that in a plea bargain the
sentence received is less than after a trial conviction. Finally, assume that if the prosecutor
is indifferent between the two options then she chooses to plea bargain.
Let w(g(θ)) be the welfare generated from a case that results in g(θ), and w(pq(θ)s)−c
be the welfare generated from a case that goes to trial. Assume that w is a strictly increasing
function. Let W(q) be the welfare generated over the prosecutor’s entire ﬁrst term if she is of
quality q. To link the two concepts, assume that θ for each case is a random variable. Across
cases, values of θ are independent and identically distributed. The likelihood of a particular
value is determined by the distribution function F : [0,θM] →[0,1]. Assume that a large
number of cases arise during the prosecutor’s term and that the number of cases disposed of
does not depend on the manner in which they are handled. The expected welfare from a case
then equals the average welfare generated from each case over the course of the term. Given
that this is so, assume that ﬁrst-period welfare equals the expected welfare from a randomly
selected case. Thus, if a prosecutor chooses to take every case to trial where θ ≥θ and plea
out those with θ < ¯θ, then ﬁrst-period welfare is
W(q) =
 θ
θ=0
w

g(θ)

dF(θ) +
 θM
θ=θ

w

pq(θ)s

−c

dF(θ).
(1)
The assumption of welfare being monotonic in sanctions is based on the presumption that
the sanction has been optimally chosen by society. This does not necessarily mean that
society beneﬁts from having every defendant punished as harshly as possible, but rather
that given the option to impose the harsher sanction deemed appropriate by the judge (or
chosen by the sentencing board or legislature) or to accept a plea offer, welfare is greater
if the prosecutor achieves the stiffer of the two penalties. One may also think of welfare
as the expected welfare allowing for the possibility of wrongful convictions.5 The cost of
trial appears as a negative term because with greater expenditures on a trial, the resources
available for disposing of other cases shrink. Finally, let V (q′) be second-period welfare if
the prosecutor is of quality q′, where dV
dq′ > 0. Consequently, total welfare is W(q) + V (q′).
5See McCannon (2013) for an analysis of the effect of prosecutor elections on mistakes and appeal[s].
--- END PAGE 4 ---

--- PAGE 5 ---
Public Choice (2014) 161:141–156
145
2.1 First best
We now describe the ﬁrst-best outcome in this environment as it is a useful benchmark. Tak-
ing a case to trial is best if w(pq(θ)s) −c > w(g(θ)). Trial costs are assumed not to be too
great: c < w(pL(θM)s) −w(g(θM)). Otherwise, even with very good evidence the expected
welfare of going to trial is insufﬁcient to motivate that action. Given the way we have mod-
eled plea bargaining, dpq
dθ s > dg
dθ and pq(0)s = 0 < c, it follows that there exists a threshold
value of θ, denoted θq, where welfare is equal between the two options.6 The threshold value
depends on the prosecutor’s quality, since the probability of conviction depends on her abil-
ities. Consequently, θL > θH > 0. If θ > θq, then W(q) is improved if the case proceeds
to trial. The evidence is so substantial that the expected sanction is severe enough to make
the trial preferable. If θ < θq, then the best outcome is for the cases to be resolved by plea
bargaining. The expected sanction is small and, given the high cost of trial, negotiating and
accepting a plea generates a better outcome. Note also that the ﬁrst-best outcome requires
that a prosecutor of high quality be retained since V (H) > V (L). Also, if the prosecutor is
low quality, then a new one should be selected, since EV > V (L).
2.2 The model with asymmetric information
Consider the principal-agent problem that arises when the principal (in this case the voting
public or, with ideological heterogeneity, the median voter) wants to maximize total welfare,
but does not know the quality of the prosecutor or of the evidence in each particular case.
With perfect information only high-quality prosecutors are retained. However, with a bonus
for being retained, the prosecutor’s payoff does not coincide with the median voter’s. Thus,
both types of prosecutor may try to signal that they are of the high type. We are interested
in understanding how such signals distort outcomes in the criminal justice system.
Suppose that the beneﬁt received by the prosecutor from a particular case is either
u(pq(θ)s) −c or u(g(θ)). Her total expected utility, Uq, then aggregates the expected bene-
ﬁts derived in each case. Assume that the expected utility of a randomly selected case equals
the average utility generated over the prosecutor’s term. Also, let b > 0 denote a retention
bonus, which the prosecutor receives if and only if she is reelected. One may think of the
bonus as future wages earned, but it could also represent the future gains for an altruistic
prosecutor who, if retained, gains utility from prosecuting more cases.7 Thus, if a prosecutor
takes a case to trial if and only if θ ≥θq, then
Uq =
 θq
θ=0
u

g(θ)

dF(θ) +
 θM
θ=θq

u

pq(θ)s

−c

dF(θ) + b
(2)
if retained and Uq −b if not retained. To simplify the analysis we assume, absent compen-
sation, that the preferences of the prosecutor are related directly to welfare, u(P ) = αw(P )
for α > 0. Thus, the environment may be best thought of as addressing the decision making
of the chief prosecutor who is directly accountable to the voting public.
6With the assumption that pq(θ)s and g(θ) are continuous functions and c is bounded from above, the inter-
mediate value theorem guarantees that these thresholds (and all thresholds derived throughout the analysis)
exist.
7This setup is similar to the incumbent-challenger models of political agency, which consider the reelection
motives of political leaders (Besley 2006). It is possible to make b type-dependent as well, i.e., a better
prosecutor could also enjoy higher utility in period 2 because society’s welfare is higher. As it does not
change the primary predictions of the model, such complications are not presented.
--- END PAGE 5 ---

--- PAGE 6 ---
146
Public Choice (2014) 161:141–156
We model the situation as a signaling game. Prosecutors signal their quality by taking
a certain number of cases to trial. Voters observe the outcomes, namely the sentences ob-
tained, in trial, and then decide whether to retain the prosecutor. If the prosecutor is not
retained, a randomly chosen challenger takes the incumbent’s place. We will analyze the
perfect Bayesian equilibria of this game.
3 Prosecutor evaluation
The question becomes how the prosecutor’s behavior responds to the way in which she
believes voters will evaluate her. The voters, who do not have access to information about
her true type, may use a number of evaluation criteria. One possibility is that prosecutors
can signal to voters their quality by getting heavy sentences at trial. Thus, we analyze a
particular metric of quality, namely aggregate sentence lengths obtained. Evidence has been
presented that this is one of the primary measurements used to assess incumbent prosecutors
in media coverage of elections (Wright 2009). Boylan (2005) provides evidence suggesting
that this is the quantity that prosecutors try to maximize.
Accordingly, suppose that voters assess the quality of the prosecutor by the lengths of
the sentences she obtains. Sanctions may be achieved either through plea bargaining or by
courtroom victories. Hence, the aggregate sanction imposed over the course of her term can
be used to assess her quality.
As described above, for each trial an independent draw of θ is taken from the distribution
function F. The prosecutor selects a threshold value of θ, denoted θq, for her term. If θ > ¯θq
the case is taken to trial; if θ < ¯θq a plea bargain results. This prosecutor’s choice arises
because the difference between the expected sanction from trial and the plea bargain grows
as the quality and quantity of evidence improves. The threshold she chooses may depend on
her quality. The expected sanction generated is
Sq =
 θq
θ=0
g(θ)dF(θ) +
 θM
θ=θq
pq(θ)s dF(θ).
(3)
Since it is assumed that a large number of cases are decided in a term, the expected sanction
of a randomly selected case represents the actual aggregate sentence when the number of
cases is normalized to unity.
The voters observe the aggregate sanction achieved and decide whether to retain or re-
place the incumbent. If the aggregate sentence length exceeds a threshold, then the prosecu-
tor is retained. If the threshold is not achieved, then we assume that with probability z the
prosecutor is replaced. This allows for uncertainty in the process and can be a summary mea-
sure of the likelihood of a suitable replacement being found. For example, z may represent
the probability that the opposing party organizes a campaign to replace the incumbent. Thus,
the parameter z serves as a measure of the competitiveness of the electoral environment.
3.1 Separating equilibria
Consider, ﬁrst, separating equilibria. In such outcomes voters keep the prosecutor if S
matches or exceeds Se, in the belief that a prosecutor whose aggregate sanction is greater
than or equal to Se is type H and those below are type L. Which values of Se are voters able
to obtain in a separating equilibrium?
--- END PAGE 6 ---