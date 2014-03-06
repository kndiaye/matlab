function z = rotatelr(A,p)
%March 25, 1997, Herman Gollwitzer, hgollwit@mcs.drexel.edu
%Purpose: Rotate circularly the rows of A left or right according
%	as the integers in p are positive or negative, respectively.
%Inputs:	A matrix whose rows are to rotated.
%					p vector of integers indicating the amount of rotation
%						for each row individually.
%Usage
%»a =
%     1     4     7    10    13
%     2     5     8    11    14
%     3     6     9    12    15
%»twistlr(a,[-1 0 1])
%    13     1     4     7    10
%     2     5     8    11    14
%     6     9    12    15     3
if nargin < 2
	error('Needs two arguments');
elseif (ndims(A) > 2)
	error('Only matrices are accepted');
end
doRows = 1;
[m,n] = size(A);
p = p(:)';
if size(p,2) ~= m
	error([num2str(m),' shifts are required.']);
elseif any(p ~= round(p))
	error('Integer-valued shifts are required.');
end
z = twist(A,p,doRows);
