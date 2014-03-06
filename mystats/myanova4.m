function [p,F,fx,pomega2,peta2]=myanova4(X,varargin)
% Effect sizes for anova
%cf. http://psyphz.psych.wisc.edu/~shackman/olejnik_PsychMeth2003.pdf
% http://www.psy.ohio-state.edu/visionlab/lore/827/lab5_07.pdf


[p,F,fx,epsilon,df,dfe,SS,SSe,SSt]=myanova(X,varargin{:});

eta2=SS./SSt
peta2=SS./(SSe+SS)
MSe=(SSe./dfe);
N=prod(size(X))./(df+1);
%omega2=
pomega2=(SS-df.*MSe)./(SSe+(N-dfe).*MSe)

% MS=SS./df
% theta2=dfe*(MS-MSe)./prod(size(X))
% theta2/(theta2+MSe)

return

%  http://www.ats.ucla.edu/stat/stata/faq/crf24
%  http://www.ats.ucla.edu/stat/stata/faq/omega2.htm
y=[
    3 1 1
4 1 2
7 1 3
7 1 4
1 2 1
2 2 2
5 2 3
10 2 4
6 1 1
5 1 2
8 1 3
8 1 4
2 2 1
3 2 2
6 2 3
10 2 4
3 1 1
4 1 2
7 1 3
9 1 4
2 2 1
4 2 2
5 2 3
9 2 4
3 1 1
3 1 2
6 1 3
8 1 4
2 2 1
3 2 2
6 2 3
11 2 4];
y=reshape(y(:,1),4,2,4)