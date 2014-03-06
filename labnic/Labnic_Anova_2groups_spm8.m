function [] = Labnic_rfx_anova_2groups

%% parameters to specify for each study
root_path = 'D:\SEXO\'; % directory where are the populations, main directory
name_ana = 'analyse_fMRI\ana_sexo_rating\'; %or 'ana2'; etc
dirname = 'RFX_sexo_2groups'; % name for the directory of the random analysis
cons = [7 9 11 13];% which contrast is it in the 1st level analysis?

%% defining the pop_style
cd (root_path)
Population  = spm_select(Inf,'dir','which population do you want to process?');
npop        = size(Population,1);

%% Definition of subjects to process
for pop=1:npop
    cd(Population(pop,1:end))
    subject{pop}= spm_select(Inf,'dir','which subjects do you want to process?');
end
Subject = char(subject);
nsuj = size(Subject,1);
n1 = size(subject{1},1);
n2 = size(subject{2},1);
%% Creation of directory for the rfx
dirstr = strcat(root_path,dirname);
if ~exist(strcat(root_path,dirname))
    mkdir(strcat(root_path,dirname))
end
cd (dirstr)
ncon = length(cons);

fnm = 'con';
% get image files names
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'group';%second factor
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name = 'condition'; %first factor
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).name = 'subject';

matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 0; %conditions are dept because coming from the same subject
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept = 1; %deriv are dept
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).dept = 0; %subjects are not dept

matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 1; %unequal variance for groups
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance = 0; %equal variance for condition
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).variance = 0; %equal variance for subjects

for s = 1:nsuj
    su = deblank(Subject(s,:));
    scans = [];
    conds = [];
    count = 0;
    for cond = 1:ncon
        count = count+1;
        con = cons(count);
        scans = [scans;{sprintf('%s%s_%04d.img',su,fnm,con)}];
        if s<16
            group = 1;
        else
            group = 2;
        end
        conds = [conds; group cond s];
    end
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(s).scans = scans;
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(s).conds = conds;
end
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.fmain.fnum = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.fmain.fnum = 2;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{3}.inter.fnums = [1 2];
matlabbatch{1}.spm.stats.factorial_design.dir = {dirstr};

%%for covariation
% matlabbatch{1}.spm.stats.factorial_design.cov.c = repmat([20 24 32 23 30 31 24 17 25 26 25 27 21 29 20 21 25 22 29 26 25 25 25 28]',1,ncon);
% %matlabbatch{1}.spm.stats.factorial_design.cov.c = repmat([92 106 92 105 91 96 89 94 107 112 106 107 101 105 87 93 89 105 118 80 95 85 90 105]',1,8);
% matlabbatch{1}.spm.stats.factorial_design.cov.cname = 'impulsivity';
% matlabbatch{1}.spm.stats.factorial_design.cov.iCFI = 1;
% matlabbatch{1}.spm.stats.factorial_design.cov.iCC = 1;

matlabbatch{2}.spm.stats.fmri_est.spmmat = {[dirstr filesep 'SPM.mat']};
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
save('ANOVA_2groups','matlabbatch')
spm_jobman('run',matlabbatch);

%% Contrast part
load ([dirstr filesep 'SPM.mat'])
SPM = rmfield(SPM,'xCon');

%% F contrast
cn=1;
cnam{cn} = 'F-task';
cwgt{cn} = [kron(eye(npop),ones(ncon,1)) repmat(eye(ncon),npop,1)  eye(ncon*npop)];
ctyp{cn} = 'F';
%% main effect of group
cn = cn+1;
cnam{cn} = 'C-P';
cwgt{cn} = [1 -1 zeros(1,ncon) ones(1,ncon)/ncon -ones(1,ncon)/ncon];
ctyp{cn} = 'T';
cn = cn+1;
cnam{cn} = 'P-C';
cwgt{cn} = -cwgt{cn-1};
ctyp{cn} = 'T';

%% main effect of conditions
cn = cn+1;
cnam{cn} = 'E-N';
con = [1 1 -1 -1];
cwgt{cn} = [zeros(1,npop) con con*n1/nsuj con*n2/nsuj];
ctyp{cn} = 'T';
cn = cn+1;
cnam{cn} = 'N-E';
cwgt{cn} = -cwgt{cn-1};
ctyp{cn} = 'T';

cn = cn+1;
cnam{cn} = 'M-C';
con = [1 -1 1 -1];
cwgt{cn} = [zeros(1,npop) con con*n1/nsuj con*n2/nsuj];
ctyp{cn} = 'T';
cn = cn+1;
cnam{cn} = 'C-M';
cwgt{cn} = -cwgt{cn-1};
ctyp{cn} = 'T';

cn = cn+1;
cnam{cn} = 'EM-NM';
con = [1 0 -1 0];
cwgt{cn} = [zeros(1,npop) con con*n1/nsuj con*n2/nsuj];
ctyp{cn} = 'T';
cn = cn+1;
cnam{cn} = 'NM-EM';
cwgt{cn} = -cwgt{cn-1};
ctyp{cn} = 'T';

cn = cn+1;
cnam{cn} = 'EC-NC';
con = [0 1 0 -1];
cwgt{cn} = [zeros(1,npop) con con*n1/nsuj con*n2/nsuj];
ctyp{cn} = 'T';
cn = cn+1;
cnam{cn} = 'NC-EC';
cwgt{cn} = -cwgt{cn-1};
ctyp{cn} = 'T';

cn = cn+1;
cnam{cn} = 'EC-EM';
con = [-1 1 0 0];
cwgt{cn} = [zeros(1,npop) con con*n1/nsuj con*n2/nsuj];
ctyp{cn} = 'T';
cn = cn+1;
cnam{cn} = 'EM-EC';
cwgt{cn} = -cwgt{cn-1};
ctyp{cn} = 'T';

cn = cn+1;
cnam{cn} = 'NC-NM';
con = [0 0 -1 1];
cwgt{cn} = [zeros(1,npop) con con*n1/nsuj con*n2/nsuj];
ctyp{cn} = 'T';
cn = cn+1;
cnam{cn} = 'NM-NC';
cwgt{cn} = -cwgt{cn-1};
ctyp{cn} = 'T';
%% interactions
cn = cn+1;
cnam{cn} = 'E-N_C-P';
con = [1 1 -1 -1];
cwgt{cn} = [zeros(1,npop+ncon) con -con];
ctyp{cn} = 'T';
cn = cn+1;
cnam{cn} = 'E-N_P-C';
cwgt{cn} = -cwgt{cn-1};
ctyp{cn} = 'T';

cn = cn+1;
cnam{cn} = 'M-C_C-P';
con = [1 -1 1 -1];
cwgt{cn} = [zeros(1,npop+ncon) con -con];
ctyp{cn} = 'T';
cn = cn+1;
cnam{cn} = 'M-C_P-C';
cwgt{cn} = -cwgt{cn-1};
ctyp{cn} = 'T';

for c = 1:cn
    cw = [cwgt{c}]';	% pad with zero for constant
    SPM.xCon(c)     = spm_FcUtil('Set',cnam{c},ctyp{c},'c',cw,SPM.xX.xKXs);
end

spm_contrasts(SPM);
return