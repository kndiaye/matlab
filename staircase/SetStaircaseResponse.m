function [staircase] = SetStaircaseResponse(staircase,x,r)

if nargin < 3
    error('Missing input argument(s).');
end

staircase.x(staircase.i) = x;
staircase.r(staircase.i) = r;

end