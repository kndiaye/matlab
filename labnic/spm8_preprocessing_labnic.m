function [] = spm8_preprocessing_labnic
% preprocessing of the subjects you will define:
%  you must have a structure like
%  **...main_dir\populations\subjects\scans\sessions\f*img**
%
% if you have a structural image for the subject: **...main_dir\populations\subjects\scans\struct\s*img**
% if you have no structural image, do not create the dir 'struct' and the coregistration will not be processed
%
% It will create \af \waf and \swaf folders with the processed images
% Processing include realignment, coregistration, slice-timing, normalization, smoothing
%
% you must specify some details of your study in line 24 to 27 of the function
% if you have specific names or specific order for sessions, specify it at
% the end of this function

% this function has been adapted by Yann Cojan (yann.cojan@unige.ch),
% Christoph Hoftsetter (christoph.hoftsetter@unige.ch)
% and Virginie Sterpenich (virginie.sterpenich@unige.ch)

global Session_filter im_format path_spm8 func_vox_size anat_vox_size smooth_filter normalization_im_style realign_scan;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% General parameters to specify for each study
im_format = 'nii'; %or 'img';
Session_filter='*FLANKER1*'; %name of the study in the directory of the sessions
root_path = 'G:\STRHYP\controls'; % directory where are the populations, main directory

%% Specific parameters
steps = {'realign' 'coregister' 'slice_timing' 'normalization' 'smoothing'};
func_vox_size = [3 3 3];% voxel size of functional images
anat_vox_size = [1 1 1];% voxel size of anatomical image
smooth_filter = 8;      % width of the Gaussian smoothing kernel
% which scan is used for realignment?
realign_scan = 1;%1: register to mean (default); 0: register to first
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if any(strcmp('slice_timing',steps))
    normalization_im_style = 'af';
else
    normalization_im_style = 'f';
end

%% definition of the path of spm8 for finding the EPI template for normalisation
mypath = what('spm8');
path_spm8 = mypath.path;

%% Definition of the population and subjects to process
cd (root_path)
Population= spm_select(Inf,'dir','which population do you want to process?');

for pop=1:size(Population,1)
    cd(Population(pop,1:end))
    Subject{pop}= spm_select(Inf,'dir','which subjects do you want to process?');
end
Subject = char(Subject);

