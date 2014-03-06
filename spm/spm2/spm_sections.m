function spm_sections(SPM,hReg,spms)
% rendering of regional effects [SPM{Z}] on orthogonal sections of
% (a brain from an img file if given)
% FORMAT spm_sections(SPM,hReg)
%
% SPM  - xSPM structure containing details of excursion set
% hReg - handle of MIP register
%
%        spm_sections(SPM,hReg,imgfile)
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
if nargin<3
spms   = spm_get(1,'IMAGE','select image for rendering on');
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
