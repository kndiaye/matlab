function [x] = GetStaircaseVariable(staircase)

if nargin < 1, error('Not enough input arguments.'); end

x = staircase.x(staircase.i);

end
