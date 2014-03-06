function [] = Labnic_PPI_spm8
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global Session_filter scandir namevar psyconvar rad_sphere TR nslices region

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mypoints =  [42 -43 -23]; %% seed voxel
region = 'rFFA'; %% region corresponding to the voxel
namevar={'Cf' 'If' 'Cs' 'Is'};
psyconvar=[1 1 -1 -1];
root_path = 'C:\experiments\FLANKER\'; % directory where are the populations, main directory
anadir = 'ana_woST\'; %or 'ana2'; etc
Session_filter = '*ATTHYPNO_RUN*';
rad_sphere = 8; % radius of the sphere in mm
TR = 1.7; % your TR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mycon=1; %will take the F-task contrast (1) to define the conditions of the task
%% defining the pop_style
cd (root_path)
Population  = spm_select(Inf,'dir','which population do you want to process?');
npop        = size(Population,1);

%% Definition of subjects to process
for pop=1:npop
    cd(Population(pop,1:end))
    Subject{pop}= spm_select(Inf,'dir','which subjects do you want to process?');
end
Subject = char(Subject);
nsuj = size(Subject,1);

for sub = 1:size(Subject,1)
    su = deblank(Subject(sub,:));
    scandir = [su 'scans'];
    
    xyz= mypoints;
    path_ana =fullfile(deblank(Subject(sub,:)),'analyse',anadir);
    [SPM,xSPM] = spm_getSPM_PPI(path_ana,mycon);
    
    % find number of slices
%====================================================================
V  = spm_vol(SPM.xY.P(1,:));
if iscell(V)
    nslices = V{1}{1}.dim(3);
else
    nslices = V(1).dim(3);
end

    XYZ  = SPM.xVol.XYZ;
    XYZmm = SPM.xVol.M(1:3,:)*[XYZ; ones(1,size(XYZ,2))];
    [xyz,i] = spm_XYZreg('NearestXYZ',xyz,XYZmm);
    
    %% extract neural signal from seed region
    myPPI = spm_regions_PPI(SPM,xSPM,xyz);
    
    %% create a new model and estimates it
    Labnic_analyse_PPI(su,myPPI,region);
    
    %% make the contrasts
    Labnic_contrast_PPI(su,region);
end

return

%% subfunctions
function dirs = get_directories(suj_path)
% returns a cell array holding true directories located at path
D=dir(suj_path);
dirs={D(~(strcmp({D.name},'.')+strcmp({D.name},'..')+~[D.isdir])).name};
% dirs = {'morphing_titrage_run1',...
%         'morphing_titrage_run2',...
%         'morphing_test_run5',...
%         'morphing_faceloc_run11'};

return

function PPI = Labnic_extract_PPI(SPM, myvoi,psyconvar,namevar)
% Bold deconvolution to create physio- or psycho-physiologic interactions


% check inputs and set up variables
%----------------------------------------------------------------------
RT     = SPM.xY.RT;
dt     = SPM.xBF.dt;
NT     = round(RT/dt);


% Ask whether to perform physiophysiologic or psychophysiologic interactions
%--------------------------------------------------------------------------
% set(Finter,'name','PPI Setup')
% ppiflag    = 'psychophysiologic interaction';

% case  'psychophysiologic interaction'  % get hemodynamic response
%=====================================================================
%     spm_input('physiological variable:...  ',2,'d');
%     P      = spm_get(1,'VOI*.mat',{'select VOIs'});
P = myvoi;
p      = load(P,'xY');
xY(1)  = p.xY;
Sess   = SPM.Sess(xY(1).Sess);

% get 'causes' or inputs U
%----------------------------------------------------------------------
%spm_input('Psychological variable:...  ',2,'d');
U.name = {};
U.u    = [];
U.w    = [];

for i = 1:length(Sess.U)
    Name(i) = Sess.U(i).name;
end
count = 0;
for  i = 1:length(namevar)
    if any(strcmp(namevar(i),Name));
        count = count +1;
        mypsyconvar = psyconvar(i);
        for  j = 1:length(Sess.U(count).name)
            U.u             = [U.u Sess.U(count).u(33:end,j)];% don't understand
            U.name{end + 1} = Sess.U(count).name{j};
            U.w             = [U.w mypsyconvar];
        end
    end
