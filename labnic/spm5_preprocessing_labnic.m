function [] = Labnic_preprocessing_spm5
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

global TR Session_filter im_format path_spm5;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameters to specify for each study
TR = 1.7;
im_format = 'nii'; %or 'img';
Session_filter='*ATTHYPNO*'; %name of the study in the directory of the sessions
root_path = 'C:\experiments\FLANKER\'; % directory where are the populations, main directory
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% definition of the path of spm5 for finding the EPI template for normalisation
mypath = what('spm8');
path_spm8 = mypath(1).path;

%% Definition of the population and subjects to process
cd (root_path)
Population= spm_select(Inf,'dir','which population do you want to process?');

for pop=1:size(Population,1)
    cd(Population(pop,1:end))
    Subject{pop}= spm_select(Inf,'dir','which subjects do you want to process?');
end
Subject = char(Subject);

%% Processing
for suj=1:size(Subject,1)
    suj_path = [deblank(Subject(suj,1:end)) 'scans' filesep];
    disp(['working on ' suj_path]);
    disp('------------------------');
    %call different steps here
  %  realign(suj_path);
    %coregister(suj_path);
   % slice_timing(suj_path,'f');
    normalise(suj_path,'af');
    %smooth(suj_path,'waf');
end

%% F U N C T I O N - S E C T I O N
function realign(suj_path)
%%%searches in path for sessions, realigns images in folder 'f' and rewrites their headers
cd(suj_path);
global Session_filter im_format;
im_style='f';
Session=get_directories(fullfile(suj_path,Session_filter));
if ~isempty(Session)
    %loading the job
    for iii=1:length(Session)
        im_sess = fullfile(suj_path,Session{iii});
        jobs{1}.spatial{1}.realign{1}.estwrite.data{iii} = ...
            [repmat([im_sess filesep],size(spm_select('List',im_sess,['^' im_style '.*' im_format]),1),1) spm_select('List',im_sess,['^' im_style '.*' im_format])];
    end
    jobs{1}.spatial{1}.realign{1}.estwrite.eoptions.quality = 0.9;
    jobs{1}.spatial{1}.realign{1}.estwrite.eoptions.sep = 4;
    jobs{1}.spatial{1}.realign{1}.estwrite.eoptions.fwhm = 5;
    jobs{1}.spatial{1}.realign{1}.estwrite.eoptions.rtm = 1; % 1: register to mean (default); 0: register to first
    jobs{1}.spatial{1}.realign{1}.estwrite.eoptions.interp = 2;
    jobs{1}.spatial{1}.realign{1}.estwrite.eoptions.wrap = [0 0 0];
    jobs{1}.spatial{1}.realign{1}.estwrite.eoptions.weight = {};
    jobs{1}.spatial{1}.realign{1}.estwrite.eoptions.fwhm = 5;
    jobs{1}.spatial{1}.realign{1}.estwrite.roptions.interp = 4;
    jobs{1}.spatial{1}.realign{1}.estwrite.roptions.wrap = [0 0 0];
    jobs{1}.spatial{1}.realign{1}.estwrite.roptions.mask = 1;
    jobs{1}.spatial{1}.realign{1}.estwrite.roptions.which = [0 1];
    save('realign','jobs');
    spm_jobman('run',jobs);
end
return

function coregister(suj_path)
%%%searches in path if struct exist
%coregister the s img with the mean img;
global Session_filter im_format;
Session=get_directories(fullfile(suj_path,Session_filter));
D=dir(suj_path);
if any(strcmp({D.name},'struct'));%if the structural img exist
    jobs{1}.spatial{1}.coreg{1}.estimate.ref = {fullfile(suj_path,Session{1},spm_select('List',fullfile(suj_path,Session{1}), ['^mean.*' im_format]))};
    jobs{1}.spatial{1}.coreg{1}.estimate.source = {fullfile(suj_path,'struct',spm_select('List',fullfile(suj_path,'struct'), ['^s.*' im_format]))};
    jobs{1}.spatial{1}.coreg{1}.estimate.other{1}           = char(['']);
    jobs{1}.spatial{1}.coreg{1}.estimate.eoptions.cost_fun  = char(['nmi']);
    jobs{1}.spatial{1}.coreg{1}.estimate.eoptions.sep       = [4 2];
    jobs{1}.spatial{1}.coreg{1}.estimate.eoptions.tol       = reshape(double([0.02; 0.02; 0.02; 0.001; 0.001; 0.001; 0.01; 0.01; 0.01; 0.001; 0.001; 0.001;]),[1,12]);
    jobs{1}.spatial{1}.coreg{1}.estimate.eoptions.fwhm      = [7 7];
    save('coreg','jobs');
    spm_jobman('run',jobs);
