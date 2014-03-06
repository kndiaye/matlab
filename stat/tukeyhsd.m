function [Qc,HSDc,Q,pairs,X] = tukeyhsd(varargin)
%TUKEYHSD - Performs Tukey Honnestly Significant Differences Test
%   [Qc] = tukeyhsd(dfe,ng,alpha)
%   Qc: critical Q of the Studentized range statistic for the number of
%       freedom (df), the number of groups (ng) at the level: p<alpha
%       All groups must have equal df. 
%
%   [Qc,HSDc] = tukeyhsd(dfe,ng,alpha,ns,MSe)
%   Qc: (same as above)
%   HSDc: Critical difference between means to be considered significant
%
%   tukeyhsd() an also be used directly with the data:
%   [Qc,HSDc,Q,pairs,MX] = tukeyhsd(X,nf,alpha)
%   [Qc,HSDc,Q,pairs,MX] = tukeyhsd(X,nf,alpha,fx)
%   [Qc,HSDc,Q,pairs,MX] = tukeyhsd(X,nf,alpha,fx,dfe,SSe)
%   Performs Tujey's tests on matrix-data using the myanova data format:
%       X: [... nf factors ....] x [subjects]
%       fx: a vector array of within subject factors
%   Output:
%       pairs: list of all pairwise comparisons
%       Q: Q-value for each pair
%       MX: 
%
%   Example
%       >> tukeyhsd
%
%   See also:

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND   2006-02-15 Creation
% KND   2007-10-25 Argument order changed
%
% ----------------------------- Script History ---------------------------------

dfmax=120;
if nargin==2
    dfe=varargin{1};
    ng=varargin{2};
    alpha = 0.05;
elseif nargin==3
    dfe=varargin{1};
    ng=varargin{2};
    alpha=varargin{3};
elseif nargin==5
    dfe=varargin{1};
    ng=varargin{2};
    alpha=varargin{3};
    ns=varargin{4};
    MSe=varargin{5};
else
    error
    X=varargin{1};
    nf=varargin{2};
    fx=varargin{3};
    alpha=varargin{4};   
    dfe=varargin{5};
    SSe=varargin{6};
    sx=size(X);
    %number of cells in the effect
    ng=prod(sx(fx));
    % number of subjects
    ns=prod(sx(setdiff(1:nf+1, fx)));
    MSe=SSe/dfe;
end
if dfe > dfmax;
    error('Too many d.o.f.')
end
% A little math...
t = sqrt(2)*erfinv(1-alpha);
c=[0.89,0.237,1.214,1.21,1.414];
t=t+(t^3+t)/dfe/4;
q=c(1)-c(2)*t;
q=q-c(3)/dfe+c(4)*t/dfe;
Qc=t*(q*log(ng-1)+c(5));
if nargout<=1
    return
end
HSDc=Qc*sqrt(MSe*1/ns);
if nargout<=2
    return
end
X=permute(X,[fx setdiff(1:ndims(X), fx)]);
X=reshape(X,[ng ns nf+2:length(sx) ]);
pairs=nchoosek(1:ng,2)';
X=reshape(mean(X(pairs(:),:,:),2),size(pairs));
Q=diff(X)./sqrt(SSe./dfe./ns);
return




return
% Sample dataset:
% http://web.mst.edu/~psyworld/anovaexample.htm
%Problem: Susan Sound predicts that students will learn most effectively
%with a constant background sound, as opposed to an unpredictable sound or
%no sound at all. She randomly divides twenty-four students into three
%groups of eight. All students study a passage of text for 30 minutes.
%Those in group 1 study with background sound at a constant volume in the
%background. Those in group 2 study with noise that changes volume
%periodically. Those in group 3 study with no sound at all. After studying,
%all students take a 10 point multiple choice test over the material. Their
%scores follow:
%   x1  x1^2    x2  x2^2    x3  x3^2
x=[
    7    49     5    25     2     4
    4    16     5    25     4    16
    6    36     3     9     7    49
    8    64     4    16     1     1
    6    36     4    16     2     4
    6    36     7    49     1     1
    2     4     2     4     5    25
    9    81     2     4     5    25
    ];

% SStotal = 117.96
% SSamong = 30.08
% SSwithin = 117.96 - 30.08 = 87.88
% according to the F sig/probability table with df = (2,21) F must be at
% least 3.4668 to reach p < .05, so F score is statistically significant)

x=x(:,1:2:end);
x=transpose(x);
x=[
    7  	4  	6  	8  	6  	6  	2  	9 % 1) constant sound
    5 	5 	3 	4 	4 	7 	2 	2 % 2) random sound
    2 	4 	7 	1 	2 	1 	5 	5 % 3) no sound
    ];

% One way between subject epsilon=1
[p,F,fx,e,df,dfe,SS,SSe,SSt]=myanova(x,1,[],1)
% F=3.5946 -> p=0.0454
% MSe=SSe/dfe = 4.18
% Q= diff(mean(x))./sqrt(MSe*1/nr)
% mean(x(1,:))-mean(x(2,:))/.72=-2.7
% mean(x(1,:))-mean(x(3,:))/.72=4.15
% mean(x(3,:))-mean(x(2,:))/.72=1.38
pairs=nchoosek(1:3,2)';
diff(reshape(mean(x(pairs(:),:),2),[2 3]))./sqrt(SSe/dfe*1/size(x,2))
qtukey(dfe,3,0.95)
% there is an error on this page!
% Mean of column 3 is 3.375 not 3!
% i wrote to the webmaster



% http://facultyvassar.edu/lowry/ch14pt2.html
x =[
   27.0000   26.2000   28.8000   33.5000   28.8000
   22.8000   23.1000   27.7000   27.6000   24.0000
   21.9000   23.4000   20.1000   27.8000   19.3000
   23.5000   19.6000   23.7000   20.8000   23.9000
];
% Line("groups") means:
% Ma=28.86 	Mb=25.04 	Mc=22.50 	Md=22.30 

% Sources                     SS    df  	MS      F       P 
% between groups ("effect") 140.10   3  46.70    6.42	<.01
% within groups ("error") 	116.32  16	7.27    
%   TOTAL                   256.42	19
%
% a versus b :
% Q = (28.86—25.04) / sqrt(7.27 / 5) = 3.16
% For the present example, with k=4 and dfwg=16, you will end up with
% Q[.05] = 4.05 and Q[.01] = 5.2.

% 	HSD[.05] = 	Q[.05] x sqrt(MSwg / Nps)
%            = 4.05 * sqrt(7.275 / 5)
%            = 4.88
%   HSD[.01] = 6.27
% M[A-B] = 3.82 ;
% M[A-C] = 6.36
% M[A-D] = 6.56 etc.
% As you can see, two of the comparisons (A·C and A·D) are significant
% beyond the .01 level, while all the others fail to achieve significance
% even at the basic .05 level

% eta2 = SSbg / SST = 140.10 / 256.42 = 0.55
