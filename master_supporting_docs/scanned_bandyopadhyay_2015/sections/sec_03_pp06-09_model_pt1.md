# Section: Model (Part 1)
**PDF pages:** 6–9
**Split method:** headers
**Note:** This is part of a longer section, sub-split to ensure deep reading.

---

--- PAGE 6 ---
224
Journal of Public Economic Theory
Hanssen (2000) provides evidence that independent judges, less inﬂuenced
by political/electoral factors, provide administrative agencies the incentive
to spend more time and effort attempting to protect their actions from ju-
dicial review. While not about prosecutorial behavior, these papers demon-
strate that the retention motives affect the outcome of the legal system.
Section 2 presents the model. The ﬁrst-best outcome is identiﬁed.
Section 3 investigates the effects of two primary evaluation tools that could
be used to measure the quality of an incumbent prosecutor: the aggregate
sentence length obtained and the conviction rate. The equilibria are derived.
The optimal evaluation criterion is derived in Section 4. Section 5 tests the
robustness of the results by considering an extension of the model to a con-
tinuum of types of prosecutors, while Section 6 concludes.
2. Model
Consider a two-period model. In the ﬁrst period there is a single prosecutor
of unknown quality who is to decide how to handle cases brought before
her. To keep the analysis simple suppose the prosecutor is one of two quality
types q ∈{H, L} which we call high and low, respectively. She is high quality
with probability γ ∈(0, 1) and low quality with probability 1 −γ . Let the
parameter θ denote the strength of evidence she has against the defendant
in any given case. One may also think of θ being dependent on the skill
of the defendant’s lawyer and the investigatorial expenditures made by the
defense which we do not model here. Assume θ ∈[0, θM], where θM < ∞
and is exogenously given. Observing θ for a particular case the prosecutor
has two options from which to choose. She may either try the case by taking
it to trial or she may engage in plea bargaining.5 Assume that a large number
of cases come up in the ﬁrst period, which are either tried or plea bargained.
One may think of the ﬁrst time period as a term in ofﬁce.
Denote S (θ) as the sanction received if successful in the courtroom.
For example, the sanction may represent the length of time the criminal
is incarcerated. Assume that no evidence results in no sanction, S (0) = 0
and assume S (θ) is a continuous and (weakly) increasing in θ. The sanc-
tion is known and is exogenously set by, for example, sentencing guidelines.
Alternatively, with judicial discretion, uncertain parole outcomes, and
appeals this is best thought of as the expected sanction conditional on the
initial conviction. Additionally, the probability the prosecutor is successful at
trial depends on the quality of the prosecutor and the quality of the evidence.
A high-quality prosecutor wins at trial with probability p H (θ), while if she is
low quality she wins with probability p L (θ). Assume 1 > p H (θ) > p L (θ) > 0
∀θ, and p q is continuous in q with dp q
dθ ≥0 ∀q. Finally, if she takes the case
to trial, a cost C > 0 (with an upper bound of C) is experienced, which for
5 We assume that the choice of whether to ﬁle charges has already been made.
--- END PAGE 6 ---

