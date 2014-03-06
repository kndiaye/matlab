function [] = Labnic_rfx_twos_spm5

% create the second level analyis (random effect analysis RFX)
% create a two sample t-test between 2 populations of subjects

% you must speficied the 3 first line of the script
% dirname is the direcotry for the main RFX analysis
% it create a dir for each contrast in this main dir
% this code take into account that some of the subjects do not have all the
% contrasts
% Analysis of each subjects must be in:
% **...\data_fMRI\populations\subjects\analyse\ana1\**
% At the beginning, the script create a mean structural image to display the
% results of the group analysis

% this function has been adapted by Virginie Sterpenich (Virginie.Sterpenich@unige.ch)

global name_ana;

%% parameters to specify for each study
root_path = 'D:\vs1'; % directory where are the populations, main directory
name_ana = 'ana1'; %or 'ana2'; etc
dirname = ['RFX_ana_2s']; % name for the directory of the random analysis

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

%% Creation of directory for the rfx
dirstr = strcat(root_path,filesep,dirname);
if ~exist(strcat(root_path,filesep,dirname))
    mkdir(strcat(root_path,filesep,dirname))
end

%% create mean structural image to display results of the group
disp('Creating mean structural image');
PM   = cell(nsuj,1);
ii=0;
for sub = 1:nsuj
    %go to the subject's analyse folder
    sufolder= deblank(Subject(sub,:));
    path_ana =[sufolder 'scans' filesep 'struct'];
    eval(['cd ' path_ana]);
    % select the struct img
    struct_img = spm_select('List',path_ana,'^ws*');
    PM{sub} = [path_ana filesep struct_img];
    ii=ii+1;
end
% create the expression for the mean
expression = '(i';
for jj = [1:ii]
    expression = [expression  num2str(jj) '+i'];
end
expression = [expression(1:end-2) ')/' num2str(ii)];
% fil the job and calculate
jobs{1}.util{1}.imcalc.input = PM;
jobs{1}.util{1}.imcalc.output =  strcat([dirstr filesep 'meanstruct.nii']);
jobs{1}.util{1}.imcalc.expression = expression;

jobs{1}.util{1}.imcalc.options.dmtx = 0;
jobs{1}.util{1}.imcalc.options.mask = 0;
jobs{1}.util{1}.imcalc.options.interp = 0;
jobs{1}.util{1}.imcalc.options.dtype = 4;
% run the job
spm_jobman('run',jobs)
clear jobs

%% starting analysing

cd(dirstr)
% load the names of the contrasts from the first subject
% it use the contrasts_name matrix created in the Labnic_contrast script
path_suj1 =[Subject(1,:) 'analyse' filesep name_ana];
load(strcat(path_suj1,filesep,'contrasts_name'));
%     Cnames = Cnames(:,[2:7]);% if you don't want analyse all the contrasts (ex: only 2 to 7)
nb_con = size(Cnames,2);

