function z = rotateud(A,p)
%March 25, 1997, Herman Gollwitzer, hgollwit@mcs.drexel.edu
%Purpose: Rotate circularly the columns of A up or down according
%	as the integers in p are positive or negative, respectively.
%Inputs:	A matrix whose columns are to rotated.
%					p vector of integers indicating the amount of rotation
%						for each column individually.
%Usage
%»a =
%     1     4     7    10    13
%     2     5     8    11    14
%     3     6     9    12    15
%twistud(a,[1 0 0 0 -1])
%     2     4     7    10    15
%     3     5     8    11    13
%     1     6     9    12    14
if nargin < 2
	error('Needs two arguments');
elseif (ndims(A) > 2)
	error('Only matrices are accepted');
end
doColumns = 0;
[m,n] = size(A);
p = p(:)';
if size(p,2) ~= n
	error([num2str(n),' shifts are required.']);
elseif any(p ~= round(p))
	error('Integer-valued shifts are required.');
end
z = twist(A,p,doColumns);