end
return

function slice_timing(suj_path,im_style)
%%%searches in path for sessions, corrects for different slice times,
%%%writes new file prefixed by 'a' and moves them into a folder 'a...',
cd(suj_path);
global TR  Session_filter im_format;
Session=get_directories(fullfile(suj_path,Session_filter));
count =0;
if ~isempty(Session) & ~strcmp('FACELO',Session{1})
    for iii=1:length(Session)
        im_sess = fullfile(suj_path,Session{iii});
        jobs{1}.temporal{1}.st.scans{iii} = [repmat([im_sess filesep],size(spm_select('List',im_sess,['^' im_style '.*' im_format]),1),1) spm_select('List',im_sess,['^' im_style '.*' im_format])];
    end
    %find number of slices
    V=spm_vol(jobs{1}.temporal{1}.st.scans{1}(1,:));
    jobs{1}.temporal{1}.st.nslices = V.dim(3);
    jobs{1}.temporal{1}.st.tr = TR;
    jobs{1}.temporal{1}.st.ta = jobs{1}.temporal{1}.st.tr-jobs{1}.temporal{1}.st.tr/jobs{1}.temporal{1}.st.nslices;
    jobs{1}.temporal{1}.st.so = jobs{1}.temporal{1}.st.nslices:-1:1; %descending
    jobs{1}.temporal{1}.st.refslice = ceil(jobs{1}.temporal{1}.st.nslices/2); %middle slice as reference
elseif ~isempty(Session) & findstr('FACELO',Session{1})
    %loading the job
    count = count +1;
    for iii=1
        im_sess = fullfile(suj_path,Session{iii});
        jobs{1}.temporal{1}.st.scans{iii} = [repmat([im_sess filesep],size(spm_select('List',im_sess,['^' im_style '.*' im_format]),1),1) spm_select('List',im_sess,['^' im_style '.*' im_format])];
    end
    %find number of slices
    V=spm_vol(jobs{1}.temporal{1}.st.scans{1}(1,:));
    jobs{1}.temporal{1}.st.nslices = V.dim(3);
    jobs{1}.temporal{1}.st.tr = TR;
    jobs{1}.temporal{1}.st.ta = jobs{1}.temporal{1}.st.tr-jobs{1}.temporal{1}.st.tr/jobs{1}.temporal{1}.st.nslices;
    jobs{1}.temporal{1}.st.so = jobs{1}.temporal{1}.st.nslices:-1:1; %descending
    jobs{1}.temporal{1}.st.refslice = ceil(jobs{1}.temporal{1}.st.nslices/2); %middle slice as reference

    count = count + 1;
    for iii=2:length(Session)
        im_sess = fullfile(suj_path,Session{iii});
        jobs{1}.temporal{count}.st.scans{iii-1} = [repmat([im_sess filesep],size(spm_select('List',im_sess,['^' im_style '.*' im_format]),1),1) spm_select('List',im_sess,['^' im_style '.*' im_format])];
    end

    %find number of slices
    V=spm_vol(jobs{1}.temporal{count}.st.scans{1}(1,:));
    jobs{1}.temporal{count}.st.nslices = V.dim(3);
    jobs{1}.temporal{count}.st.tr = TR;
    jobs{1}.temporal{count}.st.ta = jobs{1}.temporal{1}.st.tr-jobs{1}.temporal{1}.st.tr/jobs{1}.temporal{1}.st.nslices;
    jobs{1}.temporal{count}.st.so = jobs{1}.temporal{1}.st.nslices:-1:1; %descending
    jobs{1}.temporal{count}.st.refslice = ceil(jobs{1}.temporal{1}.st.nslices/2); %middle slice as reference
end
save('slicetiming','jobs');
spm_jobman('run',jobs);
move_files(suj_path,im_style,['a' im_style]);
return

function normalise(suj_path, im_style)
%%%searches in path for sessions, normalises images indicated by im_style,
%%%using parameters from first scan in sessions, writes new file prefixed by 'w'
%%%and moves them into a folder 'w...', which is located at the same level as 'f'

global Session_filter im_format path_spm5;
Session=get_directories(fullfile(suj_path,Session_filter));
cd(suj_path);

