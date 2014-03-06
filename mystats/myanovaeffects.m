function [fx]=myanovaeffects(nf,factornames)
% myanovaeffects - List effects and their interaction in a factorial design
%   [fx]=myanovaeffects(nf) 
%   List main effects and interaction(s) in factorial design with [nf] factors
%   [fx] is a N-by-1 cell array
%
%   [fx]=myanovaeffects(nf,factornames) 
%    Makes up a cell list of char listing instead of the factor index,
%    their names according to factornames.
%    Example:
%       >> myanovaeffects(2, {'FACTOR1','FACTOR2'})
%          outputs:  { 'FACTOR1'  'FACTOR2'  'FACTOR1*FACTOR2' } 
%
%   See also: myanova
fx={};
for i=1:nf
    fx=[fx ; num2cell(nchoosek(1:nf,i),2)];
end
if nargin>1
    for i=1:length(fx)
        fxn{i,1}=factornames{fx{i}(1)};
        for j=2:length(fx{i})
            fxn{i,1}=[ fxn{i} '*' factornames{fx{i}(j)}];       
        end
    end
    fx=fxn;
end