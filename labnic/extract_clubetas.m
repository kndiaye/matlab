function [Data] = extract_clubetas(SPM,xSPM)
sub2pr=[1:SPM.nscan];
clear Data
[xyzmm,i] = spm_XYZreg('NearestXYZ',spm_results_ui('GetCoords'),xSPM.XYZmm);
spm_results_ui('SetCoords',xSPM.XYZmm(:,i));
A         = spm_clusters(xSPM.XYZ);
j         = find(A == A(i));
xyz = xSPM.XYZmm(:,j)';

pathlist = SPM.xY.P;

allbetas= [];
Allbetas = [];
allxyz = [];

%--- to write
XYZ  = SPM.xVol.XYZ;
XYZmm = SPM.xVol.M(1:3,:)*[XYZ; ones(1,size(XYZ,2))];
bob = spm_input('nature of extraction','+1','b','VOI|cluster',[0,1]);

if ~bob
    [xyz xyzmm] = spm_VOI_yann(SPM,xSPM);
    xyz = xyzmm';
end

cond_list = [];
for sub = 1:length(sub2pr)
    mydir = fileparts(pathlist{sub});
    sSPM = load([mydir filesep 'SPM.mat']);
    nses = length(sSPM.SPM.Sess);%num of session
    convec = zeros(1,length(sSPM.SPM.Vbeta));
    for ses = 1:nses
        for j = 1:length(sSPM.SPM.Sess(ses).Fc)
            index = sSPM.SPM.Sess(ses).col(sSPM.SPM.Sess(ses).Fc(1,j).i);
            convec(ses,index) = 1;
        end
    end
    real = sSPM.SPM.xX.name(any(convec,1));
    for j = 1:length(real)
        b = strfind(real{j},'*bf');
        list_cond{j} = real{j}(7:b-1);
    end
    [b,c,d] = unique(list_cond,'first');
    [m n] = sort(c);
    cond_list = [cond_list b(n)];
end
[b,c,d] = unique(cond_list,'first');
[m n] = sort(c);
thelist = b(n);

Allbetas = NaN(length(sub2pr),length(thelist));


messages = {'hot baby... hot...' 'what are you thinking about?...' 'wait and see...' 'wait for reaching heaven...' 'Please wait... (no luck! the basic)'};
colors = {[1,0.4,0.6] [1,0.6,0.4] [0.4,1,0.6] [0.4,0.6,1] [1,0.4,1]};
[m n] = sort(rand(1,5));
h = waitbar(0,messages{n(1)},'Color',colors{n(1)});

