function [] = Labnic_rfx_anova_with_covariates_spm8
% create the second level analyis (random effect analysis RFX)
% create an ANOVA with 2 factors in this example
% you must specified the 4 first lines of the script
% name_ana_grp is the directory for the main RFX analysis
% Analysis of each subjects must be in:
% **...\populations\subjects\analyse\ana1\**
 
%% parameters to specify for each study %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
myjob = [1 1];                                          % myjob(1)==1 : build + estimate model myjob(2)==1 : build contrasts
root_path = 'e:\Data XP\fMRI EWA\data_fMRI\';         % directory where are the populations, main directory
name_ana_ind = '3. analyse\quadriface\';              % Folder name of 1st level analysis
name_ana_grp = 'grp_analysis\Quadri_ANOVA12_21S';       % name for the directory of the random analysis
cons = [3:6 8:11 13:16];                                             % which contrast is it in the 1st level analysis?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dirstr = strcat(root_path,name_ana_grp);
ncon = length(cons);

if myjob(1)
    %% defining the subject list
    dbstop if error
    cd (root_path)
    Subject{1}= spm_select(Inf,'dir','which subjects do you want to process?');
    
    Subject = char(Subject);
    nsuj = size(Subject,1);
    
    %% Creation of directory for the rfx
    if ~exist(strcat(root_path,name_ana_grp))
        mkdir(strcat(root_path,name_ana_grp))
    end
    cd (dirstr)
    fnm = 'con';
    
    answer_sphericity = questdlg('Do you want to correct for potential violations of sphericity of the factor condition ?','Sphericity correction', 'Yes' , 'No' ,'Yes');   
    answer_sphericity = strcmp(answer_sphericity, 'Yes');
    
    %% defining the factors
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'condition'; % first factor condition
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name = 'subject'; % second factor subject

    %% Dependance within factors
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 1; % Conditions are dependant (=1) because the measure is performed several times within each subject
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept = 0; % Subjects are independant (=0) because they are assumed to pertain to the same group
    
    %% Variance within factors (ie sphericity assumed or not)
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = answer_sphericity;   % Unequal variance assumed (0: equal; 1:unequal)
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance = 0;                   % Unequal variance assumed (0: equal; 1:unequal)
    
    %% get the images from each subject
    for s = 1:nsuj
        su = deblank(Subject(s,:));
        scans = [];
        conds = [];
        for cond = 1:ncon
            con = cons(cond);
            scans = [scans;{sprintf('%s%s%s%s%s_%04d.img',su,filesep,name_ana_ind,filesep,fnm,con)}];
            conds = [conds; cond s];
        end
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(s).scans = scans;
        matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(s).conds = conds;
    end
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.fmain.fnum = 1;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.fmain.fnum = 2;
    matlabbatch{1}.spm.stats.factorial_design.dir = {dirstr};
    
    %% covariates if any
    % matlabbatch{1}.spm.stats.factorial_design.cov(1).c = [10,9,11,7,10,9,3,7,11,10,10,8,6,10,7,10,2,5,7,3,10,4,6,7,2,1,11,9,8,6,4,8,];
    % matlabbatch{1}.spm.stats.factorial_design.cov(1).cname = 'age';%name of the covariate
    % matlabbatch{1}.spm.stats.factorial_design.cov(1).iCFI = 2;
    % matlabbatch{1}.spm.stats.factorial_design.cov(1).iCC = 1;% do you want interaction with factor iCFI-1?
    
    matlabbatch{2}.spm.stats.fmri_est.spmmat = {[dirstr filesep 'SPM.mat']};
    matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
    save('ANOVA','matlabbatch') %save the .mat
    spm_jobman('run',matlabbatch);
    
end

if myjob(2)
    %% Contrast part
    cd (dirstr)
    load ([dirstr filesep 'SPM.mat'])
    SPM = rmfield(SPM,'xCon');
    matlabbatch = [];
    
    matlabbatch{1}.spm.stats.con.spmmat = {[pwd filesep 'SPM.mat']};
    matlabbatch{1}.spm.stats.con.consess{1}.fcon.name = 'F(Task)';
    matlabbatch{1}.spm.stats.con.consess{1}.fcon.convec = {ones(ncon)*(-1/ncon)+eye(ncon)};
    matlabbatch{1}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
    matlabbatch{1}.spm.stats.con.delete = 1;
    
    spm_jobman('run',matlabbatch);  
end

return