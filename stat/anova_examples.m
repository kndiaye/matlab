%% Factorial analyses datasets
% Examples of ANOVA
% from the web etc.

%% RESSOURCES
% http://www.brown.edu/Research/LCE/Fall2004/Within%20subjs.pdf
%

%% Simple examples
%

%% Zar, 1999, pp. 250 sqq.
% Ex. 12.5 (repeated measure one-way ANOVA)
X= [
    164 152 178
    202 181 222
    143 136 132
    210 194 216
    228 219 245
    173 159 182
    161 157 165
    ]';
% F = (1454/2)/(695.3/12) = 727/57.94 = 12.6


%% BETWEEN SUBJECT DESIGN WITH 2 REPLICATES
% ========================================
% http://www.richland.edu/james/lecture/m170/ch13-2wy.html
% SS = 512.8667  449.4667   143.1333  136.0000  1241.4667
% F observed = 28.283   12.393   1.973
% F critique = 3.682 3.056 2.641
X=[
    106, 110 , 95, 100 , 94, 107 , 103, 104 , 100, 102;
    110, 112 , 98, 99 , 100, 101 , 108, 112 , 105, 107;
    94, 97, 	86, 87 	98, 99 	99, 101 	94, 98];
X=cat(3,X(:,1:2:end),X(:,2:2:end))
[p,F]=myanova(X,2,[])

% =========================================================================

%% fromoac (1)
% Repeated Measures Anova in SPSS
% Example 1.
% Table 1, page 264.
% subject cond1 cond2 cond3.
x= [
    1 100  90 130
    2  90 100 100
    3 110 110 109
    4 100  90 109
    5 100 100 130
    ];

%% fromoac (2)
% http://www.linguistics.ucla.edu/faciliti/facilities/statistics/fromoac.htm
% Example 2.
% Table 3, page 268.
% subject c1t1 c1t2 c1t3  c2t1 c2t2 c2t3  c3t1 c3t2 c3t3
X=[
    1  8  9  8   8  9   7   10  9  10;
    2  9  10 9  10  9  13   8   9   9;
    3  8  7  7  12  7   9   10  9   7;
    4  6  8  9   8 10  10   12  9   10;
    5  7  6  7  11 12   8   8   11  9
    ];
X=X(:,2:end);
X=reshape(X,5,3,3);
%
% % COND TRIAL SUBJECT
X=permute(X,[3 2 1]);
%
[p,F]=myanova(X,2,1:2)
% l=factorlabels(X)
% rm_anova2(X(:), l(:,3),l(:,1),l(:,2),{'COND', 'TRIAL'})
% %     'Source'                 'SS'         'df'    'MS'         'F'         'p'
% %     'COND'                   [24.8444]    [ 2]    [12.4222]    [4.0216]    [0.0618]
% %     'TRIAL'                  [ 0.3111]    [ 2]    [ 0.1556]    [0.0625]    [0.9399]
% %     'COND x TRIAL'           [ 1.6889]    [ 4]    [ 0.4222]    [0.1907]    [0.9397]
% %     'COND x Subj'            [24.7111]    [ 8]    [ 3.0889]          []          []
% %     'TRIAL x Subj'           [19.9111]    [ 8]    [ 2.4889]          []          []
% %     'COND x TRIAL x Subj'    [35.4222]    [16]    [ 2.2139]          []          []

% Using Greenhouse-Geisser corection
% Source	 Type III Sum of Squares	 df	 Mean Square	 F	 Sig.
% COND          24.844	 1.976	 12.570	 4.022	 .063
% Err(COND)     24.711	 7.906	 3.126
% TRIAL         .311	 1.783	 .174	 .063	 .924
% Err(TRIAL)    19.911	 7.134	 2.791
% COND*TRIAL	   1.689	 2.601	 .649	 .191	 .878
% Err(COND*TRIAL) 35.422	 10.402	 3.405


% =========================================================================

