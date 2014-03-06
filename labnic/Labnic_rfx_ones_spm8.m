function [] = Labnic_rfx_ones_spm8
% create the second level analyis (random effect analysis RFX)
% create a one sample t-test with one group of subjects

% you must speficied the 3 first line of the script
% dirname is the direcotry for the main RFX analysis
% it create a dir for each contrast in this main dir
% this code take into account that some of the subjects do not have all the
% contrasts
% Analysis of each subjects must be in:
% **...\data_fMRI\populations\subjects\analyse\ana1\**
% At the begining, the script create a mean strucutral image to display the
% results of the group analysis

% this function has been adapted by Virginie Sterpenich (Virginie.Sterpenich@unige.ch)
% and optimised by Yann Cojan (yann.cojan@unige.ch)

global name_ana;

%% parameters to specify for each study
root_path = 'C:\experiments\FLANKER\'; % directory where are the populations, main directory
name_ana = 'ana_woST\'; %or 'ana2'; etc
dirname = 'RFX\RFX_ones_hypnosis_subjective_31s'; % name for the directory of the random analysis

%% defining the pop_style
cd ([root_path filesep 'controls'])
Subject{1}= spm_select(Inf,'dir','which subjects do you want to process?');
Subject = char(Subject);
nsuj = size(Subject,1);

%% Creation of directory for the rfx
dirstr = strcat(root_path,filesep,dirname);
if ~exist(strcat(root_path,filesep,dirname))
    mkdir(strcat(root_path,filesep,dirname))
end
cd(dirstr)

%% starting analysing
% load the names of the contrasts from the first subject
% it use the contrasts_name matrix created in the Labnic_contrast script
path_suj1 =[deblank(Subject(1,:)) 'analyse' filesep name_ana];

% loop over contrasts

% defaults.modality='FMRI';
% disp(['Processing contrast ' num2str(icon) ' : ' char(Cnames(icon))]);
% disp('-----------------------------');
%initialise variables
P   = {}; scans = {};