for suj=1:size(Subject,1)
    suj_path = [deblank(Subject(suj,1:end)) 'scans\'];
    for s = 1:size(steps,2)
        if strcmp(steps{s},'realign') || strcmp(steps{s},'coregister') || strcmp(steps{s},'slice_timing')
            im_style = 'f';
        elseif strcmp(steps{s},'normalization')
            im_style = normalization_im_style;
        elseif strcmp(steps{s},'smoothing')
            im_style = ['w' normalization_im_style];
        end
        eval([steps{s} '(suj_path,im_style)']);
    end
end

%% F U N C T I O N - S E C T I O N
function realign(suj_path,im_style)
%%%searches in path for sessions, realigns images in folder 'f' and rewrites their headers
cd(suj_path);
global Session_filter im_format realign_scan;

Session=get_directories(fullfile(suj_path,Session_filter));
if ~isempty(Session)
    %loading the job
    for iii=1:length(Session)
        im_sess = fullfile(suj_path,Session{iii});
        matlabbatch{1}.spm.spatial.realign.estwrite.data{iii} = cellstr(spm_select('FPList',im_sess,['^' im_style '.*' im_format]));
    end
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = realign_scan;%1: register to mean (default); 0: register to first
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = {};
    matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [0 1];
    save('realign','matlabbatch');
    spm_jobman('run',matlabbatch);
end
return

function coregister(suj_path,im_style)
%%%searches in path if struct exist
%coregister the s img with the mean img;
global Session_filter im_format;
Session=get_directories(fullfile(suj_path,Session_filter));
D=dir(suj_path);
if any(strcmp({D.name},'struct'));%if the structural img exist
    matlabbatch{1}.spm.spatial.coreg.estimate.ref = {fullfile(suj_path,Session{1},spm_select('List',fullfile(suj_path,Session{1}), ['^mean.*' im_format]))};
    matlabbatch{1}.spm.spatial.coreg.estimate.source = {fullfile(suj_path,'struct',spm_select('List',fullfile(suj_path,'struct'), ['^.*' im_format]))};
    matlabbatch{1}.spm.spatial.coreg.estimate.other{1}           = char('');
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.cost_fun  = char('nmi');
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.sep       = [4 2];
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.tol       = reshape(double([0.02; 0.02; 0.02; 0.001; 0.001; 0.001; 0.01; 0.01; 0.01; 0.001; 0.001; 0.001;]),[1,12]);
    matlabbatch{1}.spm.spatial.coreg.estimate.eoptions.fwhm      = [7 7];
    save('coreg','matlabbatch');
    spm_jobman('run',matlabbatch);
end
return

function slice_timing(suj_path,im_style)
%%%searches in path for sessions, corrects for different slice times,
%%%writes new file prefixed by 'a' and moves them into a folder 'a...',
cd(suj_path);
global Session_filter im_format;
Session=get_directories(fullfile(suj_path,Session_filter));
count =0;

for iii=1:length(Session)
    im_sess = fullfile(suj_path,Session{iii});
    matlabbatch{1}.spm.temporal.st.scans{iii} = cellstr(spm_select('FPList',im_sess,['^' im_style '.*' im_format]));
end
%find number of slices
V=spm_vol(matlabbatch{1}.spm.temporal.st.scans{1}{1});
nslices = V.dim(3);
TR = str2double(V.descrip(findstr('TR',V.descrip)+3:findstr('TR',V.descrip)+6))/1000;%finding automatically TR
matlabbatch{1}.spm.temporal.st.nslices = nslices;
matlabbatch{1}.spm.temporal.st.tr = TR;
matlabbatch{1}.spm.temporal.st.ta = matlabbatch{1}.spm.temporal.st.tr-matlabbatch{1}.spm.temporal.st.tr/matlabbatch{1}.spm.temporal.st.nslices;
matlabbatch{1}.spm.temporal.st.so = matlabbatch{1}.spm.temporal.st.nslices:-1:1; %descending
matlabbatch{1}.spm.temporal.st.refslice = ceil(matlabbatch{1}.spm.temporal.st.nslices/2); %middle slice as reference

save('slicetiming','matlabbatch');
spm_jobman('run',matlabbatch);
move_files(suj_path,im_style,['a' im_style]);
return

function normalization(suj_path, im_style)
%%%searches in path for sessions, normalises images indicated by im_style,
%%%using parameters from first scan in sessions, writes new file prefixed by 'w'
%%%and moves them into a folder 'w...', which is located at the same level as 'f'
cd(suj_path);
global Session_filter im_format path_spm8 func_vox_size anat_vox_size ;
Session=get_directories(fullfile(suj_path,Session_filter));
if ~isempty(Session)
    %loading the job
    %source image is the mean image generated in the realignment step
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.source = cellstr(spm_select('FPList',fullfile(suj_path,Session{1}), ['^meanf.*' im_format]));
    %initialisation of .resample
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample=[];
    for iii=1:length(Session)
        if strcmp(im_style, 'af')
            im_sess = fullfile(suj_path,Session{iii},im_style);
        else
            im_sess = fullfile(suj_path,Session{iii});
        end
        this_session_images=cellstr(spm_select('FPList',im_sess,['^' im_style '.*' im_format]));
        matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample=[matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample {this_session_images{1:end}}];
    end
    matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = {};
    %template path
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template{1} = [path_spm8 '\templates\EPI.nii,1'];
    %other parameters
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.weight = {};
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
    matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.bb = [-78 -112 -50;78 76 85];
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox = func_vox_size; %default [2 2 2]
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.interp = 1;
    matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
    
    D=dir(suj_path); %if struct exist, it is also normalised
    if any(strcmp({D.name},'struct'));
        %initialisation of .resample
        matlabbatch{2}.spm.spatial.normalise.estwrite.subj.resample=[];
        struct_img = {spm_select('FPList',fullfile(suj_path,'struct'), ['^s.*' im_format])};
        matlabbatch{2}.spm.spatial.normalise.estwrite.subj.resample = struct_img;
        
        %source image is the T1 image
        matlabbatch{2}.spm.spatial.normalise.estwrite.subj.source = struct_img;
        matlabbatch{2}.spm.spatial.normalise.estwrite.subj.wtsrc = {};
        %template path
        matlabbatch{2}.spm.spatial.normalise.estwrite.eoptions.template{1} = [path_spm8 '\templates\T1.nii,1'];
        %other parameters
        matlabbatch{2}.spm.spatial.normalise.estwrite.eoptions.weight = {};
        matlabbatch{2}.spm.spatial.normalise.estwrite.eoptions.smosrc = 8;
        matlabbatch{2}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
        matlabbatch{2}.spm.spatial.normalise.estwrite.eoptions.regtype = 'mni';
        matlabbatch{2}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
        matlabbatch{2}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
        matlabbatch{2}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
        matlabbatch{2}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
        matlabbatch{2}.spm.spatial.normalise.estwrite.roptions.bb = [-78 -112 -50;78 76 85];
        matlabbatch{2}.spm.spatial.normalise.estwrite.roptions.vox = anat_vox_size; %default [1 1 1]
        matlabbatch{2}.spm.spatial.normalise.estwrite.roptions.interp = 1;
        matlabbatch{2}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
    end
    
    save('normalize','matlabbatch');
    spm_jobman('run',matlabbatch);
    move_files(suj_path,im_style,['w' im_style]);
end
return

function smoothing(suj_path, im_style)
%%%searches in path for sessions, smooths images indicated by im_style,
%%%writes new files prefixed by 's' and moves them into a folder 's...', which
%%%is located at the same level as 'f'
cd(suj_path);
global Session_filter im_format smooth_filter;
Session=get_directories(fullfile(suj_path,Session_filter));
if ~isempty(Session)
    matlabbatch{1}.spm.spatial.smooth.data=[];
    for iii=1:length(Session)
        im_sess = fullfile(suj_path,Session{iii},im_style);
        this_session_images=cellstr([repmat([im_sess '\'],size(spm_select('List',im_sess,['^' im_style '.*' im_format]),1),1) spm_select('List',im_sess,['^' im_style '.*' im_format])]);
        matlabbatch{1}.spm.spatial.smooth.data=[matlabbatch{1}.spm.spatial.smooth.data {this_session_images{1:end}}];
    end
    matlabbatch{1}.spm.spatial.smooth.fwhm                          = repmat(smooth_filter,1,3);
    matlabbatch{1}.spm.spatial.smooth.dtype                         = 0;
    save('smooth','matlabbatch');
    spm_jobman('run',matlabbatch);
    move_files(suj_path,im_style,['s' im_style]);
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Auxiliary Functions%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function move_files(suj_path,source_style,dest_style)
%%% moves files with source_style (e.g. swaf) from path (e.g. waf) to new
%%% destination defined by dest_style
global Session_filter im_format;
Session=get_directories(fullfile(suj_path,Session_filter));
if ~isempty(Session)
    for iii=1:length(Session)
        if strcmp(im_format,'nii')
            if strcmp(source_style,'f')%$$$$ f img are not in a specific dir
                movefile(fullfile(suj_path,Session{iii},[dest_style '*.' im_format]),fullfile(suj_path,Session{iii},dest_style))
            else
                movefile(fullfile(suj_path,Session{iii},source_style,[dest_style '*.' im_format]),fullfile(suj_path,Session{iii},dest_style))
            end
        else
            if strcmp(source_style,'f')%$$$$ f img are not in a specific dir
                movefile(fullfile(suj_path,Session{iii},[dest_style '*.' im_format]),fullfile(suj_path,Session{iii},dest_style))
                movefile(fullfile(suj_path,Session{iii},[dest_style '*.hdr']),fullfile(suj_path,Session{iii},dest_style))
            else
                movefile(fullfile(suj_path,Session{iii},source_style,[dest_style '*.' im_format]),fullfile(suj_path,Session{iii},dest_style))
                movefile(fullfile(suj_path,Session{iii},source_style,[dest_style '*.hdr']),fullfile(suj_path,Session{iii},dest_style))
            end
        end
    end
end
return

function dirs = get_directories(suj_path)
% returns a cell array holding true directories located at path
D=dir(suj_path);
dirs={D(~(strcmp({D.name},'.')+strcmp({D.name},'..')+~[D.isdir])).name};
return