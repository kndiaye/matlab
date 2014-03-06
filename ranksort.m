function [r,S]=ranksort(X,varargin)
%ranksort - rank of each element in a set
%   [r]=ranksort(X,dim)
%   
%
[S,Y]=sort(X,varargin{:});
[ign,r]=sort(Y, varargin{:});
