function  = $filename(input,varargin)
%$FILENAME - One line description goes here.
%   [] = $filename(input)
%
%   Example
%       >> $filename
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>gmail.com)
% Copyright (C) $date(yyyy) 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  $date(yyyy-mm-dd) Creation
%                   
% ----------------------------- Script History ---------------------------------

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