--- PAGE 7 ---
Prosecutorial Retention
225
simplicity is assumed not to depend on the quality of the evidence or the
prosecutor’s ability.6 One may think of the cost as capturing additional re-
sources expended by the prosecutor’s ofﬁce, the opportunity cost of the ju-
rors’ time, along with all additional expenditures that come from jury trials.
The cost ﬁgures in the prosecutor’s utility and society’s welfare function.
With regards to the plea bargaining option, denote B (θ) as the agree-
ment that arises. As the prosecutor type is private information the outcome
under plea bargaining cannot be conditioned on type. It can of course be ar-
gued that even though the skill of the incumbent is not known to the voting
public, defense attorneys may actually (due to their repeated interaction)
gain this information. This would then make the plea outcomes a function
of the prosecutor’s type as well. Extending the environment to allow for type-
dependent plea bargains simply adjusts the bounds of the set of separating
and pooling equilibrium, is cumbersome, and is not presented here but in-
cluded in the Appendix. Since there are costs associated with the trial then,
absent any asymmetric information or optimism bias,7 plea bargaining is suc-
cessful, i.e., the defendant would accept the offer B (θ). Also, one might ex-
pect better evidence against the defendant to result in a tougher plea agree-
ment. Hence, assume B (θ) is continuous in θ with dB
dθ ≥0 and B (θ) ≥0 ∀θ.
Additionally, if the prosecutor is indifferent between the two options assume
she chooses to plea bargain.
Denote w (B (θ)) as the welfare generated from a case that results in the
plea bargain B (θ) and p q (θ) w (S (θ)) −C as the expected welfare gener-
ated from a case that goes to trial. Assume w is a strictly increasing function.
Denote W (q) as the welfare generated over the entire term (i.e., the ﬁrst-
period welfare) if the prosecutor is of quality q. To link the two concepts
let F : [0, θM] →[0, 1] denote the distribution function in which the qual-
ity/quantity of evidence from each case is (independently) drawn. Assume a
large number of cases arise in the term and the number of cases disposed of
does not depend on the manner in which the prosecutor handles them so
that the expected welfare from a case equals the average welfare generated
from each case over the course of the term.8 Given this, assume ﬁrst-period
welfare equals the expected welfare from a randomly selected case. Thus, for
example, if a prosecutor chooses to take every case to trial where θ ≥θ and
plea out those with θ < θ, then ﬁrst-period welfare is
W (q) =
 θ
θ=0
w (B (θ)) dF (θ) +
 θM
θ=θ

p q (θ) w (S (θ)) −C

dF (θ) .
(1)
6 Nothing changes with regard to the main results of the model if we assume that C also
depends on q.
7 See Burke (2007) for how such psychological factors affect plea bargaining outcomes.
See Garoupa and Stephen (2008) for a more cautionary view of the efﬁciency of plea
bargaining.
8 While an interesting and important issue to address, case backlogs, judicial resources,
and incentives used to encourage judicial actors to process more cases are not considered
here.
--- END PAGE 7 ---

--- PAGE 8 ---
226
Journal of Public Economic Theory
We include the cost of going to trial in the welfare function because trials
are costly and deplete society’s resources. The assumption of welfare being
monotonic in sanctions is based on the assumption that the sanction has
been optimally chosen by society. It is worthwhile to point out that this does
not necessarily mean that society beneﬁts from having every defendant pun-
ished as harshly as possible, but rather given the option to impose the high
sanction deemed appropriate by the judge (or chosen by the sentencing
commission or legislature via statute etc.) or to accept a plea offer, welfare
is greater if the prosecutor achieves the higher sanction of the two. As the
sanction S(θ) is deemed to have been chosen optimally, a deviation from
that sentence to that agreed upon in plea bargaining will give lower welfare
unless offset by the saved cost of trial. Furthermore, one may think of w as ex-
pected welfare incorporating type I and type II errors.9 Finally, denote V (q ′)
as the second-period welfare if the prosecutor is of quality q ′ with dV
dq ′ > 0.
Consequently, total welfare is W (q) + V (q ′). We assume that if replaced the
new prosecutor is high quality with probability γ ∈(0, 1) and low quality with
probability 1 −γ so q ′ = γ H + (1 −γ )L. If re-elected q ′ = q.
To summarize, in period 1 prosecutors choose a mix of trials and plea
bargains. This is observed by the voting population and a decision is made
to either retain the prosecutor or replace her. Welfare is simply the sum of
welfare of the two periods.
2.1. First Best
In this environment, the ﬁrst-best outcome can be described. Taking a case
to trial maximizes the welfare generated from that case if p q (θ) w (S (θ)) −
C > w (B (θ)). A few assumptions are employed regarding the welfare func-
tions. First, assume dp q
dθ w (S (θ)) + p q (θ) ( dw
dS
dS
dθ ) > dB
dθ ∀θ. This simply means
that the expected sanction from increased levels of θ rises at a faster rate for
going to trial than from plea bargaining. This implies that the plea bargain-
ing sentence is always less than the sentence received at trial. How might this
assumption be rationalized or, in other words, how might the function B (θ)
be determined? One way is to assume (as is done in some of the plea bar-
gaining literature) that a prosecutor makes the best offer (from her point of
view) that the defendant will accept. We assume that since trials are lengthy
and the ﬁnal sanction of successful trials comes with a delay, compared to
plea bargains which are settled more quickly, the defendant will weigh the
future disutility of the cost of trial by discounting, which means she will agree
9 For welfare to be monotonic in θ and thus S, the magnitude of errors cannot be too
high. In Appendix C, we explicitly include both types of errors in our analysis and show
that our results remain unchanged as long as the errors are not too high. We consider two
scenarios: one where both types of prosecutor make errors at the same rate and another
where the high quality prosecutor makes less errors. We show reasonable conditions under
which our analysis holds.
--- END PAGE 8 ---