%% Auto Pollution Filter Noise
% http://lib.stat.cmu.edu/DASL/Datafiles/airpullutionfiltersdat.html
% The data are from a statement by Texaco, Inc. to the Air and Water Pollution
% Subcommittee of the Senate Public Works Committee on June 26, 1973.
% Mr. John McKinley, President of Texaco, cited an automobile filter developed
% by Associated Octel Company as effective in reducing pollution. However,
% questions had been raised about the effects of filters on vehicle performance,
% fuel consumption, exhaust gas back pressure, and silencing. On the last
% question, he referred to the data included here as evidence that the silencing
% properties of the Octel filter were at least equal to those of standard silencers.
%
%    1.  NOISE = Noise level reading (decibels)
%    2. SIZE = Vehicle size: 1 small 2 medium 3 large
%    3. TYPE = 1 standard silencer 2 Octel filter
%    4. SIDE = 1 right side 2 left side of car
%    and 3 replicates
x=[
    810	1	1	1
    820	1	1	1
    820	1	1	1
    840	2	1	1
    840	2	1	1
    845	2	1	1
    785	3	1	1
    790	3	1	1
    785	3	1	1
    835	1	1	2
    835	1	1	2
    835	1	1	2
    845	2	1	2
    855	2	1	2
    850	2	1	2
    760	3	1	2
    760	3	1	2
    770	3	1	2
    820	1	2	1
    820	1	2	1
    820	1	2	1
    820	2	2	1
    820	2	2	1
    825	2	2	1
    775	3	2	1
    775	3	2	1
    775	3	2	1
    825	1	2	2
    825	1	2	2
    825	1	2	2
    815	2	2	2
    825	2	2	2
    825	2	2	2
    770	3	2	2
    760	3	2	2
    765	3	2	2
    ];
[i,nl]=dgrouping(x(:,2:end));
clear X
X(i)=x(:,1);
X=reshape(X,nl);

% =========================================================================

%% One way ANOVA from Loftus & Masson, 1994
% Exposure Duration Per Word (sec)
% 1 Sec 2 Sec 5 Sec
X= [
    10 13 13
    6 8 8
    11 14 14
    22 23 25
    16 18 20
    15 17 17
    1 1 4
    12 15 17
    9 12 12
    8 9 12
    ]';
% M1 = 11.0 M2 = 13.0 M3 = 14.2

% =========================================================================

%% Loftus & Masson 1994 reported in Cousineau 2005

X= [
    1 450 462 12 460 482 22 460 497 37 480 507 27
    2 510 492 -18 515 530 15 520 534 14 504 550 46
    3 492 508 16 512 522 10 503 553 50 520 539 19
    4 524 532 8 530 543 13 517 546 29 503 553 50
    5 420 409 -11 424 452 28 431 468 37 446 472 26
    6 540 550 10 538 528 -10 552 575 23 562 598 36
    ];
X=reshape(X(:,2:end),6,3,4);
X=permute(X(:,1:2,:),[2 3 1]);

% X : R vs U | SOA 50/100/200/400 | SUBJ(6)

% =========================================================================

%% Two-way ANOVA from Cousineau 2007
X= [
    550 580 610
    605 635 655
    660 690 710
    ]';


% Cousineau ?
X= [
    150.   44.   71.   59.   132.   74.   1.
    335.   270.   156.   160.   118.   230.   1.
    149.   52.   91.   115.   43.   154.   1.
    159.   31.   127.   212.   71.   224.   1.
    159.   0.   35.   75.   71.   34.   1.
    292.   125.   184.   246.   225.   170.   1.
    297.   187.   66.   96.   209.   74.   1.
    170.   37.   42.   66.   114.   81.   1.
    346.   175.   177.   192.   239.   140.   2.
    426.   329.   236.   76.   102.   232.   2.
    359.   238.   183.   123.   183.   30.   2.
    272.   60.   82.   85.   101.   98.   2.
    200.   271.   263.   216.   241.   227.   2.
    366.   291.   263.   144.   220.   180.   2.
    371.   364.   270.   308.   219.   267.   2.
    497.   402.   294.   216.   284.   255.   2.
    282.   186.   225.   134.   189.   169.   3.
    317.   31.   85.   120.   131.   205.   3.
    362.   104.   144.   114.   115.   127.   3.
    338.   132.   91.   77.   108.   169.   3.
    263.   94.   141.   142.   120.   195.   3.
    138.   38.   16.   95.   39.   55.   3.
    329.   62.   62.   6.   93.   67.   3.
    292.   139.   104.   184.   193.   122.   3.
    ];