end
if sum(U.w) < 0
    U.w(U.w == 1) = 4/(4+sum(U.w));
end

% name of PPI file to be saved
%-------------------------------------------------------------------------
[tmp, myfile]= fileparts(myvoi);
PPI.name    = ['PPI_' myfile]

% Setup variables
%-------------------------------------------------------------------------
N     = length(xY(1).u);
k     = 1:NT:N*NT;  			% microtime to scan time indices

% create basis functions and hrf in scan time and microtime
%-------------------------------------------------------------------------
%spm('Pointer','watch')
hrf   = spm_hrf(dt);

% create convolved explanatory {Hxb} variables in scan time
%-------------------------------------------------------------------------
xb    = spm_dctmtx(N*NT + 128,N);
Hxb   = zeros(N,N);
for i = 1:N
    Hx       = conv(xb(:,i),hrf);
    Hxb(:,i) = Hx(k + 128);
end
xb    = xb(129:end,:);


% get confounds (in scan time) and constant term
%-------------------------------------------------------------------------
X0    = xY(1).X0;
M     = size(X0,2);


% get response variable,
%-------------------------------------------------------------------------
for i = 1:size(xY,2)
    Y(:,i) = xY(i).u;
end


% remove confounds and save Y in ouput structure
%-------------------------------------------------------------------------
% Yc    = Y - X0*inv(X0'*X0)*X0'*Y; %SOSART
Yc    = Y - X0*pinv(X0'*X0)*X0'*Y;
PPI.Y = Yc(:,1);
if size(Y,2) == 2
    PPI.P  = Yc(:,2);
end


% specify covariance components; assume neuronal response is white
% treating confounds as fixed effects
%-------------------------------------------------------------------------
Q      = speye(N,N)*N/trace(Hxb'*Hxb);
Q      = blkdiag(Q, speye(M,M)*1e6  );

% get whitening matrix (NB: confounds have already been whitened)
%-------------------------------------------------------------------------
W      = SPM.xX.W(Sess.row,Sess.row);

% create structure for spm_PEB
%-------------------------------------------------------------------------
clear P
P{1}.X = [W*Hxb X0];		% Design matrix for lowest level
P{1}.C = speye(N,N)/4;		% i.i.d assumptions
P{2}.X = sparse(N + M,1);	% Design matrix for parameters (0's)
P{2}.C = Q;


% case  'psychophysiologic interaction'
%=====================================================================

% COMPUTE PSYCHOPHYSIOLOGIC INTERACTIONS
% use basis set in microtime
%---------------------------------------------------------------------
% get parameter estimates and neural signal; beta (C) is in scan time
% This clever trick allows us to compute the betas in scan time which is
% much quicker than with the large microtime vectors. Then the betas
% are applied to a microtime basis set generating the correct neural
% activity to convolve with the psychological variable in mircrotime
%---------------------------------------------------------------------
C       = spm_PEB(Y,P);
xn      = xb*C{2}.E(1:N);
xn      = spm_detrend(xn);

% setup psychological variable from inputs and contast weights
%---------------------------------------------------------------------
PSY     = zeros(N*NT,1);
for i = 1:size(U.u,2)
    tmp = full(U.u(:,i)*U.w(:,i));
    tmp = tmp(1:(N*NT));
    PSY = PSY + tmp;
end
PSY     = spm_detrend(PSY);

% multiply psychological variable by neural signal
%---------------------------------------------------------------------
PSYxn   = PSY.*xn;

% convolve and resample at each scan for bold signal
%---------------------------------------------------------------------
ppi	    = conv(PSYxn,hrf);
ppi     = ppi(k);

% similarly for psychological effect
%---------------------------------------------------------------------
PSYHRF  = conv(PSY,hrf);
PSYHRF  = PSYHRF(k);

% save psychological variables
%---------------------------------------------------------------------
PPI.psy = U;
PPI.P   = PSYHRF;
PPI.xn  = xn;
PPI.ppi = spm_detrend(ppi);

return

function [myPPI] = spm_regions_PPI(SPM,xSPM,xyz)
xY.xyz  = xyz;

global Session_filter scandir psyconvar namevar rad_sphere
%-Get adjustment options and VOI name
%-----------------------------------------------------------------------
spm_input(sprintf('at [%3.0f %3.0f %3.0f]',xY.xyz),1,'d',...
    'VOI time-series extraction')

if ~isfield(xY,'name')
    tmp = deblank(num2str(xyz'));
    xY.name = strrep(tmp, ' ','');
end

xY.Ic = 1;

xY.def    = 'sphere';
Q = ones(1,size(xSPM.XYZmm,2));

if ~isfield(xY,'spec')
    xY.spec = rad_sphere; % radius of the sphere
end
d = [xSPM.XYZmm(1,:) - xyz(1);
    xSPM.XYZmm(2,:) - xyz(2);
    xSPM.XYZmm(3,:) - xyz(3)];
Q = find(sum(d.^2) <= xY.spec^2);

%% Get raw data, whiten and filter
y        = spm_get_data(SPM.xY.VY,xSPM.XYZ(:,Q));
y        = spm_filter(SPM.xX.K,SPM.xX.W*y);
xY.XYZmm = xSPM.XYZmm(:,Q);

%-Parameter estimates: beta = xX.pKX*xX.K*y
%---------------------------------------------------------------
beta  = spm_get_data(SPM.Vbeta,xSPM.XYZ(:,Q));

%-subtract Y0 = XO*beta,  Y = Yc + Y0 + e
%---------------------------------------------------------------
y     = y - spm_FcUtil('Y0',SPM.xCon(xY.Ic),SPM.xX.xKXs,beta);

% extract session-specific rows from data and confounds
%-----------------------------------------------------------------------
Session=get_directories(fullfile(scandir,Session_filter));
nses = size(Session,2);

for ses=1:nses
    clear xY.X0 y2
    xY.X0     = SPM.xX.xKXs.X(:,[SPM.xX.iB SPM.xX.iG]);
    xY.Sess   = ses;
    
    try
        i     = SPM.Sess(xY.Sess).row;
        y2     = y(i,:);
        xY.X0 = xY.X0(i,:);
    end
    
    % and add session-specific filter confounds
    %-----------------------------------------------------------------------
    try
        xY.X0 = [xY.X0 SPM.xX.K(xY.Sess).X0];
    end
    
    %=======================================================================
    try
        xY.X0 = [xY.X0 SPM.xX.K(xY.Sess).KH]; % Compatibility check
    end
    
    % compute regional response in terms of first eigenvariate
    %-----------------------------------------------------------------------
    [m n]   = size(y2);
    if m > n
        [v s v] = svd(spm_atranspa(y2));
        s       = diag(s);
        v       = v(:,1);
        u       = y2*v/sqrt(s(1));
    else
        [u s u] = svd(spm_atranspa(y2'));
        s       = diag(s);
        u       = u(:,1);
        v       = y2'*u/sqrt(s(1));
    end
    d       = sign(sum(v));
    u       = u*d;
    v       = v*d;
    Y       = u*sqrt(s(1)/n);
    
    % set in structure
    %-----------------------------------------------------------------------
    xY.y    = y2;
    xY.u    = Y;
    xY.v    = v;
    xY.s    = s;
    
    str     = ['VOI_' xY.name];
    if isfield(xY,'Sess')
        if length(xY.Sess) == 1
            str = sprintf('VOI_%s_%i',xY.name,xY.Sess);
        end
    end
    myvoi= [fullfile(SPM.swd,str) '.mat'];
    save(fullfile(SPM.swd,str),'Y','xY')
    myPPI{ses} = Labnic_extract_PPI(SPM,myvoi,psyconvar,namevar);
end
return

function [SPM,xSPM] = spm_getSPM_PPI(swd,Ic)
SCCSid = '2.51';

%-GUI setup
%-----------------------------------------------------------------------
SPMid  = spm('SFnBanner',mfilename,SCCSid);
spm_help('!ContextHelp',mfilename)

%-Select SPM.mat & note SPM results directory
%-----------------------------------------------------------------------
% swd    = spm_str_manip(spm_get(1,'SPM.mat','Select SPM.mat'),'H');

%-Preliminaries...
%=======================================================================

%-Load SPM.mat
%-----------------------------------------------------------------------
load(fullfile(swd,'SPM.mat'));
SPM.swd = swd;

%-Get volumetric data from SPM.mat
%-----------------------------------------------------------------------
try
    xX   = SPM.xX;				%-Design definition structure
    XYZ  = SPM.xVol.XYZ;			%-XYZ coordinates
    S    = SPM.xVol.S;			%-search Volume {voxels}
    R    = SPM.xVol.R;			%-search Volume {resels}
    M    = SPM.xVol.M(1:3,1:3);		%-voxels to mm matrix
    VOX  = sqrt(diag(M'*M))';		%-voxel dimensions
catch
    
    % check the model has been estimated
    %---------------------------------------------------------------
    str = {	'This model has not been estimated.';...
        'Would you like to estimate it now?'};
    if spm_input(str,1,'bd','yes|no',[1,0],1)
        [SPM] = spm_spm(SPM);
    else
        return
    end
end


%-Contrast definitions
%=======================================================================

%-Load contrast definitions (if available)
%-----------------------------------------------------------------------
try
    xCon = SPM.xCon;
catch
    xCon = {};
end

nc       = length(Ic);  % Number of contrasts

n = 1;

%-Enforce orthogonality of multiple contrasts for conjunction
% (Orthogonality within subspace spanned by contrasts)
%-----------------------------------------------------------------------
Im = [];
pm = [];
Ex = [];

%-Create/Get title string for comparison
%-----------------------------------------------------------------------
str  = xCon(Ic).name;
if Ex
    mstr = 'masked [excl.] by';
else
    mstr = 'masked [incl.] by';
end
if length(Im) == 1
    str  = sprintf('%s (%s %s at p=%g)',str,mstr,xCon(Im).name,pm);
    
elseif ~isempty(Im)
    str  = [sprintf('%s (%s {%d',str,mstr,Im(1)),...
        sprintf(',%d',Im(2:end)),...
        sprintf('} at p=%g)',pm)];
end
titlestr     = str;

%-Compute & store contrast parameters, contrast/ESS images, & SPM images
%=======================================================================
SPM.xCon = xCon;
SPM      = spm_contrasts(SPM,unique([Ic,Im]));
xCon     = SPM.xCon;
VspmSv   = cat(1,xCon(Ic).Vspm);
STAT     = xCon(Ic(1)).STAT;

%-Check conjunctions - Must be same STAT w/ same df
%-----------------------------------------------------------------------
if (nc > 1) && (any(diff(double(cat(1,xCon(Ic).STAT)))) || ...
        any(abs(diff(cat(1,xCon(Ic).eidf))) > 1))
    error('illegal conjunction: can only conjoin SPMs of same STAT & df')
end

%-Degrees of Freedom and STAT string describing marginal distribution
%-----------------------------------------------------------------------
df          = [xCon(Ic(1)).eidf xX.erdf];
if nc>1
    if n>1
        str = sprintf('^{%d \\{Ha:k\\geq%d\\}}',nc,(nc-n)+1);
    else
        str = sprintf('^{%d \\{Ha:k=%d\\}}',nc,(nc-n)+1);
    end
else
    str = '';
end

switch STAT
    case 'T'
        STATstr = sprintf('%c%s_{%.0f}','T',str,df(2));
    case 'F'
        STATstr = sprintf('%c%s_{%.0f,%.0f}','F',str,df(1),df(2));
    case 'P'
        STATstr = sprintf('%s^{%0.2f}','PPM',df(1));
end

%-Compute (unfiltered) SPM pointlist for masked conjunction requested
%=======================================================================
fprintf('\t%-32s: %30s\n','SPM computation','...initialising')         %-#

%-Compute conjunction as minimum of SPMs
%-----------------------------------------------------------------------
Z         = Inf;
for i     = Ic
    Z = min(Z,spm_get_data(xCon(i).Vspm,XYZ));
end

% P values for False Discovery FDR rate computation (all search voxels)
%=======================================================================
switch STAT
    case 'T'
        Ps = (1 - spm_Tcdf(Z,df(2))).^n;
    case 'P'
        Ps = (1 - Z).^n;
    case 'F'
        Ps = (1 - spm_Fcdf(Z,df)).^n;
end

%-Compute mask and eliminate masked voxels
%-----------------------------------------------------------------------
for i = Im
    fprintf('%s%30s',sprintf('\b')*ones(1,30),'...masking')
    
    Mask = spm_get_data(xCon(i).Vspm,XYZ);
    um   = spm_u(pm,[xCon(i).eidf,xX.erdf],xCon(i).STAT);
    if Ex
        Q = Mask <= um;
    else
        Q = Mask >  um;
    end
    XYZ       = XYZ(:,Q);
    Z         = Z(Q);
    if isempty(Q)
        fprintf('\n')                                           %-#
        warning(sprintf('No voxels survive masking at p=%4.2f',pm))
        break
    end
end

%-clean up interface
%-----------------------------------------------------------------------
fprintf('\t%-32s: %30s\n','SPM computation','...done')         %-#
spm('Pointer','Arrow')



%=======================================================================
% - H E I G H T   &   E X T E N T   T H R E S H O L D S
%=======================================================================

%-Height threshold - classical inference
%-----------------------------------------------------------------------
u      = -Inf;
k      = 0;
u  = 1;
if u <= 1; u = spm_u(u^(1/n),df,STAT); end



%-Calculate height threshold filtering
%-------------------------------------------------------------------
Q      = find(Z > u);

%-Apply height threshold
%-------------------------------------------------------------------
Z      = Z(:,Q);
XYZ    = XYZ(:,Q);
if isempty(Q)
    warning(sprintf('No voxels survive height threshold u=%0.2g',u))
end


%-Extent threshold (disallowed for conjunctions)
%-----------------------------------------------------------------------
if ~isempty(XYZ)
    
    %-Get extent threshold [default = 0]
    %-------------------------------------------------------------------
    k     = 0;
    
    %-Calculate extent threshold filtering
    %-------------------------------------------------------------------
    A     = spm_clusters(XYZ);
    Q     = [];
    for i = 1:max(A)
        j = find(A == i);
        if length(j) >= k; Q = [Q j]; end
    end
    
    % ...eliminate voxels
    %-------------------------------------------------------------------
    Z     = Z(:,Q);
    XYZ   = XYZ(:,Q);
    if isempty(Q)
        warning(sprintf('No voxels survive extent threshold k=%0.2g',k))
    end
    
else
    
    k = 0;
    
end % (if ~isempty(XYZ))


%=======================================================================
% - E N D
%=======================================================================
fprintf('\t%-32s: %30s\n','SPM computation','...done')         %-#

%-Assemble output structures of unfiltered data
%=======================================================================
xSPM   = struct('swd',		swd,...
    'title',	titlestr,...
    'Z',		Z,...
    'n',		n,...
    'STAT',		STAT,...
    'df',		df,...
    'STATstr',	STATstr,...
    'Ic',		Ic,...
    'Im',		Im,...
    'pm',		pm,...
    'Ex',		Ex,...
    'u',		u,...
    'k',		k,...
    'XYZ',		XYZ,...
    'XYZmm',	SPM.xVol.M(1:3,:)*[XYZ; ones(1,size(XYZ,2))],...
    'S',		SPM.xVol.S,...
    'R',		SPM.xVol.R,...
    'FWHM',		SPM.xVol.FWHM,...
    'M',		SPM.xVol.M,...
    'iM',		SPM.xVol.iM,...
    'DIM',		SPM.xVol.DIM,...
    'VOX',		VOX,...
    'Vspm',		VspmSv,...
    'Ps',		Ps);

% RESELS per voxel (density) if it exists
%-----------------------------------------------------------------------
if isfield(SPM,'VRpv'), xSPM.VRpv = SPM.VRpv; end
return

function [] = Labnic_analyse_PPI(su,myPPI,region)

global Session_filter scandir TR nslices

anatype = ['analyse' filesep 'PPI' filesep];
% select the sessions of interest
Session=get_directories(fullfile(scandir,Session_filter));
nses = size(Session,2);

myana= ['PPI_' region filesep]; %ROI

% specify data: matrix of filenames and TR
%===========================================================================
nscans=[];
SPM.xY.P=[];
clear tmp

for ses= 1:nses
    smoothfolder = fullfile(scandir,deblank(Session{ses}),[filesep 'swf' filesep]);
    tmp{ses} = spm_select('List',smoothfolder,'^sw.*nii');
    nscans = [nscans size(tmp{ses},1)];
    SPM.xY.P = strvcat(SPM.xY.P,[repmat(smoothfolder,nscans(ses),1),tmp{ses}]);
end

% basis functions and timing parameters
%---------------------------------------------------------------------------
ref_slice=floor(nslices/2);	% middle slice in time
SPM.xBF.T          = nslices;        % number of time bins per scan  % useless? cf. defaults above
SPM.xBF.T0         = ref_slice;		    % middle slice/timebin          % useless? cf. defaults above
SPM.xBF.UNITS      = 'scans';           % OPTIONS: 'scans'|'secs' for onsets
SPM.xBF.Volterra   = 1;     
SPM.xBF.name       = 'hrf';
SPM.xBF.order      = 1;                 %2= hrf + time deriv --> 'hrf (with time derivative)';
SPM.xBF.length     = 32;                % length in seconds
   
SPM.xY.RT = TR;

% number of scans and sessions
%---------------------------------------------------------------------------
SPM.nscan   = nscans;

for ses=1:nses
    SPM.Sess(ses).U=[];
end

rnam = {'PPI' 'contrast' region 'X','Y','Z','x','y','z'};
for ses=1:nses
    fn = spm_select('List',fullfile(scandir,deblank(Session{ses})),'^rp_.*txt');
    [r1,r2,r3,r4,r5,r6] = textread(fullfile(scandir,deblank(Session{ses}),fn(1,:)),'%f%f%f%f%f%f');
    SPM.Sess(ses).C.C = [myPPI{ses}.ppi myPPI{ses}.P myPPI{ses}.Y r1 r2 r3 r4 r5 r6];
    SPM.Sess(ses).C.name = rnam;
end

defaults.stats.fmri.t   = nslices;
defaults.stats.fmri.t0  = ref_slice;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subject specific bit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wkdir =  [su anatype myana];
if ~exist(wkdir, 'dir');
    mkdir(wkdir);
end
eval(['cd ' (wkdir)]);

% global normalization: OPTIONS:'Scaling'|'None'
%---------------------------------------------------------------------------
SPM.xGX.iGXcalc    = 'None';

% low frequency confound: high-pass cutoff (secs) [Inf = no filtering]
%---------------------------------------------------------------------------
SPM.xX.K(1).HParam = 128;

% intrinsic autocorrelations: OPTIONS: 'none'|'AR(1) + w'
%-----------------------------------------------------------------------
SPM.xVi.form       = 'AR(1)'; %AR(0.2)???? SOSART

% specify SPM working dir for this sub
%===========================================================================
SPM.swd = wkdir;

% Configure design matrix
%===========================================================================
SPM = spm_fmri_spm_ui(SPM);

% Estimate parameters
%===========================================================================
SPM = spm_spm(SPM);
return


function [] = Labnic_contrast_PPI(su,region)

cd (fullfile(su,['analyse' filesep 'PPI'],['PPI_' region]))
load('SPM.mat');

SPM.xCon =[]; % reset xCon

for i = 1:length(SPM.xX.name)%adding 6 for mvt regressors that are in SPM.xX.name
    connam{i} = SPM.xX.name{i}(7:end);
end
PPI = double(strcmp(connam,'PPI'));
contrast = double(strcmp(connam,'contrast'));
vox = double(strcmp(connam,region));
%----------
%MAIN EFFECTS
%----------
cn = 1;
Cnames{cn} = 'PPI';
cwgt{cn} = PPI;
ctyp{cn} = 'F';
cn = cn+1;
Cnames{cn} = 'contrast';
cwgt{cn} = contrast;
ctyp{cn} = 'T';
cn = cn+1;
Cnames{cn} = region;
cwgt{cn} = vox;
ctyp{cn} = 'T';
cn = cn+1;
Cnames{cn} = 'PPI';
cwgt{cn} = PPI;
ctyp{cn} = 'T';
cn = cn+1;
Cnames{cn} = '-PPI';
cwgt{cn} = -PPI;
ctyp{cn} = 'T';

save contrasts_name Cnames
for c = 1:cn
    cw = [cwgt{c}]';	% pad with zero for constant
    tmp(c)     = spm_FcUtil('Set',Cnames{c},ctyp{c},'c',cw,SPM.xX.xKXs);
end
SPM.xCon = tmp;

SPM = spm_contrasts(SPM);
return