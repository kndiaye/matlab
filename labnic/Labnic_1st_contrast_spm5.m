function [] = Labnic_contrast_spm5
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

global name_ana;

%% parameters to specify for each study
root_path = 'D:\'; % directory where are the populations, main directory
name_ana = 'ana'; %or 'ana2'; etc

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

%% starting analysing
for pop = 1:npop
    % go to the population folder
    Pop{pop} = deblank(Population(pop,:));
    sep_pop = findstr(filesep,Pop{pop});
    popu = Pop{pop}(1,sep_pop(end-1)+1:sep_pop(end));
    for sub = 1:nsuj
        %go to the subject's analyse folder
        sufolder= deblank(Subject(sub,:));
        path_ana =[sufolder 'analyse' filesep name_ana];
        eval(['cd ' path_ana]);
        %select SPM.mat
        [files]=spm_select('List',path_ana,'^SPM.mat$');
        jobs{1}.stats{1}.con.spmmat = {fullfile(path_ana,files)};
        % create the F contrasts
        [Cf,Cnamesf] = f_con;
        for iconf = 1:size(Cf,2)
            % put the contrast in the job
            jobs{1}.stats{1}.con.consess{iconf}.fcon.name = Cnamesf{iconf};
            jobs{1}.stats{1}.con.consess{iconf}.fcon.convec = {Cf{iconf}};
        end
        
%         create the T contrasts
        [Ct,Cnamest] = t_con;
        for icont = 1:size(Ct,1)
            % put the contrast in the job
            jobs{1}.stats{1}.con.consess{iconf+icont}.tcon.name = Cnamest{icont};
            jobs{1}.stats{1}.con.consess{iconf+icont}.tcon.convec = Ct(icont,:);
        end
        % save a matrix with the names of the contrasts
        eval('save contrasts_name Ct Cnamest');
        eval('save contrast jobs');
        % run the job
        spm_jobman('run',jobs)
    end
end

%% FUNCTION SECTION: create contrasts

function [Cf,Cnamesf] = f_con
load SPM
SPM.xCon = [];
save SPM SPM

Cf = []; Cnamesf = [];
for i = 1:length(SPM.xX.name)% creating a variable connam which contain all possible contrasts
    b = strfind(SPM.xX.name{i},'*bf');
    connam{i} = SPM.xX.name{i}(7:b-1);
end

%% then named the contrasts
Lbissec_placebo = double(strcmp(connam,'Lbissec_placebo'));

Cnamesf{end+1} = 'F-Task';
Cf{end+1} = [Lbissec_placebo;Mbissec_placebo;Rbissec_placebo;Lmemo_placebo;Mmemo_placebo;Rmemo_placebo;Lsearch_placebo;Msearch_placebo;Rsearch_placebo;...
    Lbissec_nico;Mbissec_nico;Rbissec_nico;Lmemo_nico;Mmemo_nico;Rmemo_nico;Lsearch_nico;Msearch_nico;Rsearch_nico];% example

return

function [Ct,Cnamest] = t_con
load SPM

Ct = []; Cnamest = [];
for i = 1:length(SPM.xX.name)% creating a variable connam which contain all possible contrasts
    b = strfind(SPM.xX.name{i},'*bf');
    connam{i} = SPM.xX.name{i}(7:b-1);
end

%% then named the contrasts
Mmemo_nico = double(strcmp(connam,'Mmemo_nico'));

Cnamest{end+1} = 'Lbissec_placebo';
Ct(end+1,:) = Lbissec_placebo;% example

return