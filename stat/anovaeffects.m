function [fx]=anovaeffects(nf,m)
% anovaeffects - List effects and their interaction in a factorial design
%   [fx]=anovaeffects(nf) 
%   List main effects and interaction(s) in factorial design with [nf] factors
%   [fx] is a N-by-1 cell array
%
%   [fx]=anovaeffects(nf,m) 
%   m: maximum number of interacting factors (default: 3)

fx={};
if nargin<2
    m=min(nf,3);
end
for i=1:m
    fx=[fx ; num2cell(nchoosek(1:nf,i),2)];
end
