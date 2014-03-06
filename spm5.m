function [spmpath]=spm5(varargin)
% spm2() - starts SPM5 on Karim's computers
spmpath = myspm('ver','spm5','do','run', varargin{:});