X=reshape(X(:,1:6),[8,3,6]);
X=permute(X,[1 3 2]);


% =========================================================================

%% Cousineau TQPM
X=str2num(urlread('http://www.tqmp.org/doc/vol1-1/p42.dat'));
X=reshape(X(:,end),[16,5,2]);
X=permute(X,[3 2 1]);
myanova(X,2,1:2)

% all?the?variances?are?homogeneous?and?spherical,?Tabachnik?&?Fidell,?1996
% Mauchly?s?W?=?0.74,?p?>?.50?for?factor?2?
% and?W?=?0.68,?p?>?.50?for?the?interaction;?
% this?test?cannot?be?performed?for?factor?1?since?it?has?only?two?levels
% but?we?generated?the?data?such?that?it?is?also?homogenous.
% The?Greenhouse?Geiser?and?the?Huynh?Feldt?epsilons?are?close?to?1?so?that
%?we?don?t?need?to?use?corrections?(Huynh,?1978,?Rouanet?and?Lepine,?1970).

% Effect?name? SS??      dl?? MS??       F??   p<0.001
% Factor?1??  10621??     1?? 10621??   76.8?    ***?
% Error??      2073??    15??   135????
% Factor?2??  11784??     4??  8196??   16.4?    ***
% Error??      4378??    60?    ?72.9????
% Interaction??2250??     4??   562??    6.52?   ***?
% Error??      5171??    60??    86.2????
% Subject: F(1,?15)?=?710,?p?<?.001)

% Analyzed using SPSS15:;
% Tests of Between-Subjects Effects
% Dependent Variable: X
% Source	 	Type III Sum of Squares	df      Mean Square	F	Sig.
% Intercept	Hypothesis	66283627.628	1       66283627.628	710.851	.000
%               Error	1398682.399     15  	93245.493(a)
% fx1	Hypothesis      10621.640       1       10621.640       76.829	.000
%       Error           2073.752    	15      138.250(b)
% fx2	Hypothesis      4784.064        4       1196.016        16.389	.000
%       Error           4378.604        60      72.977(c)
% Subject	Hypothesis	1398682.399 	15      93245.493       745.749	.000
%           Error       1314.799        10.515	125.036(d)
% fx1 * fx2	Hypothesis	2250.918        4   	562.729         6.529	.000
%           Error       5171.445    	60      86.191(e)
% fx1 * Subject	Hypothesis	2073.752	15      138.250         1.604	.100
%               Error       5171.445	60  	86.191(e)
% fx2 * Subject	Hypothesis	4378.604	60      72.977      	.847	.739
%               Error       5171.445	60      86.191(e)
% fx1*fx2*Subj	Hypothesis	5171.445	60      86.191          .       .
%               Error       .000        0       .(f)
% (a)	 MS(Subject)
% (b)	 MS(fx1 * Subject)
% (c)	 MS(fx2 * Subject)
% (d)	1.000 MS(fx1 * Subject) +  MS(fx2 * Subject) -  MS(fx1 * fx2 * Subject)
% (e)	 MS(fx1 * fx2 * Subject)
% (f)	 MS(Error)

% =========================================================================

