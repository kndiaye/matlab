% pseudotvalue - Pseudo T-value(s) between two samples (regularization of sample variance)
%                   
%   [T] = pseudotvalue(A,B,W)
%       Computes a pseudo T-value between the two samples A and B where the
%       variance in the denominator is smoothed by matrix W  
% INPUTS:
% A - MxK matrix (M=number of observations in the 1st sample, K=number of measures)
% B - NxK matrix (N=number of observations in the 2nd sample, K=number of measures)
% W - KxK matrix (may be sparse) applied to the variance
% OUTPUTS:
% T - 1xK vector of T-values
%
% Author: Karim(s) Jerbi & N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2006 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2006-01-06 Creation of pseudotvalue.c & its helper pseudotvalue.m
%                   
% ----------------------------- Script History ---------------------------------
