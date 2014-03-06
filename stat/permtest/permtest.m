function [pv,S0,NP,PS,P]=permtest(X,X2,statistic,dim_p,dim_m,NP,TimeBar,tails,varargin)
% permtest - Generic permutation/randomization test
%   [pv,S0,NP,PS,P] = permtest(X1,X2,statistic,dim_p,dim_m,NP,TimeBar,tails,[testoptions])
%   [pv ... ]       = permtest(X, N1,statistic,...)
%
%   Performs a permutation test with the data
%
%MANDATORY INPUTS:
%  X1,X2: [N1 x Ma x Mb...] and [ N2 x Ma x Mb x...] Multidimensional matrices
%         of Ni samples/subjects for each group, eg. [ Subjects x Channel x Time ]
%  Alternatively:
%         X can be a single data matrix. But the number of samples (ie subjects)
%         in the first group should be set using 'N1'
%         I.e.   X = [ X1 ; X2 ]  &  N1=size(X1,1)=nb of samples in group 1
%
%  statistic: Name of the statistic to use:
%       'meandiff' (mean difference)
%       'tvalue' (Student's t-value)
%       'pseudotvalue' (tvalue with smoothed variance)
%       'signtest' 
%       'wilcoxon' (aka. signed ranks)
%       'edist'(euclidian distance, on dimension dim_m)
%
%OPTIONAL INPUTS (use [] for default values):
%  dimP: Permuted dimensions (ie. subjects). Default: first non singleton
%        If dim_p > 0 : paired permutations (default)
%        Use negative dim_p for unpaired samples/subjects
%  dimM: Dimensions of data across which the maximum T-value is computed.
%        For multidimensional data, eg. [ Subject x Channel x Time ],
%        control of Family-wise Error Rate requires to compute T-value
%        across all dimensions (starting after the permuted one.
%        Default is: all dimensions besides the "permuted" dimensions
%        (typically: [2 3 ... ndims(X)])
%  NP: Number of permutations (may be reduced if bigger than the number of permutations,
%      for example if NP > 2^N-1 using paired data)
%      If not specify, permttest uses 10000 (at most).
%      Set NP=inf so to enforce exhaustive permutations, ie. all possible permutations
%      (this may lead to HUGE numbers of permutations, avoid with unpaired tests)
%  TimeBar: 1 (default) or 0. To display a progress bar.
%  tails: 1- (one: X1>X2) or 2- (two: X1<X2 or X1>X2) tailed test (default: 2)
%  testoptions: List of parameters required for the chosen test
%           'ttest'|'mann-whitney'|'wilcoxon': testoptions={};
%           'pseudottest': testoptions{1}=smooting kernel
%           'edist': testoptions={}
%
%OUTPUTS:
%   pv: p-values of the observed data, computed from the permutations
%       (dimensions subjects and dim_m are squeezed). This is a fairly good
%       approximation of the parametric test when data are normally
%       distributed. But it is still valid when they are not!
%   S0: [Ma x Mb...] Observed values of the statistic
%   NP: Number of permutations actually performed
%   PS: [P x Ma x Mb... ] Matrix of permutation statistics (may be quite big!)
%   P:  [NP x (N1+N2)] List of permutations used
%
% References:
%   On euclidian distance: Greenblatt, Brain Topography, 2004
%
% Authors:
%   K² Team, aka. K. N'Diaye (kndiaye01<at>yahoo.fr> & K. Jerbi (jerbi<at>chups.jussieu.fr)
%   CNRS UPR640, Lab. d'imagerie cérébrale et neurosciences cognitives
%   Hopital de la Salpetriere, Paris, France
% Copyright (C) 2006
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% K²  2006-02-02 Creation
% KND 2006-02-14 Added euclidian distance test ('edist')
% KND 2010-11-12 May now use function handle
% ----------------------------- Script History ---------------------------------

NMAX_UNPAIRED=15; %  maximum number of observations for exhaustive search for unpaired samples
NMAX_PAIRED=30;  %  maximum number of observations for exhaustive search in paired samples
NMAX_SUBJECTS=1000; % Max number of subjects
NPERMS=9999; % Default number of permutations
STATISTICS={'tvalue','meandiff','tvaluesmoothed','signtest','wilcoxon','edist'};
PAIREDSTAT={'wilcoxon', 'mann-whitney', 'signtest', 'plusminus'};
%Note for authors:
%   'mann-whitney' : check code below before making it available to user
%   'plusminus' : should be ok
%       'plusminus' (sum of X1>X2 along dim_m)

%initialize parameters
if nargin<3
    error('Test Statistic need to be specified (e.g. ''meandiff'' or ''tvalue'')!')
end
testargs ={};
if (iscell(statistic))
    testargs = statistic{2:end};
    statistic=statistic{1};
end
if isa(statistic, 'function_handle')
    testfun = statistic;
    statistic = 'fun';
elseif not(ismember(statistic, STATISTICS))
    error('Wrong type of test! Possible test statistics are:\n%s\n', sprintf('%s ', STATISTICS{:}))
end
if nargin<4
    dim_p=[];
end
if nargin<5
    dim_m=[];
end
if nargin<6
    NP=[];
end
if nargin<7
    TimeBar=1; % KJ, default is off now...
end
if nargin<8
    tails=2;
end
if ~isequal(tails,1) && ~isequal(tails,2) && ~isequal(tails,-1)
    error('Tails can be 1 or 2')
end

%% Checking dimensions
%
if isempty(dim_p)
    dim=find(size(X)>1,1);
    if isempty(dim)
        error('Input X has only singleton or null dimensions!')
    end
    %dim=dim(1);
    if ndims(X2)>=dim
        if size(X,dim) ~= size(X2,dim)
            dim=-dim;
        end
    end    
    dim_p=dim;
end
dim=abs(dim_p);
options=varargin;
if dim_p<0 && ~isempty(strmatch(statistic, PAIREDSTAT))
    error('Unpaired data not supported for %s statistics, are you still a Student? LOL',statistic)
end


%% RESHAPING ORIGINAL DATA
%
% Data in X (and possibly in X2) will be concatenated (if needed) and
% reshaped so that following computations are made easier.
% Resulting size of X will be: [ (N1+N2) "dim_m"(1) "dim_m"(2) (...) ]
% i.e  - subjects are put in the first dimension, group 1 above group 2
%      - data from the dimension(s) dim_m are put as the second, third... dimension of X
%      - additional dimensions (tested separately, ie univariately) follow
%
ndX=ndims(X);
dX1=setdiff(1:ndX,dim);
sX1=[size(X) 1 1];
% Put subjects in the first dimension
X=permute(X, [dim dX1]);
sX=[size(X) ones(1,ndX)];
if numel(X2)>1 % X2 is a matrix
    X2=permute(X2, [dim dX1]);
    sX2=[size(X2) ones(1,ndX)];
    if ~isequal(sX(2:end), sX2(2:end))
        error('X1 and X2 should be of the same size in the non-permuted dimensions!')
    end
    X=cat(1,X,X2);
    N=[sX(1) sX2(1)];
    clear sX2;
elseif numel(X2)==1 % X2 is the number of samples in the first group
    N=[X2 sX(1)-X2];
else
    error('Check inputs!')
end
clear X2;
X=double(X);
if sum(N)>NMAX_SUBJECTS
    error('Too many subjects!')
end
if dim_p>0 && N(1) ~= N(2)
    error('Paired data should have the same number of samples!')
end

%% SETTING dim_m VARIABLE & SHAPE OF X ALONG IT
%
% Default is to compute the maximum T value across all dimensions of the
% measurement data (dim_m).
if isempty(dim_m)
    dim_m=setdiff(1:ndX,dim);
end
dim_m=unique(dim_m(:))';
if any(dim_m>ndX)
    error('Wrong dimM dimensions!')
end
if any(ismember(dim_p,dim_m))
    error(sprintf('Wrong dimM dimensions: [%d] is already set as the permuted dimension!\n' , dim))
end
dim_m1=dim_m;
dim_m=dim_m+(dim_m<dim & dim_m>0);

%% PUT DATA INTO A SINGLE ARRAY FOR EFFICENCY
% Define a practical shape  for the measurement data (all dim_m dimensions
% as a single vector) so that the maximum across dimension is easy to
% compute
if dim_m==0
    nsX=[1 sX(2:end)];
elseif ndX==2
    nsX=[1 sX(2:end)];
else
    X=permute(X,[1 dim_m setdiff(2:ndX, dim_m)]);
    nsX=[prod(sX(dim_m)) sX(setdiff(2:ndX, dim_m)) 1];    
    X=reshape(X,[size(X,1) nsX]);
end


%% NUMBER OF PERMUTATIONS
%
% Now compute the number of exhaustive permutations
if dim_p>0
    if tails==2
        % We compute only one half of the permutations for paired samples
        Nexh=2^(N(1)-1)-1;
    else
        Nexh=2^(N(1))-1;
    end
else
    Nexh=factorial(N(1)+N(2))/(factorial(N(1))*factorial(N(2)))-1;
end

exhaustive=0;
if isempty(NP)
    if (dim_p>0 && (N(1)+N(2))<NMAX_PAIRED ) || ...
            (dim_p<0 && (N(1)+N(2))<NMAX_UNPAIRED )
        NP=Nexh;
        exhaustive=1;
    else
        NP=NPERMS;
        exhaustive=0;
    end
else
    if NP<Nexh & NP<NPERMS
        if TimeBar
            msg=sprintf('%d', N(1));
            if dim_p>0
                msg=[ msg ' paired'];
            end
            warning(sprintf([ 'You are under-sampling (with %d permutations)!\nFor this dataset (with %s subjects),'...
                'the possible number of permutations is: %d.'],NP,msg,Nexh));
        end
    elseif isequal(NP, inf)
        if TimeBar
            disp(sprintf('You have requested exhaustive permutations: %d.',Nexh));
        end
        NP=Nexh;
        exhaustive=1;
    elseif NP>Nexh
        if TimeBar
            msg=sprintf('%d', N(1));
            if dim_p>0
                msg=[ msg ' paired'];
            end
            warning(sprintf([ 'You are over-sampling (with %d permutations)!\nFor this dataset (with %s subjects),'...
                'the maximum number of permutations is: %d.'],NP,msg,Nexh));
        end
    elseif NP==Nexh;
        exhaustive=1;
    else
        if NP>NPERMS
            if TimeBar
                warning(sprintf('So many permutations to be done (%d) may take a long time!',NP));
            end
        end
    end
end


%% LIST OF PERMUTAIONS
if dim_p>0
    % paired permutations
    if exhaustive
        % compute exhaustive list of perms
        P=49==(dec2bin(1:NP,N(1)));
    else
        % non exhaustive
        P=round(rand(NP,N(1)));
    end
    P=[P 1-P].*N(1)+repmat(1:N(1), [NP,2]);
else
    % non-paired perms
    if exhaustive % do all possible perms
        p=nchoosek(1:(N(1)+N(2)),N(1));
        p(1,:)=[]; % the 1st is not a permutation
        for i=1:NP
            P(i,:)=[p(i,:) setdiff(1:(N(1)+N(2)),p(i,:))];
        end
        clear p
    else % non exhaustive
        [ignore,P]=sort(rand(NP,N(1)+N(2)),2);
    end
end

%% DISPLAY TIMEBAR
if TimeBar
    try
        htimer = timebar('Permutation Statistics','Progress...');
    catch
        warning('Function timebar.m missing. waitbar.m is used instead')
        htimer = waitbar(0,'Permutation Statistics');
    end
else
    htimer = NaN;
end

%% PERMUTATION LOOP
for i=0:NP
    if i==0
        % At the 0-th permutation, evaluate original data
        Y=X;
    else
        Y=X(P(i,:),:,:);
    end

    switch(statistic)
        case 'tvalue'
            Z=tvalue(Y(1:N(1),:),Y(N(1)+(1:N(2)),:));
        case 'meandiff'
            Z=sum(Y(1:N(1),:),1)./N(1)-sum(Y(N(1)+(1:N(2)),:),1)./N(2); %this is to use difference of mean instead of T-statistic (KJ)
        case 'pseudotvalue'
            Z=pseudotvalue(Y(1:N(1),:),Y(N(1)+(1:N(2)),:),options{1});
        case 'signtest'
            Z=sign(Y(1:N(1),:)-Y(N(1)+(1:N(2)),:));
            Z=sum(Z,1).^2./sum(abs(Z),1);
        case 'wilcoxon'
            Z=Y(1:N(1),:)-Y(N(1)+(1:N(2)),:);
            Z=sign(Z).*tiedrank(abs(Z),1);
            Z=sum(Z(:,:),1);
            % 		case 'mann-whitney'
            % 			Z=tiedrank(Y(:,:),1);
            % 			Z=sum(Z(1:N(1),:),1);
        case 'edist'
            if i==0
                nsX(1)=1;
                sX1(dim_m)=[];
                dim=dim-sum(dim_m1<dim);
            end
            Z=sqrt(sum((sum(Y(1:N(1),:,:),1)./N(1)-sum(Y(N(1)+(1:N(2)),:,:))./N(2)).^2,2));
            %        case 'plusminus'
            %           Z=sum(Y(1:N(1),:)>Y(N(1)+(1:N(2)),:),1);
        case 'fun'
            Z=feval(testfun,Y(1:N(1),:),Y(N(1)+(1:N(2)),:),testargs{:});
    end
    Z=reshape(Z,nsX);
    if tails==2
        Z=abs(Z);
    end
    if i==0
        S0=Z;
        sz=size(S0);
        S=zeros(sz);
        if nargout>3
            %pack;
            PS=zeros([NP sz(2:end) 1],'single');
        end
    else
        Z=max(Z,[],1);
        if nargout>3
            PS(i,:)=Z(:)';
        end
        S=S+(repmat(Z,[nsX(1) 1])>=S0);
        if TimeBar,try if isequal(get(htimer,'tag'),'timebar'),timebar(htimer,i/NP),else waitbar(i/NP,htimer);end;catch,TimeBar=0;end,end
    end
end

%% COMPUTE RESULTING P-VALUES
pv=(S+1)./(NP+1);

%% PROCESSING OUTPUTS
if ndX>2
    % Put back the dim_m dimension at their original place
    if ~isequal(dim_m, 0)
        pv=ipermute(pv, [dim_m-1 setdiff(1:ndX-1, dim_m-1)]);
        S0=ipermute(S0, [dim_m-1 setdiff(1:ndX-1, dim_m-1)]);
    end
end
if dim>1 || ndX>2
    sX1(dim)=[];
    pv=reshape(pv, sX1);
    S0=reshape(S0, sX1);
end
if nargout>3
    PS=reshape(PS, [NP nsX(2:end)]);
end
try,if ishandle(htimer),close(htimer),end,drawnow;end
return


%% Validation:
X1=randn(100,1);
X=X1+0.2+randn(size(X1));
% Paired case:
[p,K,P,PS]=permttest(X1,X,1,[],999,0);p
myttest(X1,X,1,'pttest')
% Unpaired (unequal variance)
[p,K,P,PS]=permttest(X1,X,-1,[],999,0);p
myttest(X1,X,1,'uttest')