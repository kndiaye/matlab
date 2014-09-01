function [staircase] = UpdateStaircase(staircase,xnew,snew,dnew)

if nargin < 4
    error('Missing input argument(s).');
end

staircase = RefreshStaircase(staircase);
staircase.j = staircase.i-1;

if ~isempty(xnew)
    staircase.x(staircase.i) = xnew;
end
if ~isempty(snew)
    staircase.scur = snew;
end
if ~isempty(dnew)
    staircase.dcur = dnew;
end

end