function [varargout] = nic_spm_explorer(input,varargin)
%NIC_SPM_EXPLORER - SPM results explorer
%   [] = nic_spm_explorer() will open a new window asking for a SPM file
% 
%
%   [] = nic_spm_explorer(SPM)
%   [] = nic_spm_explorer('/some/path/SPM.mat')
%   [] = nic_spm_explorer('/some/path/SPM.mat','option1', value1, ...)
%   [] = nic_spm_explorer('/some/path/SPM.mat','option1', value1, ...)
%
%   Example
%       >> nic_spm_explorer
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2008 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2008-10-16 Creation
%                   
% ----------------------------- Script History ---------------------------------

% TO DO
% Everything! based on  xjview.m  plus:
% - no conflict with the spm_figure (Graphics) window
% - yoke windows "à la" MRICro(n)
% - remove uicontrol for cleaner export via "copy figure" 
% - 

if nargin<1
    action='start';
elseif nargin==1 || isnumeric(action)
    varargin=[{action} varargin ];
    action='start';
end

% equivalent to
varargout={eval(sprintf('action_%s(varargin{:});',action))};

%% ACTION CALLS ===========================================================

function [hf]=action_start(varargin)
OPTIONS = load_options(varargin)


%% PRIVATE FUNCTIONS ======================================================
%
function OPTIONS=load_options(varargin)
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
return; % load_options
% -------------------------------------------------------------------------