if ~isempty(Session)
    %loading the job
    %source image is the mean image generated in the realignment step
    jobs{1}.spatial{1}.normalise{1}.estwrite.subj.source = {fullfile(suj_path,Session{1},spm_select('List',fullfile(suj_path,Session{1}), ['^meanf.*' im_format]))};
    %initialisation of .resample
    jobs{1}.spatial{1}.normalise{1}.estwrite.subj.resample=[];
    for iii=1:length(Session)
        im_sess = fullfile(suj_path,Session{iii},im_style);
        this_session_images=cellstr([repmat([im_sess filesep],size(spm_select('List',im_sess,['^' im_style '.*' im_format]),1),1) spm_select('List',im_sess,['^' im_style '.*' im_format])]);
        jobs{1}.spatial{1}.normalise{1}.estwrite.subj.resample=[jobs{1}.spatial{1}.normalise{1}.estwrite.subj.resample {this_session_images{1:end}}];
    end
    jobs{1}.spatial{1}.normalise{1}.estwrite.subj.wtsrc = {};
    %template path
    jobs{1}.spatial{1}.normalise{1}.estwrite.eoptions.template{1} = [path_spm5 filesep 'templates' filesep 'EPI.nii,1'];
    %other parameters
    jobs{1}.spatial{1}.normalise{1}.estwrite.eoptions.weight = {};
    jobs{1}.spatial{1}.normalise{1}.estwrite.eoptions.smosrc = 8;
    jobs{1}.spatial{1}.normalise{1}.estwrite.eoptions.smoref = 0;
    jobs{1}.spatial{1}.normalise{1}.estwrite.eoptions.regtype = 'mni';
    jobs{1}.spatial{1}.normalise{1}.estwrite.eoptions.cutoff = 25;
    jobs{1}.spatial{1}.normalise{1}.estwrite.eoptions.nits = 16;
    jobs{1}.spatial{1}.normalise{1}.estwrite.eoptions.reg = 1;
    jobs{1}.spatial{1}.normalise{1}.estwrite.roptions.preserve = 0;
    jobs{1}.spatial{1}.normalise{1}.estwrite.roptions.bb = [-78 -112 -50;78 76 85];
    jobs{1}.spatial{1}.normalise{1}.estwrite.roptions.vox = [3 3 3]; %default [2 2 2]
    jobs{1}.spatial{1}.normalise{1}.estwrite.roptions.interp = 1;
    jobs{1}.spatial{1}.normalise{1}.estwrite.roptions.wrap = [0 0 0];
    
    D=dir(suj_path); %if struct exist, it is also normalised bu in 1 1 1 vox size
    if any(strcmp({D.name},'struct'));
        struct_img = {fullfile(suj_path,'struct',spm_select('List',fullfile(suj_path,'struct'), ['^s.*' im_format]))};
        jobs{1}.spatial{1}.normalise{2}.write.subj.matname = {[jobs{1}.spatial{1}.normalise{1}.estwrite.subj.source{1}(1,1:findstr(im_format,jobs{1}.spatial{1}.normalise{1}.estwrite.subj.source{1})-2) '_sn.mat']};
        jobs{1}.spatial{1}.normalise{2}.write.subj.resample = struct_img;
        jobs{1}.spatial{1}.normalise{2}.write.roptions.bb = [-78 -112 -50;78 76 85];
        jobs{1}.spatial{1}.normalise{2}.write.roptions.vox = [1 1 1]; %default [2 2 2]
        jobs{1}.spatial{1}.normalise{2}.write.roptions.interp = 1;
        jobs{1}.spatial{1}.normalise{2}.write.roptions.wrap = [0 0 0];
    end

    save('normalize','jobs');
    spm_jobman('run',jobs);
    move_files(suj_path,im_style,['w' im_style]);
end
return

function smooth(suj_path, im_style)
%%%searches in path for sessions, smooths images indicated by im_style,
%%%writes new files prefixed by 's' and moves them into a folder 's...', which
%%%is located at the same level as 'f'
cd(suj_path);
global Session_filter im_format;
Session=get_directories(fullfile(suj_path,Session_filter));
if ~isempty(Session)
    jobs{1}.spatial{1}.smooth.data=[];
    for iii=1:length(Session)
        im_sess = fullfile(suj_path,Session{iii},im_style);
        this_session_images=cellstr([repmat([im_sess filesep],size(spm_select('List',im_sess,['^' im_style '.*' im_format]),1),1) spm_select('List',im_sess,['^' im_style '.*' im_format])]);
        jobs{1}.spatial{1}.smooth.data=[jobs{1}.spatial{1}.smooth.data {this_session_images{1:end}}];
    end
    jobs{1}.spatial{1}.smooth.fwhm                          = [8 8 8];
    jobs{1}.spatial{1}.smooth.dtype                         = 0;
    save('smooth','jobs');
    spm_jobman('run',jobs);
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

%------------------------------%
% if you have speficic names or a specific order for the sessions, specify it here
% if you have normal names, like EXP_run1, EXP_run2, etc, keep it commanded

% dirs = {'morphing_titrage_run1',...
%         'morphing_titrage_run2',...
%         'morphing_test_run5',...
%         'morphing_faceloc_run11'};
%------------------------------%
return