%% Eysenck 1974 OLD/YOUNG
%
X=urlread('http://forrest.psych.unc.edu/research/vista-frames/help/lecturenotes/lecture10/eysenck.xli');
X= ['DATA "Eysenck" :TITLE "Eysenck" :ABOUT "Eysenck study of recall ability of subjects '...
    'who were young (Y - 18-30 years old) or old (O - 55-65 years old) for recall conditions ' ...
    'involving Counting, Rhyming, Adjectives, Imagery or Intentional. ' ...
    'From Howell, David C., (Ed. 3) p. 325." :VARIABLES (QUOTE ("Recall" "Age" "Condition")) :TYPES (QUOTE ("Numeric" "Category" "Category")) :LABELS (QUOTE ("Obs0" "Obs1" "Obs2" "Obs3" "Obs4" "Obs5" "Obs6" "Obs7" "Obs8" "Obs9" "Obs10" "Obs11" "Obs12" "Obs13" "Obs14" "Obs15" "Obs16" "Obs17" "Obs18" "Obs19" "Obs20" "Obs21" "Obs22" "Obs23" "Obs24" "Obs25" "Obs26" "Obs27" "Obs28" "Obs29" "Obs30" "Obs31" "Obs32" "Obs33" "Obs34" "Obs35" "Obs36" "Obs37" "Obs38" "Obs39" "Obs40" "Obs41" "Obs42" "Obs43" "Obs44" "Obs45" "Obs46" "Obs47" "Obs48" "Obs49" "Obs50" "Obs51" "Obs52" "Obs53" "Obs54" "Obs55" "Obs56" "Obs57" "Obs58" "Obs59" "Obs60" "Obs61" "Obs62" "Obs63" "Obs64" "Obs65" "Obs66" "Obs67" "Obs68" "Obs69" "Obs70" "Obs71" "Obs72" "Obs73" "Obs74" "Obs75" "Obs76" "Obs77" "Obs78" "Obs79" "Obs80" "Obs81" "Obs82" "Obs83" "Obs84" "Obs85" "Obs86" "Obs87" "Obs88" "Obs89" "Obs90" "Obs91" "Obs92" "Obs93" "Obs94" "Obs95" "Obs96" "Obs97" "Obs98" "Obs99")) :DATA (QUOTE (9 "O" "C" 8 "O" "C" 6 "O" "C" 8 "O" "C" 10 "O" "C" 4 "O" "C" 6 "O" "C" 5 "O" "C" 7 "O" "C" 7 "O" "C" 7 "O" "R" 9 "O" "R" 6 "O" "R" 6 "O" "R" 6 "O" "R" 11 "O" "R" 6 "O" "R" 3 "O" "R" 8 "O" "R" 7 "O" "R" 11 "O" "A" 13 "O" "A" 8 "O" "A" 6 "O" "A" 14 "O" "A" 11 "O" "A" 13 "O" "A" 13 "O" "A" 10 "O" "A" 11 "O" "A" 12 "O" "I" 11 "O" "I" 16 "O" "I" 11 "O" "I" 9 "O" "I" 23 "O" "I" 12 "O" "I" 10 "O" "I" 19 "O" "I" 11 "O" "I" 10 "O" "IN" 19 "O" "IN" 14 "O" "IN" 5 "O" "IN" 10 "O" "IN" 11 "O" "IN" 14 "O" "IN" 15 "O" "IN" 11 "O" "IN" 11 "O" "IN" 8 "Y" "C" 6 "Y" "C" 4 "Y" "C" 6 "Y" "C" 7 "Y" "C" 6 "Y" "C" 5 "Y" "C" 7 "Y" "C" 9 "Y" "C" 7 "Y" "C" 10 "Y" "R" 7 "Y" "R" 8 "Y" "R" 10 "Y" "R" 4 "Y" "R" 7 "Y" "R" 10 "Y" "R" 6 "Y" "R" 7 "Y" "R" 7 "Y" "R" 14 "Y" "A" 11 "Y" "A" 18 "Y" "A" 14 "Y" "A" 13 "Y" "A" 22 "Y" "A" 17 "Y" "A" 16 "Y" "A" 12 "Y" "A" 11 "Y" "A" 20 "Y" "I" 16 "Y" "I" 16 "Y" "I" 15 "Y" "I" 18 "Y" "I" 16 "Y" "I" 20 "Y" "I" 22 "Y" "I" 14 "Y" "I" 19 "Y" "I" 21 "Y" "IN" 19 "Y" "IN" 17 "Y" "IN" 15 "Y" "IN" 22 "Y" "IN" 16 "Y" "IN" 22 "Y" "IN" 22 "Y" "IN" 18 "Y" "IN" 21 "Y" "IN")) :DATASHEET-ARGUMENTS (QUOTE ((420 475) (511 120) 2 8)))'];
