function [] = Labnic_1stlevel_spm8
% analysing of the subjects you will define:
% you must have a structure like
% **...\data_fMRI\populations\subjects\scans\sessions\swaf\**
% your behavioral data are in a matrix begining by ONS in:
% **...\data_fMRI\populations\subjects\behavior\**
% your analysis will be in :
% **...\data_fMRI\populations\subjects\analyse\ana1\**
% for your processed images.

% this function has been adapted by Yann Cojan (yann.cojan@unige.ch)
% improved by Virginie Sterpenich (Virginie.Sterpenich@unige.ch)
clear global
global TR Session_filter im_format Cnam ons_unit name_ana Ons Modul;

%% parameters to specify for each study
TR = 1.7;
im_format = 'nii'; %or 'img';
Session_filter ='*ATTHYPNO_RUN*'; %name of the study in the directory of the sessions
root_path = 'F:\FLANKER'; % directory where are the populations, main directory
name_ana = 'ana_E_CI_parametric_1back_2mm'; %or 'ana2'; etc
ons_unit = 'secs'; %or 'scans';

%% Definition of subjects to process
cd ([root_path '\controls'])
Subject{1}= spm_select(Inf,'dir','which subjects do you want to process?');

Subject = char(Subject);
nsuj = size(Subject,1);

