function  = mvrnorm(input,varargin)
%MVRNORM - Robust Correlation by Rich Herrington
%   [] = mvrnorm(input)
%
%   Example
%       >> mvrnorm
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2009 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2009-10-13 Creation
%                   
% ----------------------------- Script History ---------------------------------

% Dealing with Outliers in Bivariate Data: Robust Correlation
% By Dr. Rich Herrington, Research and Statistical Support Consultant 
% 
% R script:
%
% # n=sample size
% # p=number of columns
% # u=mean of columns
% # s=standard deviation of columns
% # S=correlation matrix
% 
% mvrnorm <- function(n, p, u, s, S) {
% Z <- matrix(rnorm(n*p), p, n)
% t(u + s*t(chol(S))%*% Z)
% }
% 
% # Sample from Bivariate Normal
% 
% z<-mvrnorm(n=100, p=2, u=c(100,100), s=c(15,15), S=matrix(c(1, .4, .4, 1), ncol=2, nrow=2,byrow=T))
% 
% # Fit least squares regression
% 
% z.fit<-lm(z[,1]~z[,2])
% z.fit
% 
% # Plot scatterplot
% plot(z[,1], z[,2])
% 
% # Plot best fit line
% abline(z.fit)
% 
% # Calculate Pearson's Correlation
% cor(z[,1], z[,2])

if nargin<1
    error('No data!')
elseif nargin==1 || isnumeric(action)
    varargin=[{action} varargin ];
    action='init';
end

try
    varargout={eval(sprintf('action_%s(varargin{:});',action))};
catch
    eval(sprintf('action_%s(varargin{:});',action)); 
end


function [ha]=action_init(data, varargin)
% -------------------------------------------------------------------------
% Check OPTIONS and default values when optional arguments are not
% specified
Def_OPTIONS = struct(...
    'option1',[],...
    );
if nargin < 2
    OPTIONS = Def_OPTIONS;
else
    if length(varargin)>1 
        OPTIONS = cell2struct(varargin(2:2:end),varargin(1:2:end),2); 
        % struct(varargin{:}) bugs with something like {'string1' 'string2'} in the inputs!
    else        
        OPTIONS = varargin{1};
    end 
    % Check field names of passed OPTIONS and fill missing ones with default values
    DefFieldNames = fieldnames(Def_OPTIONS);
    for k = 1:length(DefFieldNames)
        if ~isfield(OPTIONS,DefFieldNames{k})
            OPTIONS = setfield(OPTIONS,DefFieldNames{k},getfield(Def_OPTIONS,DefFieldNames{k}));
        end
    end
    clear DefFieldNames
end
clear Def_OPTIONS
% -------------------------------------------------------------------------