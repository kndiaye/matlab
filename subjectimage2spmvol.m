function [v,y]=subjectimage2spmvol(imagefile)
% subjectimage2spmvol - converts Brainstorm subjectimage to SPM volume
% [V,Y]=subjectimage2spmvol(imagefile)
%
% See also: spm_vol, spm_read_vol
if nargin<1
  imagefile=spm_get(1,'*subjectimage.mat',...
		    'Choose a subjectimage');
end

m=load(imagefile);

% Create volume
v.fname=imagefile;
TYPE=2;
v.dim=[size(m.Cube) TYPE];
% Translation (origin)
% T=[0 ; 0 ; 0];
% v.mat=[ diag(m.Voxsize) T; zeros(1,3) 1];

% v.mat=m.mat;

% Orientation in SubjecTImage is in CTF referential, thats not what we
% want: we would prefere it in the MRI referential
% Anyhow, we drop SCS info...
% if isfield(m, 'SCS')
%     iSCS=strmatch('ctf', lower({m.SCS.System}));
%     if isfield(m.SCS(iSCS), 'R') & isfield(m.SCS(iSCS), 'T')
%         v.mat=[ m.SCS(iSCS).R m.SCS(iSCS).T ; zeros(1,3) 1 ];
%         v.mat=v.mat([2 1 3 4],:);
%     end
% else
%     warning('No SCS in subjectimage.')

v.mat=diag([-1 1 1 1]); 
% i.e. origin is at:  v.mat(:,4) = [ 0 0 0 ]' 

% end

v.pinfo=[1 ; 0 ; 0 ]; % Slice info: intensity scale & offset and bytes offset
v.n=1;
v.descrip='Imported from BrainStrom Image';

if nargout>1
  y=m.Cube;
end



