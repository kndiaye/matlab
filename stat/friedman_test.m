function [p,F,fx,epsilon,df,dfe,SS,SSe,SSt,Y]=friedman_test(X,nf,rp)
% friedman_test - Friedman's Test: N-way non-parametric ANOVA (using ranks)
%   [p,F,fx]=friedman_test(X,nf)
%   X should be [Factor1 x Factor2 x ... x Subjects x ...]
%   nf is the number of factors
%   rp is the list of within-subject factors
%
%   [p,F,fx,epsilon,df,dfe,SS,SSe,SSt,Y]=friedman_test(...)
%   ouputs data from myanova and Y, the rank matrix
%
% See also: myanova
% Uses: myanova, tiedrank
if nargin<3
    rp=[];
end
if not(isempty(rp)) & ~all(ismember(1:nf, rp))
    error('Cannot deal with split-plot (ie. mixed) designs')
end
% This test is an ANOVA on the rank
sX=size(X);
ng=sX(1:nf);  % nb of groups in each factor
png=prod(ng); % nb of cells
if isempty(rp)
    %data are ranked across subjects
    X=reshape(X,png*sX(nf+1),[]);
else
    %data are ranked within subjects
    X=reshape(X,png,[]);
end
Y=tiedrank(X);
Y=reshape(Y,sX);
if nargout>3
    [p,F,fx,epsilon,df,dfe,SS,SSe,SSt]=myanova(Y,nf,rp);
else
    [p,F,fx]=myanova(Y,nf,rp);
end
return

%% This example is in the SAS Sample library.
% TEST DATA:
% http://www.biostat.wustl.edu/archives/html/jmp-l/1995/msg00168.html
%   columns: TREATMENT, 4-level within
%   rows: SUBJECTS N=6
X =[32.6 36.4 29.5 29.4 ;
    42.7 47.1 32.9 40.2 ;
    35.3 40.1 33.6 35   ;
    35.2 40.3 35.7 40   ;
    33.2 34.3 33.2 34   ;
    33.1 34.4 33.1 34.1 ]';
% WARNING : the following does not used tied ranks!
% so tweak the data an epsilon bit...
X(1,5)=X(1,5)-1e-10;
X(1,6)=X(1,6)-1e-10;
friedman_test(X,1,1)
% Results :
% Response: Rank within Block
% Effect Test
% Source    Nparm   DF  Sum of Squares  F Ratio Prob>F
% BLOCK     5       5   0.000000        0.0000  1.0000
% TRTMENT   3       3   19.333333       9.0625  0.0011
%
% Step 4:
% TO CALCULATE THE CHI-SQUARE,
% MULTIPLY THE SUM-OF-SQUARES FOR TREATMENT BY
% 12/((T*(T+1)) WHERE T IS THE NUMBER OF TREATMENTS.



%% Example from ZAR, p. 265
X=[ 7.0 5.3 4.9 8.8
    9.9 5.7 7.6 8.9
    8.5 4.7 5.5 8.1
    5.1 3.5 2.8 3.3
    10.3 7.7 8.4 9.1];

% Cousineau 2005; TQPM
% Simulated data of a 2-by-5 exp with 16 subjects
X=str2num(urlread('http://www.tqmp.org/Content/vol01-1/p042/p042.dat'));
X=reshape(X(:,end),[16,5,2]);
X=permute(X,[3 2 1]);
p=myanova(X,2,1:2)
% all the variances are homogeneous and spherical, Tabachnik & Fidell, 1996
% Mauchly s W = 0.74, p > .50 for factor 2
% and W = 0.68, p > .50 for the interaction;


%% Avec R
%% http://www.r-statistics.com/2010/02/post-hoc-analysis-for-friedmans-test-r-code/ 
X=[5.40, 5.50, 5.55,
    5.85, 5.70, 5.75,
    5.20, 5.60, 5.50,
    5.55, 5.50, 5.40,
    5.90, 5.85, 5.70,
    5.45, 5.55, 5.60,
    5.40, 5.40, 5.35,
    5.45, 5.50, 5.35,
    5.25, 5.15, 5.00,
    5.85, 5.80, 5.70,
    5.25, 5.20, 5.10,
    5.65, 5.55, 5.45,
    5.60, 5.35, 5.45,
    5.05, 5.00, 4.95,
    5.50, 5.50, 5.40,
    5.45, 5.55, 5.50,
    5.55, 5.55, 5.35,
    5.45, 5.50, 5.55,
    5.50, 5.45, 5.25,
    5.65, 5.60, 5.40,
    5.70, 5.65, 5.55,
    6.30, 6.30, 6.25]