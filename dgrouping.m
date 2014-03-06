function [I,nl,F] = dgrouping(G,S)
% dgrouping() - Get indices of data elements using grouping variable in multidimension (myanova)
%
%       [I,NL,F] = dgrouping(G)
%
%       G is a grouping variable with as many colunms (N) as there are
%       factors in the design and as many unique elements per column as
%       they are levels in the corresponding factor.
%       G must represent BALANCED data across levels in each factor.
%       I are the indices of the data in a N-dimensional array (one
%       dimension per factor)
%       NL : number of levels in each factor (size of reshaped data)
%       F are the factors
%
% See also: myanova

if prod(G)==max(size(G)),G=G(:);end
% number of factors
nf=size(G,2);
% total number of elements (inc. replications)
ne=size(G,1);
% output indices
I=zeros(ne,1);
% number of cells in the design
nc=1;

% if length(unique(G, 'rows'))<ne
%     error('G should not contain replicates')
% end

for i=1:nf    
    [F{i},ig{i},g{1,i}]=unique(G(:,i));
    % F:        lists the levels in each factor
    % ig{i}(j): indices of one the occurences of the j-th level for factor i in the array
    % g{i}(k):  in which level of factor i belong the k-th element in data
    % number of levels in the factor
    nl(i)=length(F{i});
    % number of cells is increased
    nc=nc*nl(i);
end
    
if nc==ne
    % There are no replicates...
    I=sub2ind(nl,g{:});
    return
end
% Number of replicates
nr=0;
for i=1:nc
    j=ind2sub2(nl,i);
    nr=max(nr,sum(all(repmat(j,[ne,1])==G,2)));
end
nl=[nl nr];
for i=1:nf
    if i==1
        I=I+g{i};
    else
        I=I+prod(nl(1:i-1))*(g{i}-1);
    end
end
% accounts for replicates in indices
for i=1:nc
    I=I+(cumsum(I==i)-1).*(I==i)*nc;
end

return