X=strread(X, '%s', 'delimiter', ' ');
X=X(160:3:end-8)
X{1}(1)=[];
X=str2num(strvcat(X));
X=reshape(X,10,5,2);
X=permute(X,[3 2 1]); % AGE x COND x SUBJ

% =========================================================================
%% Migraine Headache
% http://core.ecu.edu/psyc/wuenschk/SPSS/SPSS-Data.htm
X= [
    21	      22	       8	       6	       6
    20	      19	      10	       4	       9
    7	       5	       5	       4	       5
    25	      30	      13	      12	       4
    30	      33	      10	       8	       6
    19	      27	       8	       7	       4
    26	      16	       5	       2	       5
    13	       4	       8	       1	       5
    26	      24	      14	       8	      17
    ];
% =========================================================================
%% Howell Table 14.3
X= [
    21	      22	       8	       6	       6
    20	      19	      10	       4	       4
    17	      15	       5	       4	       5
    25	      30	      13	      12	       17
    30	      27	      13	       8	       6
    19	      27	       8	       7	       4
    26	      16	       5	       2	       5
    17	      18	       8	       1	       5
    26	      24	      14	       8	       9
    ];


% =========================================================================
%% Weight Training Data by Jorge L. Mendoza
% http://www.ou.edu/faculty/M/Jorge.L.Mendoza-1/psy5013/twoway-repeated.sas
% subj program$ s1 s2 s3 s4 s5 s6 s7;


