function [I,D] = closest(A,B) % deprecated
% DEPRECATED. See: nearest

% closest - Closest points between two sets 
%           (N-dimension euclidian distance)
%
%   [I,D] = closest(A,B)
%
% INPUTS:
%    A - MxD matrix (M=number of points, D=number of dimensions)
%    B - NxD matrix (N=number of points, D=number of dimensions)
% OUTPUTS:
%    I - Mx1 vector of indices of B's closest to each A's
%    D - Mx1 vector of euclidian distances
error