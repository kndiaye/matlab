function [y]=stdnan(x,flag,dim)
%stdnan -  Standard deviation once NaN values have been removed
%   
% see std() for details

%   For vectors, MEAN(X) is the mean value of the elements in X. For
%   matrices, MEAN(X) is a row vector containing the mean value of
%   each column.  For N-D arrays, MEAN(X) is the mean value of the
%   elements along the first non-singleton dimension of X.
%
%   MEAN(X,DIM) takes the mean along the dimension DIM of X. 
%
%   Example: If X = [0 1 2
%                    3 4 5]
%
%   then mean(X,1) is [1.5 2.5 3.5] and mean(X,2) is [1
%                                                     4]
%
%   See also MEDIAN, STD, MIN, MAX, COV.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.17 $  $Date: 2002/06/05 17:06:39 $

if nargin < 2
    flag=0;
end
if nargin < 3
    dim=1;
end
x=permute(x, [dim 1:dim-1 dim+1:ndims(x)]);

if size(x,dim)==1, 
   y = zeros(size(x)); 
   y(isnan(x))=NaN; 
   return
end


% tile = ones(1,max(ndims(x),dim));

t1 = [ size(x, 1) 1 ];
t2 = [ 1 size(x, 2) ];

xn = x;
nn=sum(isnan(x));
xn(isnan(xn))=0;
sx=size(x,1)-nn;

xc = x - repmat(sum(xn),t1)./repmat((sx),t1);  % Remove mean
xc(isnan(xc))=0;

if flag,
  y = sqrt(sum(conj(xn).*xc)./(sx));
else
  y = sqrt(sum(conj(xc).*xc)./(sx-1));
end
if dim>1
    y=permute(y, [2:dim 1 dim+1:ndims(x)]);
end

return
sx=size(x);



if 0
  % Determine which dimension SUM will use
  if ndims(x)>1
      error('stdnan: You have to specifiy the dimension on which stdnan operate!')
  end
  % dim = min(find(size(x)~=1));
  % if isempty(dim), dim = 1; end      
  x(find(isnan(x)))=[];
  y = sum(x)/size(x);
else
  k=find(isnan(x));
  kk=zeros(size(x));
  kk(k)=1;
  x(k)=0;
  y = sum(x,dim)./(size(x,dim)-sum(kk,dim));
end