for sub = 1:length(sub2pr)
    mydir = fileparts(pathlist{sub});
    sSPM = load([mydir filesep 'SPM.mat']);
    nses = length(sSPM.SPM.Sess);%num of session
    for i = 1:length(sSPM.SPM.Vbeta)
        sSPM.SPM.Vbeta(i).fname = [mydir filesep sSPM.SPM.Vbeta(i).fname];
    end
    tmpallbetas= [];
    tmpallxyz = [];
    Tmpallbetas= [];
    list_cond = [];
    for cluvox = 1:size(xyz,1)
        [nxyz,i] = spm_XYZreg('NearestXYZ',xyz(cluvox,:),XYZmm);
        govox=1;
        if sqrt(sum((nxyz'-xyz(cluvox,:)).^2))>=1.7321 %one voxel in each dimZ
            govox= spm_input({'No data stored for this voxel','Closest voxels with data are:',...
                num2str(xyz(cluvox,:)),...
                'Continue anyway?'},...
                1,'bd',{'OK','NO'},[1,0]);
        end
        vXYZ     = XYZ(:,i)  ;         % coordinates in voxels

        %-Get parameter and hyperparameter estimates
        beta= spm_get_data(sSPM.SPM.Vbeta, vXYZ);

        convec = zeros(1,length(sSPM.SPM.Vbeta));
        for ses = 1:nses
            for j = 1:length(sSPM.SPM.Sess(ses).Fc)
                index = sSPM.SPM.Sess(ses).col(sSPM.SPM.Sess(ses).Fc(1,j).i);
                convec(ses,index) = 1;
            end

        end
        real = sSPM.SPM.xX.name(any(convec,1));
        for j = 1:length(real)
            b = strfind(real{j},'*bf');
            list_cond{j} = real{j}(7:b-1);
        end
        tmpallbetas  = [tmpallbetas; beta(any(convec,1))'];
    end

    for c = 1:length(thelist)
        C = strcmp(thelist{c},list_cond);
        Tmpallbetas = [Tmpallbetas mean(sum(tmpallbetas(:,C)))];
    end

    Allbetas(sub,:) = Tmpallbetas;
    %allxyz= [allxyz;mean(tmpallxyz,1)];
    waitbar(sub/length(sub2pr),h)
end
close(h)

ctitle = [num2str(nxyz') '  nvox = ' num2str(size(xyz,1))];
tmpaxe = thelist(1:length(thelist));

npop = size(SPM.xX.X,2);
for pop = 1:npop
    Data{pop}(:,:) = reshape(Allbetas(logical(repmat(SPM.xX.X(:,pop),1,size(Allbetas,2)))),sum(SPM.xX.X(:,pop)),size(Allbetas,2));
end
[Maj,ST,SE] = yann_bar(Data);
switch spm_input('errorbar?',2,'b','yes|no');
    case 'yes'
        figure
        h  = bar(Maj');
        for  i = 1:size(Maj,1)
            if i == 1 & npop > 1
                N = -0.08;
            elseif i == 1
                N = 0;
            else
                N = 0.08;
            end
            for j = 1:size(Maj,2)
                coef = j+npop*N;
                line([coef coef],([SE(i,j) 0 - SE(i,j)] + Maj(i,j)),...
                    'LineWidth',1.5,'Color','k')
                line ([coef-0.05 coef+0.05],([SE(i,j)+Maj(i,j) SE(i,j)+Maj(i,j)]),...
                    'LineWidth',1.5,'Color','k')
                line ([coef-0.05 coef+0.05],([-SE(i,j)+Maj(i,j) -SE(i,j)+Maj(i,j)]),...
                    'LineWidth',1.5,'Color','k')
            end
        end
    case 'no'
        figure
        h  = bar(Maj');
        set(h,'FaceColor',[1 1 1]*.8)
end
set(gca, 'XTickLabel',tmpaxe, 'XTick' , [1:length(tmpaxe)],'FontSize',6);
title(ctitle,'FontSize',16)

%% Functions
function [Maj,ST,SE] = yann_bar(Data)
% function [Maj,ST,SE] = yann_bar(Data)
% calculate Mean, stdev and std error for Data
% developed by Yann Cojan (yann.cojan@unige.ch)

npop = length(Data)

switch spm_input('Reset lowest value to:?',1,'b','zero|mean|unchanged');
    case 'zero'
        for pop = 1:npop
            if isempty(find(mean(Data{pop})<0))
                Maj(pop,:) = mean(Data{pop},1)- min(mean(Data{pop},1));
            else
                Maj(pop,:) = mean(Data{pop},1) + abs(min(mean(Data{pop},1)));
            end
        end
    case 'mean'
        for pop = 1:npop
            Maj(pop,:) = mean(Data{pop},1) - mean(mean(Data{pop},1));
        end
    case 'unchanged'
        for pop = 1:npop
            if any(any(isnan(Data{pop})))
                count = 1;
                for hu = 1:size(Data{pop},2)
                    Maj(pop,hu) = mean(Data{pop}(~isnan(Data{pop}(:,hu)),hu));
                end
            else
                Maj(pop,:) = mean(Data{pop},1);
            end
        end
end
for pop = 1:npop
    if size(Data{pop},1)>1
        if any(any(isnan(Data{pop})))
            for hu = 1:size(Data{pop},2)
                SE(pop,hu) = std(Data{pop}(~isnan(Data{pop}(:,hu)),hu))/sqrt(size(Data{pop}(~isnan(Data{pop}(:,hu))),1));
                ST(pop,hu) = std(Data{pop}(~isnan(Data{pop}(:,hu)),hu));
            end
        else
            SE(pop,:) = std(Data{pop})/sqrt(size(Data{pop},1));
            ST(pop,:) = std(Data{pop});
        end
    else
        if any(any(isnan(Data{pop})))
            for hu = 1:size(Data{pop},2)
                SE(pop,hu) = std(Data{pop}(~isnan(Data{pop}(:,hu)),hu))/sqrt(size(Data{pop}(~isnan(Data{pop}(:,hu))),1));
                ST(pop,hu) = std(Data{pop}(~isnan(Data{pop}(:,hu)),hu));
            end
        else
            SE(pop,:) = zeros(1,size(Data{pop},2));
            ST(pop,:) = zeros(1,size(Data{pop},2));
        end
    end
end

function [XYZ XYZmm] = spm_VOI_yann(SPM,xSPM,hReg)
% see spm_VOI for help

%-Parse arguments
%-----------------------------------------------------------------------
if nargin < 2,   error('insufficient arguments'), end
if nargin < 3,	 hReg = []; end

Num      = 16;			% maxima per cluster
Dis      = 04;			% distance among maxima (mm)

%-Title
%-----------------------------------------------------------------------
spm('FigName',['SPM{',xSPM.STAT,'}: Small Volume Correction']);

%-Get current location {mm}
%-----------------------------------------------------------------------
xyzmm    = spm_results_ui('GetCoords');

%-Specify search volume
%-----------------------------------------------------------------------
str      = sprintf(' at [%.0f,%.0f,%.0f]',xyzmm(1),xyzmm(2),xyzmm(3));
SPACE    = spm_input('Search volume...',-1,'m',...
    {['Sphere',str],['Box',str],'Image'},['S','B','I']);

% voxels in entire search volume {mm}
%-----------------------------------------------------------------------
XYZmm    = SPM.xVol.M(1:3,:)*[SPM.xVol.XYZ; ones(1, SPM.xVol.S)];
Q        = ones(1,size(xSPM.XYZmm,2));
O        = ones(1,size(     XYZmm,2));
FWHM     = xSPM.FWHM;


switch SPACE

    case 'S' %-Sphere
        %---------------------------------------------------------------
        D          = spm_input('radius of VOI {mm}',-2);
        str        = sprintf('%0.1fmm sphere',D);
        j          = find(sum((xSPM.XYZmm - xyzmm*Q).^2) <= D^2);
        k          = find(sum((     XYZmm - xyzmm*O).^2) <= D^2);
        D          = D./xSPM.VOX;


    case 'B' %-Box
        %---------------------------------------------------------------
        D          = spm_input('box dimensions [k l m] {mm}',-2);
        str        = sprintf('%0.1f x %0.1f x %0.1f mm box',D(1),D(2),D(3));
        j          = find(all(abs(xSPM.XYZmm - xyzmm*Q) <= D(:)*Q/2));
        k          = find(all(abs(     XYZmm - xyzmm*O) <= D(:)*O/2));
        D          = D./xSPM.VOX;


    case 'I' %-Mask Image
        %---------------------------------------------------------------
        Msk   = spm_select(1,'image','Image defining search volume');
        D     = spm_vol(Msk);
        str   = sprintf('image mask: %s',spm_str_manip(Msk,'a30'));
        VOX   = sqrt(sum(D.mat(1:3,1:3).^2));
        FWHM  = FWHM.*(xSPM.VOX./VOX);
        XYZ   = D.mat \ [xSPM.XYZmm; ones(1, size(xSPM.XYZmm, 2))];
        j     = find(spm_sample_vol(D, XYZ(1,:), XYZ(2,:), XYZ(3,:),0) > 0);
        XYZ   = D.mat \ [     XYZmm; ones(1, size(    XYZmm, 2))];
        k     = find(spm_sample_vol(D, XYZ(1,:), XYZ(2,:), XYZ(3,:),0) > 0);

end

xSPM.S     = length(k);
xSPM.R     = spm_resels(FWHM,D,SPACE);
xSPM.Z     = xSPM.Z(j);
xSPM.XYZ   = xSPM.XYZ(:,j);
xSPM.XYZmm = xSPM.XYZmm(:,j);
xSPM.Ps    = xSPM.Ps(k);
XYZ = xSPM.XYZ;
XYZmm = xSPM.XYZmm;
%-Tabulate p values
%-----------------------------------------------------------------------
str       = sprintf('search volume: %s',str);
if any(strcmp(SPACE,{'S','B'}))
    str = sprintf('%s at [%.0f,%.0f,%.0f]',str,xyzmm(1),xyzmm(2),xyzmm(3));
end

TabDat    = spm_list('List',xSPM,hReg,Num,Dis,str);

%-Reset title
%-----------------------------------------------------------------------
spm('FigName',['SPM{',xSPM.STAT,'}: Results']);