function  [x]=overlap(S,s2)
% overlap - return the overlap between two segments
%
%   [x]=overlap(s1,s2)
%   Computes the overlap x=[a b] between the two (closed) segments.
%   s1 and s2 MUST be real numbers.
%
%   [x]=overlap(S)
%   If S is a N-by-2 matrix, computes the global overlap of these N
%   segments.
%
%   x may be empty if s1 and s2 have no overlap, equals to [a a] if their
%   overlap is a single point, or equals to the smaller of s1 and s2 if one
%   includes the other.
%
%INPUTS:
%   s1=[a1 b1], s2=[a2 b2] are two numerical segment (of real numbers)
%
if nargin<2
    s2=[];
end
if any(~isreal([S(:) ; s2(:)]))
    error('s1 and s2 must be real numbers')
end
if nargin>1 & isempty(s2)
    x=[];
    return
end
if isempty(S)
    x=[];
    return
end
S=[S;s2];

if size(S,1)>2
    x=overlap(S(1,:), overlap(S(2:end,:)));
else
    if S(1)>S(4) | S(3)<S(2)
        x=[];
        return
    end
    x=[max(S(1:2)) min(S(3:4))];
end
return