--- PAGE 9 ---
Prosecutorial Retention
227
to a sanction no greater than δp S(θ) −cd where p = γp H + (1 −γ )p L, cd is
the cost to the defendent for some discount factor δ < 1. Alternately, with
optimism or self-serving bias (as is often assumed in the plea bargaining lit-
erature, see Burke [2007] and Farmer and Pecorino [2010] for a discussion)
a defendant may believe that she will receive a sanction kp S(θ) where k < 1
so even with a take it or leave it offer will not accept a sanction greater than
that. This assumption is indeed consistent with the view that in a plea bar-
gain the sentence received is less than in a trial.10 Second, assume the cost
of trial is not too high. If the cost to going to trial is excessively high, then
it is possible that even with extremely good evidence the expected payoff to
going to trial is less than the value of plea bargaining.11 Here we assume that
the cost parameters are such that it is worthwhile taking some cases to trial.
Consequently, it follows immediately that there exists a threshold value
of θ, denoted θq, where welfare is equal between the two options.12 The
threshold value depends on the prosecutor’s quality since the probability
of conviction depends on her abilities. Consequently, θL > θH > 0. If θ > θq,
then W (q) is increased when the case proceeds to trial. In this scenario
the evidence is so great that the expected sanction is high enough to make
the trial preferable. The sanction from plea bargain is insufﬁcient. If θ < θq,
then the best outcome is for the case to be decided by plea bargaining. The
expected sanction is small so that with the cost of the trial the resulting plea
generates a better outcome.13
Thus, we get the following:
PROPOSITION 1:
There exists a threshold θq such that if a prosecutor of type q is
in ofﬁce W (q) is maximized by taking cases θ > θq to trial and plea bargaining the
rest.
Figure 1 depicts the determination of these thresholds. Clearly, θL >
θH > 0.
10 In fact, Black’s Law Dictionary deﬁnes plea bargaining as “[t]he process whereby the
ACCUSED and the PROSECUTOR in a criminal case work out a mutually satisfactory
DISPOSITION of the case subject to court approval. It usually involves the defendant’s
pleading guilty to a lesser offense or to only one or some of the counts of a multi-count
INDICTMENT in return for a lighter sentence than that possible for the graver charge.”
11 Speciﬁcally, assume C ≤p L(θM)w(S(θM)) −w(B(θM)).
12 With the assumption that p q(θ)S(θ) and B(θ) are continuous functions and C is
bounded from above, the intermediate value theorem guarantees that these thresholds
(and all thresholds derived throughout the analysis) exist.
13 To simplify the analysis only the environment where cases with weaker evidence results in
plea bargaining is considered. One could extend the environment arguing that cases with
very strong evidence also result in plea bargaining. As a consequence, plea bargaining fails
only for cases with intermediate amounts of evidence. Such setups are typically considered
in model of civil suits following the seminal contribution of Priest and Klein (1984). The
main results of the paper hold in such an environment, but due to the cumbersome nature
of this extension the results are not presented here (but see Appendix B).
--- END PAGE 9 ---