function [r,ta]=tiedrank(X,dim)
%tiedrank - Tied rank of each element in a set
%   [r]=tiedrank(X,dim)
%   Computes tied rank of each element of X along given dimension 
%   (default is to use the first non-singleton dimension) 
%   "Tied ranking" is such that ex-aequo elements share the same (possibly
%   half) rank:  
%       >> tiedrank(['DABBC']) %-> 6 1 2.5 2.5 4
if nargin<2
    dim=min(find(size(X)>1));
    if isempty(dim)
        error('X is empty!')
    end
end
[ignore,Y]=sort(X,dim);
[ignore,r1]=sort(Y,dim);
[ignore,Y]=sort(-X,dim);
[ignore,r2]=sort(Y,dim);
r2=size(X,dim)-r2+1;
r=(r1+r2)/2;
if nargout > 1
    warning('Tier adjustments not computed yet!');
    
    % Tie adjustment...
    ta=0;
end