% R
% datafilename="http://personality-project.org/r/datasets/R.appendix4.data"
% data.example4=read.table(datafilename,header=T)
% aov.ex4=aov(Recall~(Task*Valence)+Error(Subject/(Task*Valence)),data.ex
% summary(aov.ex4)
% Error: Subject
%           Df Sum Sq Mean Sq F value Pr(>F)
% Residuals  4 349.13   87.28
%
% Error: Subject:Task
%           Df  Sum Sq Mean Sq F value  Pr(>F)
% Task       1 30.0000 30.0000  7.3469 0.05351 .
% Residuals  4 16.3333  4.0833
% ---
% Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
%
% Error: Subject:Valence
%           Df  Sum Sq Mean Sq F value Pr(>F)
% Valence    2  9.8000  4.9000  1.4591 0.2883
% Residuals  8 26.8667  3.3583
%
% Error: Subject:Task:Valence
%              Df  Sum Sq Mean Sq F value Pr(>F)
% Task:Valence  2  1.4000  0.7000  0.2907 0.7553
% Residuals     8 19.2667  2.4083
%
% But to perform post-hoc we need to go through LME
% 
% require(MASS)
% require(nlme)
% require(multcomp)
% lme.ex4 <- lme(Recall ~ Task + Valence, random = ~1 | Subject/(Task*Valence), data = data.example4)


a= [ 8  9  5  7  9 10 12 13 14 16 13 14 13 13 12 15 16 14 12 14 15 17 18 20  6  7  9  4  9 10 ];
a = reshape(a,[3 2 5])
myanova(a,2,1:2);

%% http://blog.gribblelab.org/2009/03/09/repeated-measures-anova-using-r/
% > dv <- c(1,3,4,2,2,3,2,5,6,3,4,4,3,5,6)
% > subject <- factor(c("s1","s1","s1","s2","s2","s2","s3","s3","s3",
%   + "s4","s4","s4","s5","s5","s5"))
% > myfactor <- factor(c("f1","f2","f3","f1","f2","f3","f1","f2","f3",
%   + "f1","f2","f3","f1","f2","f3"))
% > mydata <- data.frame(dv, subject, myfactor)
%
% Error: subject
%           Df Sum Sq Mean Sq F value Pr(>F)
% Residuals  4   12.4     3.1               
% 
% Error: subject:myfactor
%           Df  Sum Sq Mean Sq F value   Pr(>F)   
% myfactor   2 14.9333  7.4667  13.576 0.002683 **
% Residuals  8  4.4000  0.5500
%
% > require(nlme)
% > am2 <- lme(dv ~ myfactor, random = ~1|subject/myfactor, data=mydata)
% > anova(am2)
%             numDF denDF  F-value p-value
% (Intercept)     1     8 60.40869  0.0001
% myfactor        2     8 13.57575  0.0027
% 
% > require(multcomp)
% > summary(glht(am2,linfct=mcp(myfactor="Tukey")))
% Linear Hypotheses:
%              Estimate Std. Error z value Pr(>|z|)
% f2 - f1 == 0    1.600      0.469   3.411  0.00185 **
% f3 - f1 == 0    2.400      0.469   5.117  < 1e-04 ***
% f3 - f2 == 0    0.800      0.469   1.706  0.20308
%
d = [
    1   1      1       1
    2   3      1       2
    3   4      1       3
    4   2      2       1
    5   2      2       2
    6   3      2       3
    7   2      3       1
    8   5      3       2
    9   6      3       3
    10  3      4       1
    11  4      4       2
    12  4      4       3
    13  3      5       1
    14  5      5       2
    15  6      5       3 ]
X = reshape(d(:,2),[ 3 5 ]);
[p,F,fx,epsilon,df,dfe,SS,SSe,SSt]=myanova(X,1,1)

%[Qc,HSDc] = tukeyhsd(dfe,ng,alpha,ns,MSe)


% [Qc,HSDc,Q,pairs,MX] = tukeyhsd(X,nf,alpha,fx,dfe,SSe)
[Qc,HSDc,Q,pairs,MX] = tukeyhsd(X,1,0.05)



%% [R] Tukey HSD (or other post hoc tests) following repeated measures ANOVA
%   https://stat.ethz.ch/pipermail/r-help/2008-May/163433.html
% 
% ## Example
% require(MASS)         ## for oats data set
% require(nlme)         ## for lme()
% require(multcomp)  ## for multiple comparison stuff
% 
% Aov.mod <- aov(Y ~ N + V + Error(B/V), data = oats)
% Lme.mod <- lme(Y ~ N + V, random = ~1 | B/V, data = oats)
% 
% summary(Aov.mod)
% anova(Lme.mod)
% 
% summary(Lme.mod)
% summary(glht(Lme.mod, linfct=mcp(V="Tukey")))
%
% E.g. with gribblelab data
% summary(glht(l, linfct=mcp(myfactor="Tukey")))


%% http://yatani.jp/HCIstats/PostHoc
% Post-hoc Tests
% > aov <- aov(Value ~ factor(Group) + Error(factor(Participant)/factor(Group)), data) 
% > summary(aov)
% Error: factor(Participant)
%           Df Sum Sq Mean Sq F value Pr(>F)
% Residuals  7 5.1667  0.7381               
% Error: factor(Participant):factor(Group)
%               Df  Sum Sq Mean Sq F value   Pr(>F)   
% factor(Group)  2 22.7500 11.3750   10.92 0.001388 **
% Residuals     14 14.5833  1.0417 
%

X =[ 1 2 4 1 1 2 2 3 3 4 4 2 3 4 4 3 4 5 3 5 5 3 4 6]
X = reshape(X,[8 5])';
myanova(X,1,1)

    


