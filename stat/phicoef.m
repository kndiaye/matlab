function [phi]=phicoef(C)
%phicoef - (Pearson's) Phi coefficient (correlation for binary data)
%
%   [phi]=phicoef(C) computes phi for a contingeny matrix C
%
% KND, 2011

if ~isequal(size(C),[2 2])
    error
end
c1 = sum(C,1);
c2 = sum(C,2);
phi = det(C)/sqrt(prod([c1 c2']));
