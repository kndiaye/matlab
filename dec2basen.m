function s = dec2basen(d,b)
%DEC2BASEN Convert decimal integer to base B *number*.
%   DEC2BASEN(D,B) returns the representation of D as a string in
%   base B.  D must be a non-negative integer array smaller than 2^52
%   and B must be an integer > 1.
%
%   Examples
%       dec2basen(23,3) returns [2 1 2]
%
%   See also DEC2BASE

% Original by Douglas M. Schwarz, Eastman Kodak Company, 1996.
% Modified (actually cut through !) by Karim N'Diaye, 2005

d = d(:);
if any(d ~= floor(d)) || any(d < 0) || any(d > 1/eps)
   error('KND:dec2basen:FirstArg', 'D must be an array of integers, 0 <= D <= 2^52.');
end
if numel(b)~=1 || b ~= floor(b) || b < 2
   error('KND:dec2basen:SecondArg', 'B must be an integer > 1');
end
d = double(d);
b = double(b);
n = max(1,round(log2(max(d)+1)/log2(b)));
while any(b.^n <= d)
   n = n + 1;
end
s(:,n) = rem(d,b);
while n > 1 & any(d)
   n = n - 1;
   d = floor(d/b);
   s(:,n) = rem(d,b);
end
