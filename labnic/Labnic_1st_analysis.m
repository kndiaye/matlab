function [] = Labnic_analyse
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

global TR Session_filter im_format Cnam ons_unit name_ana Ons;
% defaults.modality = 'FMRI';


%% parameters to specify for each study
TR = 1.7;
im_format = 'nii'; %or 'img';
Session_filter ='*RUN*'; %name of the study in the directory of the sessions
root_path = 'C:\experiments\FLANKER'; % directory where are the populations, main directory
name_ana = 'ana'; %or 'ana2'; etc
ons_unit = 'secs'; %or 'scans';

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

%% analysis
for pop = 1:npop
    % go to the population folder
    Pop{pop} = deblank(Population(pop,:));
    sep_pop = findstr(filesep,Pop{pop});
    popu = Pop{pop}(1,sep_pop(end-1)+1:sep_pop(end));
    for sub = 1:nsuj
        %create the subject's analyse folder
        sufolder= deblank(Subject(sub,:));
        sep_suj = findstr(filesep,Subject(sub,:));
        sujet = Subject(sub,sep_suj(end-1)+1:sep_suj(end)-1);
        su = Subject(sub,sep_suj(end-1)+2:sep_suj(end)-1);
        if ~exist([sufolder 'analyse' filesep],'dir');
            mkdir(sufolder, 'analyse');
        end
        mkdir([sufolder 'analyse' filesep],name_ana);
        wkdir=[sufolder 'analyse' filesep name_ana];
        eval(['cd ' wkdir]);

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % read the behavior files to define onsets and conditions
        % this is the tricky part of reading the behavior files,
        % contact the script writers for help....
        
        %[Ons Cnam] = readres_FLANKER_missed_pooled([sufolder 'behavior' filesep],su);
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
    end
end

%% FUNCTION SECTION

%% function analyse
function [] = ana(suj_path)
global TR Session_filter im_format Cnam Ons ons_unit name_ana;

% select the sessions of interest
Session=get_directories(fullfile([suj_path 'scans'],Session_filter));
nses = size(Session,2);

% select swaf images for each Session
%===================================================================
im_style = 'swaf';
image_filter = '*swaf*';
nscans = [];
SPM.xY.P = [];

% selection of the swaf img of each session
%===================================================================
for ses = 1:nses
    smoothfolder = [suj_path 'scans' filesep deblank(Session{ses}) filesep 'swaf' filesep];
    tmp{ses} = spm_select('List',smoothfolder,['^' im_style '.*' im_format]);
    nscans = [nscans size(tmp{ses},1)];
    SPM.xY.P = strvcat(SPM.xY.P,[repmat(smoothfolder,nscans(ses),1),tmp{ses}]);
end
SPM.nscan   = nscans;
cd([suj_path 'analyse' filesep name_ana]);

% building matrix
%====================================================================
for ses = 1:nses
    nconds=length(Cnam{ses});
    for c=1:nconds
        SPM.Sess(ses).U(c).name      = {Cnam{ses}{c}};
        SPM.Sess(ses).U(c).ons       = Ons{ses}{c};
        SPM.Sess(ses).U(c).dur       = 0;

        % define the parametric modulation according to your sessions
        % (comment the adequate modulation: parametric modulation(if you
        % already specify it before), or time modulation (nothing to
        % specify in modul) or none (nothing to specify in modul)
        %% parametric modulation
        %         SPM.Sess(ses).U(c).P(1).name ='modul';
        %         SPM.Sess(ses).U(c).P(1).i = [1 2];
        %         SPM.Sess(ses).U(c).P(1).P = eval(modul{ses}{c});
        %         SPM.Sess(ses).U(c).P(1).h = 1;
        %% time modulation
        %             SPM.Sess(ses).U(c).P(1).name ='time';
        %             SPM.Sess(ses).U(c).P(1).i = [1 2];
        %             SPM.Sess(ses).U(c).P(1).P = eval(Cnam{ses}{c});
        %             SPM.Sess(ses).U(c).P(1).h = 1;
        %% no modulation
        SPM.Sess(ses).U(c).P(1).name = 'none';
    end
end

% multiple regressors for mvts parameters
%===================================================================
rnam = {'X','Y','Z','x','y','z'};
for ses=1:nses
    fn = spm_select('List',[suj_path 'scans' filesep deblank(Session{ses})],['^rp_.*txt']);
    [r1,r2,r3,r4,r5,r6] = textread([suj_path 'scans' filesep deblank(Session{ses}) filesep fn(1,:)],'%f%f%f%f%f%f');
    SPM.Sess(ses).C.C = [r1 r2 r3 r4 r5 r6];
    SPM.Sess(ses).C.name = rnam;
end

% basis functions and timing parameters
%====================================================================
defaults.stats.fmri.t   = 16;
defaults.stats.fmri.t0  = 8;

SPM.xY.RT          = TR;
SPM.xBF.name       = 'hrf';             % 'hrf (with time derivative)'
SPM.xBF.order      = 1;                 % 2 = hrf + time deriv
SPM.xBF.length     = 32;                % length in seconds

% find number of slices
%====================================================================
V  = spm_vol(SPM.xY.P(1,:));
if iscell(V)
    nslices = V{1}{1}.dim(3);
else
    nslices = V(1).dim(3);
end
ref_slice          = floor(nslices/2);	% middle slice in time
SPM.xBF.T          = defaults.stats.fmri.t;        % number of time bins per scan  % useless? cf. defaults above
SPM.xBF.T0         = defaults.stats.fmri.t/2;		    % middle slice/timebin          % useless? cf. defaults above
SPM.xBF.UNITS      = ons_unit;           % OPTIONS: 'scans'|'secs' for onsets
SPM.xBF.Volterra   = 1;                 % OPTIONS: 1|2 = order of convolution

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
SPM.swd = pwd;

% Configure design matrix
%===========================================================================
SPM = spm_fmri_spm_ui(SPM);

% Estimate parameters
%==========================================================================
SPM = spm_spm(SPM);
return

function dirs = get_directories(suj_path)
% returns a cell array holding true directories located at path
D=dir(suj_path);
dirs={D(~(strcmp({D.name},'.')+strcmp({D.name},'..')+~[D.isdir])).name};
% dirs = {'morphing_titrage_run1',...
%         'morphing_titrage_run2',...
%         'morphing_test_run5',...
%         'morphing_faceloc_run11'};

return