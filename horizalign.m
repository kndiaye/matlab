function [s]=horizalign(s,FLAG)
% horizalign - NOT WORKING !!! Horizontal Alignment of a char array



error('')

% [s]=horizalign(s,FLAG)
% FLAG: -1 for left alignment, +1 for right, 0: centered [default:-1]
if nargin<2
    FLAG=-1;
end
if ~isequal(FLAG,1) & ~isequal(FLAG,-1) & ~isequal(FLAG,0)
    error('FLAG should be -1 or +1')
end

% 


m=

for i=1:size(s,1)
    k=strfind(s(1,:), ' ')
    
    z=find(diff(k)>1)
    if ~isempty(z) | 
        s(i,:)=circshift(s(i,:), [0 FLAG*(z(1))]);
    end
end

