function [v]=whichRank(x,b,n,backward)
% whichRank - get the n-th "pseudo-bit" of a number x in pseudo-base b (little-endian)
%
%    [v]=whichRank(x,b,[n], [backward])
% 
% Ex. 
%     >> for i=1:3, for j=1:7, for k=1:5, x=[x, ...], end, end, end
%     if you want to know at which rank in "j" (the 2nd loop index) 
%     the, say, 12-th value in x corresponds:
%     >> whichrank(12, [3 7 5], 2)  
%         returns:  3
%
% Cool, isn't it?
%
% [n] is optional, if not given, the whole list is output
%     >> whichrank(1, [3 7 5])  ->  [1 1 1] that is i=1, j=1, k=1
%     >> whichrank(51,[3 7 5])  ->  [2 4 1] that is i=2, j=4, k=1
% 
% [backward] is 0 [default] or 1. In the latter case, treat b as the
% last loops of some upper unspecified loops. 
% i.e. "the heaviest pseudo-bits are discarded":
%     >> for i=1:???, ..., for j=1:7, for k=1:5 ... end
%     >> whichrank(12, [ 6 4 7 5 ], 2, 1) 
%         returns : 3 (whatever the loops in '?') 


if nargin<4 
  backward=0;
end
if nargin<3
  n=[];
end

if not(backward)
  if x < 1 | x > prod(b)
    error([mfilename ': impossible x input according to the loops b' ]) 
  end
else
  n=length(b)-n+1;
end


k=fliplr(1./cumprod([1 b(end:-1:2)]));
x=floor((x-1)*k);
v=rem(x,b)+1;

if not(isempty(n))
  if n>length(b) | n<1 
    error(sprintf('%s: asked rank (n=%d) beyond the number of loops', ...
		  mfilename,n))
  end
  v=v(n);
end

return 


v=rem(x,b(n))+1;
return
k=floor(x/k)-1
v=rem(k,b(n))+1;
return

