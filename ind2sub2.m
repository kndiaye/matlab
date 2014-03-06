function varargout = ind2sub(siz,ndx)
%IND2SUB2 - Multiple subscripts from linear index.
%   IND2SUB2 is used to determine the equivalent subscript values
%   corresponding to a given single index into an array.
%   It is an extension of the native IND2SUB (R14) as it returns a
%   multicolumn matrix of subscripts S, each column being a dimension. 
%       S =[ I1 I2 ... In ]
%   when a single output is asked for.
%
%   [I,J] = IND2SUB(SIZ,IND) returns the arrays I and J containing the
%   equivalent row and column subscripts corresponding to the index
%   matrix IND for a matrix of size SIZ.  
%   For matrices, [I,J] = IND2SUB(SIZE(A),FIND(A>5)) returns the same
%   values as [I,J] = FIND(A>5).
%
%   [I1,I2,I3,...,In] = IND2SUB(SIZ,IND) returns N subscript arrays
%   I1,I2,..,In containing the equivalent N-D array subscripts
%   equivalent to IND for an array of size SIZ.
%
%   See also SUB2IND, FIND.
 
%   Copyright 1984-2000 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2000/06/01 16:46:44 $

siz=siz(:)';
nout = max(nargout,1);
if nout==1
    % do nothing
elseif length(siz)<=nout,
  siz = [siz ones(1,nout-length(siz))];
else
  siz = [siz(1:nout-1) prod(siz(nout:end))];
end
n = length(siz);
k = [1 cumprod(siz(1:end-1))];
ndx = ndx(:) - 1;
for i = n:-1:1,
    if nout<=1
        if i==n
            vout{1}=NaN*zeros(length(ndx), n);
        end
        vout{1}(1:length(ndx),i) = floor(ndx./k(i))+1;
    else
        vout{i} = floor(ndx./k(i))+1;
    end
  ndx = rem(ndx,k(i));
end

varargout=vout;