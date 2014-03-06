function [I,D,DD] = nearest(A,B)
% nearest - nearest points between two sets 
%           (N-dimension euclidian distance)
%
%   [I,D,DD] = nearest(A,B)
%
% INPUTS:
%    A - MxD matrix (M=number of points, D=number of dimensions)
%    B - NxD matrix (N=number of points, D=number of dimensions)
% OUTPUTS:
%    I - Mx1 vector of indices of B's nearest to each A's
%    D - Mx1 vector of euclidian distances
%    DD - MxN matrix of euclidian distances


% Compilation: 
% mex -v -g nearest.c