% loop over contrasts
for icon = 1:nb_con
    defaults.modality='FMRI';
    disp(['Processing contrast ' num2str(icon) ' : ' char(Cnames(icon))]);
    disp('-----------------------------');
    %initialise variables
    P   = {}; scans1 = {}; scans2 = {};
    % go to the main dir
    cd(dirstr)
    % Create the dir for the contrast of interest
    mkdir(char(Cnames(icon)));

    % loop over subjects
    for sub = 1:nsuj
        %go to the subject's analyse folder
        path_ana =[deblank(Subject(sub,:)) 'analyse' filesep name_ana];
        eval(['cd ' path_ana]);
        %select SPM.mat
        load SPM
        % check the name of the contrast
        % Find for this subject the con.img corresponding to the contrast of interest (icon)
        % This works even if the name of the con.img differs from one subject to the other !watch out for multiple matches!
        contrastindice = [];
        for icontrast = 1:size(SPM.xCon,2)
            contrastmatch = findstr(SPM.xCon(icontrast).name,Cnames{icon});
            if  ~isempty(contrastmatch)
                contrastindice = icontrast;
                break
            end
        end
        %%alternative to loop above, adding some error messages
        %contrastmatch = find(~cellfun('isempty',regexp(cellstr(char(SPM.xCon.name)),Cnames{icon})));
        %   if  isempty(contrastmatch) ...no contrast was found
        %       error('No matching contrast found - check names');
        %   elseif length(contrastmatch)>1 ... more than 1 contrasts found
        %       error('Multiple matches found - check names');
        %   else
        %       contrastindice = icontrast; ...found exactly 1 match
        %   end

        % Take the adequate 'con' img
        if ~isempty(contrastindice)% au cas ou le contraste n'existe pas chez un sujet
            if contrastindice < 10
                str = ['^con_000+' num2str(contrastindice) filesep '.img$'];
            elseif contrastindice < 100
                str = ['^con_00+' num2str(contrastindice) filesep '.img$'];
            else
                str = ['^con_0+' num2str(contrastindice) filesep '.img$'];
            end
            files = spm_select('List',pwd,str);
            P{end+1,1} = strcat(path_ana,filesep,files,',1');
            % put the image con in the appropriate group
            if any(strcmp(P{end}(1:size(deblank(Population(1,:)),2)),deblank(Population(1,:))));
                scans1{end+1,1} = P{end,:};
            elseif any(strcmp(P{end}(1:size(deblank(Population(2,:)),2)),deblank(Population(2,:))));
                scans2{end+1,1} = P{end,:};
            end
        end
        clear SPM
    end % end isub loop
    %affiche les img con sélectionnées
    scans1
    scans2
    % fil the job
    jobs{1}.stats{1}.factorial_design.des.t2.scans1 = scans1;
    jobs{1}.stats{1}.factorial_design.des.t2.scans2 = scans2;
    jobs{1}.stats{1}.factorial_design.dir = {char(strcat(dirstr,filesep,Cnames{icon}))};
    % normal parameters
    jobs{1}.stats{1}.factorial_design.des.t2.dept = 0;
    jobs{1}.stats{1}.factorial_design.des.t2.variance = 1;
    jobs{1}.stats{1}.factorial_design.des.t2.gmsca = 0;
    jobs{1}.stats{1}.factorial_design.des.t2.ancova = 0;
    jobs{1}.stats{1}.factorial_design.masking.tm.tm_none = [];
    jobs{1}.stats{1}.factorial_design.masking.im = 1;
    jobs{1}.stats{1}.factorial_design.masking.em = {''};
    jobs{1}.stats{1}.factorial_design.globalc.g_omit = [];
    jobs{1}.stats{1}.factorial_design.globalm.gmsca.gmsca_no = [];
    jobs{1}.stats{1}.factorial_design.globalm.glonorm = 1;

    % run the job for the design specification
    spm_jobman('run',jobs)
    clear jobs

    %% Estimate parameters
    cd(strcat(dirstr,filesep,Cnames{icon}))
    load SPM
    SPM = spm_spm(SPM);

    %% Create contrasts
    % select the SPM.mat
    jobs{1}.stats{1}.con.spmmat = {char(strcat(dirstr,filesep,Cnames{icon},filesep,'SPM.mat'))};

    % precise the contrasts between both groups
    jobs{1}.stats{1}.con.consess{1}.tcon.name = 'Gr1 vs Gr2';
    jobs{1}.stats{1}.con.consess{1}.tcon.convec = [1 -1];
    jobs{1}.stats{1}.con.consess{1}.tcon.sessrep = 'none';

    jobs{1}.stats{1}.con.consess{2}.tcon.name = 'Gr2 vs Gr1';
    jobs{1}.stats{1}.con.consess{2}.tcon.convec = [-1 1];
    jobs{1}.stats{1}.con.consess{2}.tcon.sessrep = 'none';

    jobs{1}.stats{1}.con.consess{3}.tcon.name = 'Gr1';
    jobs{1}.stats{1}.con.consess{3}.tcon.convec = [1 0];
    jobs{1}.stats{1}.con.consess{3}.tcon.sessrep = 'none';

    jobs{1}.stats{1}.con.consess{4}.tcon.name = 'Gr2';
    jobs{1}.stats{1}.con.consess{4}.tcon.convec = [0 1];
    jobs{1}.stats{1}.con.consess{4}.tcon.sessrep = 'none';

    jobs{1}.stats{1}.con.consess{5}.tcon.name = 'Gr1_and_Gr2';
    jobs{1}.stats{1}.con.consess{5}.tcon.convec = [1 1];
    jobs{1}.stats{1}.con.consess{5}.tcon.sessrep = 'none';
    % run the job
    spm_jobman('run',jobs)
    clear jobs
    cd(dirstr)

end % end icond loop over contrasts
return