%% analysis
for sub = 1:nsuj
    %create the subject's analyse folder
    sufolder= deblank(Subject(sub,:));
    sep_suj = findstr('\',Subject(sub,:));
    su = Subject(sub,sep_suj(end-1)+2:sep_suj(end)-1);
    if ~exist([sufolder 'analyse\'],'dir');
        mkdir(sufolder, 'analyse\');
    end
    mkdir([sufolder 'analyse\'],name_ana);
    wkdir=[sufolder 'analyse\' name_ana];
    eval(['cd ' wkdir]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % read the behavior files to define onsets and conditions
    % this is the tricky part of reading the behavior files,
    % contact the script writers for help....
    [Ons Modul Cnam] = readres_flanker_E_CI_parametric([sufolder 'behavior\'],su);
    %% onsets definition
    % load your ONS* mat in the behavior directory
    % ONS = spm_select('List',[path 'behavior'],strcat('^ONS+.+\.mat$'));
    % cd([path 'behavior']);
    % load(ONS);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % do the 1st level analysis for each subject
    ana(sufolder);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % do the 1st level analysis for each subject
    con(sufolder);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end

%% FUNCTION SECTION

%% function analyse
function [] = ana(suj_path)
global TR Session_filter im_format Cnam Ons ons_unit name_ana Modul;

% select the sessions of interest
Session=get_directories(fullfile([suj_path 'scans'],Session_filter));
nses = size(Session,2);

% select swaf images for each Session
%===================================================================
im_style = 'swf';
nscans = [];

matlabbatch{1}.spm.stats.fmri_spec.dir = {[suj_path 'analyse\' name_ana '\']};


% selection of the swaf img of each session
%===================================================================
for ses = 1:nses
    matlabbatch{1}.spm.stats.fmri_spec.sess(ses) = struct('scans',[],'cond',[],'multi',{{''}},'regress',struct('name',{},'val',{}),'multi_reg',[],'hpf',128);
    smoothfolder = [suj_path 'scans\' deblank(Session{ses}) '\swf'];
    tmp{ses} = spm_select('ExtFPList',smoothfolder,['^' im_style '.*' im_format]);
    nscans = [nscans size(tmp{ses},1)];
    matlabbatch{1}.spm.stats.fmri_spec.sess(ses).scans = cellstr(tmp{ses});
    
    % building matrix
    %====================================================================
    nconds=length(Cnam{ses});
    for c=1:nconds
        matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).name      = Cnam{ses}{c};
        matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).onset     = Ons{ses}{c};
        matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).duration  = 0;
        
        % no modulation
        matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).tmod = 0;%1 for time modulation 
        matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).pmod = struct('name',{},'param',{},'poly',{});
%         % modulation
%         if c < 3
%             count = 0;
%                 count = count +1;
%                 matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).pmod(count).name ='preE';
%                 matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).pmod(count).param = Modul{ses}{c}(:,1);
%                 matlabbatch{1}.spm.stats.fmri_spec.sess(ses).cond(c).pmod(count).poly = 1;
%         end
    end
    
    % multiple regressors for mvts parameters
    %===================================================================
    fn = spm_select('FPList',[suj_path 'scans\' deblank(Session{ses})],'^rp_.*txt');
    matlabbatch{1}.spm.stats.fmri_spec.sess(ses).multi_reg = {fn};  
end

% basis functions and timing parameters
%====================================================================
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 8;

matlabbatch{1}.spm.stats.fmri_spec.timing.RT = TR;           %TR

matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0]; %time derivatives
matlabbatch{1}.spm.stats.fmri_spec.timing.units = ons_unit;  % OPTIONS: 'scans'|'secs' for onsets
matlabbatch{1}.spm.stats.fmri_spec.volt   = 1;               % OPTIONS: 1|2 = order of convolution
matlabbatch{1}.spm.stats.fmri_spec.mask = {''};              % explicit masking

% global normalization: OPTIONS:'Scaling'|'None'
%---------------------------------------------------------------------------
matlabbatch{1}.spm.stats.fmri_spec.global    = 'None';

matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name',{},'levels',{});

% intrinsic autocorrelations: OPTIONS: 'none'|'AR(1) + w'
%---------------------------------------------------------------------------
matlabbatch{1}.spm.stats.fmri_spec.cvi       = 'AR(1)'; %AR(0.2)???? SOSART

matlabbatch{2}.spm.stats.fmri_est.spmmat = {[matlabbatch{1}.spm.stats.fmri_spec.dir{1} '\SPM.mat']};
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

save analyse matlabbatch
% Configure & Estimate
%==========================================================================
spm_jobman('run',matlabbatch);
return

function [] = con(sudir)
global  name_ana;

cd ([sudir '\analyse\' name_ana]);
load('SPM.mat');
SPM.xCon =[]; % reset xCon

for i = 1:length(SPM.xX.name)%adding 6 for mvt regressors that are in SPM.xX.name
    b = strfind(SPM.xX.name{i},'*bf');
%     connam{i} = SPM.xX.name{i}([7:b-1 end-1]);
    connam{i} = SPM.xX.name{i}(7:b-1);   
end

C = double(strcmp(connam,'C')); C_preE = double(strcmp(connam,'CxpreE^1')); C_postE = double(strcmp(connam,'CxpostE^1'));
I = double(strcmp(connam,'I')); I_preE = double(strcmp(connam,'IxpreE^1')); I_postE = double(strcmp(connam,'IxpostE^1'));
C_preE0 = double(strcmp(connam,'CxpreE0^1')); C_postE0 = double(strcmp(connam,'CxpostE0^1'));
I_preE0 = double(strcmp(connam,'IxpreE0^1')); I_postE0 = double(strcmp(connam,'IxpostE0^1'));
EC = double(strcmp(connam,'EC'));
EI = double(strcmp(connam,'EI'));
%----------
%F TASK
%----------
cn=1;
Cnames{cn} = 'F-task';
cwgt{cn} = [C;I;EC;EI];
ctyp{cn} = 'F';

%% main effects
cn=cn+1;
Cnames{cn} = 'C';
cwgt{cn} = C;
ctyp{cn} = 'T';
cn=cn+1;
Cnames{cn} = 'I';
cwgt{cn} = I;
ctyp{cn} = 'T';


save contrasts_name Cnames
for c = 1:cn
    cw = [cwgt{c}]';	% pad with zero for constant
    tmp(c)     = spm_FcUtil('Set',Cnames{c},ctyp{c},'c',cw,SPM.xX.xKXs);
end
SPM.xCon = tmp;
%save SPM SPM and evaluate---------------------------------------------------------------------------
SPM = spm_contrasts(SPM);
return

function dirs = get_directories(suj_path)
% returns a cell array holding true directories located at path
D=dir(suj_path);
dirs={D(~(strcmp({D.name},'.')+strcmp({D.name},'..')+~[D.isdir])).name};
return