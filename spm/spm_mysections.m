function  spm_mysections(input,varargin)
%SPM_MYSECTIONS - Display views
%   [] = spm_mysections(input)
%
%   Example
%       >> spm_mysections
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
% KND  2009-07-03 Creation
%                   
% ----------------------------- Script History ---------------------------------

function spm_mysections(SPM,,hReg)
% rendering of regional effects [SPM{Z}] on orthogonal sections of
% colin27's brain
% FORMAT spm_sections(SPM,hReg)
%
% SPM  - xSPM structure containing details of excursion set
% hReg - handle of MIP register
%
% see spm_getSPM for details
%_______________________________________________________________________
%
% spm_sections is called by spm_results and uses variables in SPM and
% VOL to create three orthogonal sections though a background image.
% Regional foci from the selected SPM are rendered on this image.
%
%_______________________________________________________________________
% @(#)spm_sections.m	2.14	John Ashburner 02/09/05

Fgraph = spm_figure('FindWin','Graphics');
if isempty(Fgraph)
    Fgraph = spm_figure('Create','Graphics');
end
%spms   = spm_get(1,'IMAGE','select image for rendering on');
spms = fullfile(spm('dir'), 'canonical', 'single_subj_T1.nii');
if ~exist(spms)
    spms = fullfile(spm('dir'), 'canonical', 'single_subj_T1.mnc');
end

spm_results_ui('Clear',Fgraph);
spm_orthviews('Reset');
global st
st.Space = spm_matrix([0 0 0  0 0 -pi/2])*st.Space;
spm_orthviews('Image',spms,[0.05 0.05 0.9 0.45]);
spm_orthviews MaxBB;
spm_orthviews('register',hReg);
spm_orthviews('addblobs',1,SPM.XYZ,SPM.Z,SPM.M);
spm_orthviews('Redraw');