% % Create the dir for the contrast of interest
% mkdir(char(Cnames(icon)));
Cnames = {'slatency_Cf' 'slatency_If' 'slatency_Cs' 'slatency_Is' 'slatency_ECf' 'slatency_EIf' 'slatency_ECs' 'slatency_EIs'};
nb_con = size(Cnames,2);
% loop over subjects
count = 0;
for sub = 1:nsuj
    count = count+1;
    %go to the subject's analyse folder
    path_ana =[deblank(Subject(sub,:)) 'analyse' filesep name_ana];
    
    % check the name of the contrast
    % Find for this subject the con.img corresponding to the contrast of
    % interest (icon)
    con = 0;
    for icon = 1:nb_con %for td %10:19 %for hrf  % 20:26 %for tdd %  depending on F and T contrast at the first level
        con = con+1;
        if sub == 1 %for initialising the struct
            matlabbatch{con}.spm.stats.factorial_design.des.t1.scans = {};
            matlabbatch{con}.spm.stats.factorial_design.dir = {char(strcat(dirstr,filesep,Cnames{icon}))};
            if ~exist(matlabbatch{con}.spm.stats.factorial_design.dir{1})
                mkdir(matlabbatch{con}.spm.stats.factorial_design.dir{1})
            end
        end
        %% mask
        matlabbatch{con}.spm.stats.factorial_design.masking.im = 0;
        matlabbatch{con}.spm.stats.factorial_design.masking.em = {'C:\experiments\FLANKER\RFX\RFX_anova_woST\mask.img,1'};
        % Take the adequate 'latency' img
        str = Cnames{icon};
        files = spm_select('ExtFPList',path_ana,str);
        % put the image con in the appropriate group
        matlabbatch{con}.spm.stats.factorial_design.des.t1.scans{end+1} = files;
        
        
        %         %matlabbatch{con}.spm.stats.factorial_design.cov(1).c = [139 198
        %         178 184 161 172 123 142 125 174 214 177 102 145 121 136 174 109 105 139 175 131 148 130 142 183 ]';
        matlabbatch{con}.spm.stats.factorial_design.cov(1).c = [10,9,11,7,10,9,3,7,11,10,10,8,6,10,7,10,2,5,7,3,10,4,6,7,2,1,11,9,8,6,4,8;]'; %hypnosis subj
        matlabbatch{con}.spm.stats.factorial_design.cov(1).cname = 'hypnosis subjective';
        matlabbatch{con}.spm.stats.factorial_design.cov(1).iCFI = 1;
        matlabbatch{con}.spm.stats.factorial_design.cov(1).iCC = 1;
        
        %         matlabbatch{con}.spm.stats.factorial_design.cov(1).c = [527.93,430.56,544.31,437.01,418.69,606.21,516.66,373.88,612.50,499.77,430.23,577.45,462.00,454.70,460.17,521.39,395.60,429.86,531.31,484.48,465.62,426.93,420.84,681.16,638.34,447.86,407.31,461.15,370.47,473.02]';
        %         matlabbatch{con}.spm.stats.factorial_design.cov(1).cname = 'reaction time';
        %         matlabbatch{con}.spm.stats.factorial_design.cov(1).iCFI = 1;
        %         matlabbatch{con}.spm.stats.factorial_design.cov(1).iCC = 1;
        %
        %         matlabbatch{con}.spm.stats.factorial_design.cov(2).c = [23.18,27.08,80.97,25.36,17.07,73.28,36.61,21.03,22.30,42.92,34.49,116.21,57.44,54.08,40.86,24.04,33.38,58.98,33.16,83.69,58.14,15.97,34.38,-22.34,10.28,78.25,19.23,19.67,49.42,10.67,52.88]';
        %         matlabbatch{con}.spm.stats.factorial_design.cov(2).cname = 'incongruency effect';
        %         matlabbatch{con}.spm.stats.factorial_design.cov(2).iCFI = 1;
        %         matlabbatch{con}.spm.stats.factorial_design.cov(2).iCC = 1;
        %
        %         matlabbatch{con}.spm.stats.factorial_design.cov(2).c = [-7.2105,1.6933,-10.3191,-5.9564,12.103,-27.4546,11.0383,-8.5667,-9.85,4.7017,-4.4777,5.3444,-17.0412,-7.1307,4.0314,7.9951,-5.6508,14.6891,-17.6318,10.7182,-2.3345,4.404,9.8678,6.1827,5.8837,-1.9921,8.745,-5.7231,-2.1239,-3.0548;]';
        %         matlabbatch{con}.spm.stats.factorial_design.cov(2).cname = 'TR_F-S';
        %         matlabbatch{con}.spm.stats.factorial_design.cov(2).iCFI = 1;
        %         matlabbatch{con}.spm.stats.factorial_design.cov(2).iCC = 1;
        
        %                 matlabbatch{con}.spm.stats.factorial_design.cov(2).c = [-18.9881,-24.9904,-85.9272,-28.1663,-7.4509,-69.0327,-33.1592,-21.4825,-22.5177,-31.5774,-30.9564,-119.0013,-63.5359,-54.963,-36.2025,-19.6949,-36.909,-57.6552,-38.0087,-91.712,-55.8303,-16.1885,-24.5821,23.7739,-69.5856,-16.0828,-14.7308,-50.3663,-10.876,-47.7222;]';
        %                 matlabbatch{con}.spm.stats.factorial_design.cov(2).cname = 'TR_Cf-If';
        %                 matlabbatch{con}.spm.stats.factorial_design.cov(2).iCFI = 1;
        %                 matlabbatch{con}.spm.stats.factorial_design.cov(2).iCC = 1;
        %
        %                 matlabbatch{con}.spm.stats.factorial_design.cov(2).c = [20.0982,31.4695,72.5183,18.2599,27.5145,81.5441,52.4209,16.9066,7.8373,56.2911,37.8267,129.6121,59.0775,51.9855,40.9023,30.59,33.1506,63.7293,33.5807,88.6858,59.559,17.5099,38.3411,-39.5562,90.8655,21.9729,24.6094,44.8306,14.6509,53.9644;]';
        %                 matlabbatch{con}.spm.stats.factorial_design.cov(2).cname = 'TR_Cs-Is';
        %                 matlabbatch{con}.spm.stats.factorial_design.cov(2).iCFI = 1;
        %                 matlabbatch{con}.spm.stats.factorial_design.cov(2).iCC = 1;
        
        %         matlabbatch{con}.spm.stats.factorial_design.cov(2).c =  [-3.0502,4.0862,-11.864,-7.9314,16.0833,-7.4716,15.15,-6.5713,-12.2652,14.7077,1.1963,7.9776,-10.7498,-5.0541,4.3656,9.4451,-4.7046,10.3816,-11.0299,3.846,0.6971,2.8627,11.8134,-4.7998,13.5818,1.949,9.3118,-5.6294,0.8255,1.5937;]';
        %         matlabbatch{con}.spm.stats.factorial_design.cov(2).cname = 'TR_Cf-Cs';
        %         matlabbatch{con}.spm.stats.factorial_design.cov(2).iCFI = 1;
        %         matlabbatch{con}.spm.stats.factorial_design.cov(2).iCC = 1;
        
        %         matlabbatch{con}.spm.stats.factorial_design.cov(2).c = [-4.1603,-2.6332,-1.9456,-7.6981,-3.9411,-0.5668,-0.0937,-2.9494,-4.6485,-2.3929,1.5449,1.975,-3.9803,-19.983,-4.1117,-1.9954,2.4152,-10.006,-5.674,-6.2914,-2.0766,-0.3342,-1.45,-0.9462,4.3075,-6.6019,6.8722,-3.0316,1.5413,10.9825;]';
        %         matlabbatch{con}.spm.stats.factorial_design.cov(2).cname = 'TR_If-Is';
        %         matlabbatch{con}.spm.stats.factorial_design.cov(2).iCFI = 1;
        %         matlabbatch{con}.spm.stats.factorial_design.cov(2).iCC = 1;
        
        if sub == 1 %for initialising the struct
            matlabbatch{con}.spm.stats.factorial_design.masking.tm.tm_none = [];
            matlabbatch{con}.spm.stats.factorial_design.masking.im = 1;
            matlabbatch{con}.spm.stats.factorial_design.masking.em = {''};
            matlabbatch{con}.spm.stats.factorial_design.globalc.g_omit = [];
            matlabbatch{con}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = [];
            matlabbatch{con}.spm.stats.factorial_design.globalm.glonorm = 1;% precise the contrasts between both groups
        end
        %% for estimation
        con = con+1;
        matlabbatch{con}.spm.stats.fmri_est.spmmat = {char(strcat(dirstr,filesep,Cnames{icon},filesep,'SPM.mat'))};
        matlabbatch{con}.spm.stats.fmri_est.method = 1;
        %% for creating contrasts
        con = con+1;
        matlabbatch{con}.spm.stats.con.spmmat = {char(strcat(dirstr,filesep,Cnames{icon},filesep,'SPM.mat'))};
        matlabbatch{con}.spm.stats.con.consess{1}.tcon.name = Cnames{icon};
        matlabbatch{con}.spm.stats.con.consess{1}.tcon.convec = 1;
        matlabbatch{con}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        %         matlabbatch{con}.spm.stats.con.consess{2}.tcon.name = ['-' Cnames{icon}];
        %         matlabbatch{con}.spm.stats.con.consess{2}.tcon.convec = -1;
        %         matlabbatch{con}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{con}.spm.stats.con.consess{2}.tcon.name = matlabbatch{con-2}.spm.stats.factorial_design.cov(1).cname;
        matlabbatch{con}.spm.stats.con.consess{2}.tcon.convec = [0 1];
        matlabbatch{con}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{con}.spm.stats.con.consess{3}.tcon.name = ['-' matlabbatch{con-2}.spm.stats.factorial_design.cov(1).cname];
        matlabbatch{con}.spm.stats.con.consess{3}.tcon.convec =  [0 -1];
        matlabbatch{con}.spm.stats.con.consess{3}.tcon.sessrep = 'none';
        %         matlabbatch{con}.spm.stats.con.consess{4}.tcon.name = [matlabbatch{con-2}.spm.stats.factorial_design.cov(2).cname];
        %         matlabbatch{con}.spm.stats.con.consess{4}.tcon.convec =  [0 0 1];
        %         matlabbatch{con}.spm.stats.con.consess{4}.tcon.sessrep = 'none';
        %         matlabbatch{con}.spm.stats.con.consess{5}.tcon.name = ['-' matlabbatch{con-2}.spm.stats.factorial_design.cov(2).cname];
        %         matlabbatch{con}.spm.stats.con.consess{5}.tcon.convec =  [0 0 -1];
        %         matlabbatch{con}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
        %         matlabbatch{con}.spm.stats.con.consess{6}.tcon.name = ['-' matlabbatch{con-2}.spm.stats.factorial_design.cov(2).cname];
        %         matlabbatch{con}.spm.stats.con.consess{6}.tcon.convec =  [0 0 -1];
        %         matlabbatch{con}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
        %         matlabbatch{con}.spm.stats.con.consess{5}.tcon.name = matlabbatch{con}.spm.stats{con-2}.factorial_design.cov(2).cname;
        %         matlabbatch{con}.spm.stats.con.consess{5}.tcon.convec = [0 0 1];
        %         matlabbatch{con}.spm.stats.con.consess{5}.tcon.sessrep = 'none';
        %         matlabbatch{con}.spm.stats.con.consess{6}.tcon.name = ['-' matlabbatch{con}.spm.stats{con-2}.factorial_design.cov(2).cname];
        %         matlabbatch{con}.spm.stats.con.consess{6}.tcon.convec =  [0 0 -1];
        %         matlabbatch{con}.spm.stats.con.consess{6}.tcon.sessrep = 'none';
        %
        %         matlabbatch{con}.spm.stats.con.consess{7}.tcon.name = matlabbatch{con}.spm.stats{con-2}.factorial_design.cov(3).cname;
        %         matlabbatch{con}.spm.stats.con.consess{7}.tcon.convec = [0 0 0 1];
        %         matlabbatch{con}.spm.stats.con.consess{7}.tcon.sessrep = 'none';
        %         matlabbatch{con}.spm.stats.con.consess{8}.tcon.name = ['-' matlabbatch{con}.spm.stats{con-2}.factorial_design.cov(3).cname];
        %         matlabbatch{con}.spm.stats.con.consess{8}.tcon.convec =  [0 0 0 -1];
        %         matlabbatch{con}.spm.stats.con.consess{8}.tcon.sessrep = 'none';
        %
        %         matlabbatch{con}.spm.stats.con.consess{9}.tcon.name = matlabbatch{con}.spm.stats{con-2}.factorial_design.cov(4).cname;
        %         matlabbatch{con}.spm.stats.con.consess{9}.tcon.convec = [0 0 0 0 1];
        %         matlabbatch{con}.spm.stats.con.consess{9}.tcon.sessrep = 'none';
        %         matlabbatch{con}.spm.stats.con.consess{10}.tcon.name = ['-' matlabbatch{con}.spm.stats{con-2}.factorial_design.cov(4).cname];
        %         matlabbatch{con}.spm.stats.con.consess{10}.tcon.convec =  [0 0 0 0 -1];
        %         matlabbatch{con}.spm.stats.con.consess{10}.tcon.sessrep = 'none';
        %
        %         matlabbatch{con}.spm.stats.con.consess{11}.tcon.name = 'impulsivity';
        %         matlabbatch{con}.spm.stats.con.consess{11}.tcon.convec = [0 1 1 1 1];
        %         matlabbatch{con}.spm.stats.con.consess{11}.tcon.sessrep = 'none';
        %         matlabbatch{con}.spm.stats.con.consess{12}.tcon.name = '-impulsivity';
        %         matlabbatch{con}.spm.stats.con.consess{12}.tcon.convec =  [0 -1 -1 -1 -1];
        %         matlabbatch{con}.spm.stats.con.consess{12}.tcon.sessrep = 'none';
    end % end icon loop
end % end isub loop
save test_latency matlabbatch
% run the job for the design specification
spm_jobman('run',matlabbatch)

return