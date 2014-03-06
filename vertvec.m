function [X]=vertvec(X)
% vertvec - make array X into one column, same as X(:)
%   [Y]=vertvec(X) is equivalent to Y=X(:)

X=X(:);

%see: vec() in BrainStorm