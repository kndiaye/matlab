function [SPM]=spm_move_spm
[f,p]=uigetfile('SPM.mat', 'SPM file?')
load(fullfile(p,f));
swd = SPM.swd;
[d2,f,ext] = fileparts(SPM.xY.VY(1).fname);
if ~exist(d2, 'dir')
    d2=cd;
end
[d2]=uigetdir(d2,'New directory of functional data')
for i=1:size(SPM.xY.VY,1)
    [d0,f,ext] = fileparts(SPM.xY.VY(i).fname);
    if isempty(ext)
        if ~exist(fullfile(d2,[f,'.img']),'file')
            ext='.img';
            errordlg(sprintf('Data (%s.img) are not in this directory', [f ext]));
            return
        elseif ~exist(fullfile(d2,[f,'.hdr']),'file')
            ext='.hdr';
            errordlg(sprintf('Data (%s.hdr) are not in this directory', [f ext]));
            return
        end
    else
        if ~exist(fullfile(d2,[f,ext]),'file')
            errordlg('Data (%s) are not in this directory', [f,ext]);
            return
        end
    end
end
%
% if ~exist(fullfile(p,'SPM.mat.bak'))
%     copyfile(fullfile(p,'SPM.mat'), fullfile(p,'SPM.mat.bak'))
% end

for i=1:size(SPM.xY.VY,1)
    [d0,f,ext] = fileparts(SPM.xY.VY(i).fname);
    if isempty(ext)
        ext='.img';
    end
    SPM.xY.VY(i).fname=fullfile(d2,[f, ext]);
end

msgbox('You may now save your SPM data by typing in: ''save SPM.mat SPM''');
