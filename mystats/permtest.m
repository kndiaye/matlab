function [pv,S0,NP,PS,P]=permtest(X,X2,testoptions,dim_p,dim_m,NP,TimeBar,tails,verbose,varargin)
% permtest - Generic permutation/randomization test
%
%   [pv,S0,NP,PS,P] = permtest(X1,X2,{testname testparams},dim_p,dim_m,NP,TimeBar,tails)
%
%   Performs a permutation test with the data
%
%MANDATORY INPUTS:
%  X1,X2: [N1 x Ma x Mb...] and [ N2 x Ma x Mb x...] Multidimensional matrices
%         of Ni samples/subjects for each group, eg. [ Subjects x Channel x Time ]
%  Alternative input formats:
%   [pv ... ] = permtest(X,D,{testname},...)
%         X is a single data matrix. The two conditions are specified by
%         dimension D in the matrix.
%         size(X,D)=2   &   X1=X(...,1,...)  &   X2=X(...,2,...)
%   [pv ... ] = permtest(X,-N1,{...},...)
%         X can be a single data matrix. But the number of samples (ie subjects)
%         in the first group should be set using 'N1' (which is input as a
%         negative value)
%         I.e.   X = [ X1 ; X2 ]  &  N1=size(X1,1)=nb of subjects in group 1
%
%   { testname testparams } : Name of the test statistic to use (and its
%       parameters). Must be a cell or a char:
%       'ttest': Student's t-value
%       'difftest': difference of the means
%       'pseudottest': t-value with smoothed variance
%       'signtest': sign of the differences
%       'wilcoxon': signed ranks (used for paired data)
%       'edist': euclidian distance, along given dimension(s)
%   Test parameters (if needed) should be given in the right order
%   following testname:
%           'ttest': No parameters needed
%           'mann-whitney': No parameters needed
%           'wilcoxon': No parameters needed
%           'signtest': No parameters needed
%           'pseudottest': Needs the smooting kernel
%           'edist': Specify the dimension(s) on which distance is computed

%   You can add post-processing on a 2nd line of the cell (if none: enter [])
%           'vertconn_min': Uses the minimal statistic value of the
%                           neighourhoud. Vertices must be the first dimension
%                           of dependent variables.
%                           Vertex connectivity must be provided.
%
%   And on a 3rd line, the post-hoc correction for multiple comparison
%   across dimension(s) specified in dim_m (skipped if dim_m==0)
%           'max': (default) uses the maximal statistic value
%           'vertconn_max',vc: uses the maximum statistic across neighbours
%                           only (not the whole brain). It needs the vertex
%                           connectivity: vc
%           'quantile',p: uses the p-th quantile of data
%           'wyrm': Westfall-Young Randomization Method for multiple
%                   comparisons
%
%           Example:
%               >> permtest(x1,x2,{'ttest' [];'vertconn_min', vertconn})
%               Note that the [] is needed by matlab but is not used.
%
%OPTIONAL INPUTS (use [] for default values):
%  dimP: Permuted dimensions (ie. subjects). Default: first non singleton
%        If dim_p > 0 : paired permutations (default)
%        Use negative dim_p for unpaired samples/subjects
%  dimM: Dimensions of data across which the maximum (or whatever post
%        processing ) of T-value is computed.
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
%   On pseudo T-value (smoothed variance): Nichols, NeuroImage, 2003[?]
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
% KND 2006-10-12 Corrected bug due to missing reshape following global stat
% ----------------------------- Script History ---------------------------------

NMAX_UNPAIRED=15; %  maximum number of observations for exhaustive search for unpaired samples
NMAX_PAIRED=30;  %  maximum number of observations for exhaustive search in paired samples
NMAX_SUBJECTS=1000; % Max number of subjects
NPERMS=10000; % Default number of permutations
TESTS={'ttest','difftest','pseudottest','signtest','wilcoxon','edist','cluttest', 'pairedttest'};
PAIREDTESTS={'wilcoxon', 'mann-whitney', 'signtest', 'plusminus', 'pairedttest'};
%Note for authors:
%   'mann-whitney' : check code below before making it available to user
%   'plusminus' : should be ok
%   'plusminus' (sum of X1>X2 along dim_m)

%initialize parameters
if nargin<3
    error('Test Statistic need to be specified!')
end
if ischar(testoptions)
    testoptions={testoptions};
end
if ~iscell(testoptions)
    error('The test to be used should be specified as char or cell!')
end
if not(ismember(testoptions{1}, TESTS))
    error('Wrong type of test! Possible test statistics are:\n%s\n', sprintf('%s ', TESTS{:}))
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
if nargin<9
    verbose=1;
end
if ~isequal(tails,1) && ~isequal(tails,2)
    error('Tails can be 1 or 2')
end

%__________________________________________________________________________
%
%% Checking dimensions
%
if isempty(dim_p)
    dim=find(size(X)>1);
    if isempty(dim)
        error('Input X has only singleton or null dimensions!')
    end
    dim=dim(1);
    dim_p=dim;
end
dim=abs(dim_p);
if dim_p<0 && ~isempty(strmatch(testoptions{1}, PAIREDTESTS))
    error('Unpaired data not supported for %s statistics, are you still a Student? LOL',testoptions{1})
end


%__________________________________________________________________________
%
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
sX1=[size(X) 1 1];
if numel(X2)==1 && X2>0 % X2 is the dimension of the "group factor"
    X=permute(X, [     setdiff(1:dim-1,X2)      dim X2     setdiff(dim+1:ndX,X2) ]);
    X=reshape(X, [ sX1(setdiff(1:dim-1,X2)) sX1(dim)*2 sX1(setdiff(dim+1:ndX,X2)) 1 ]);
    sX1(X2)=[];
    dim=dim-(X2<dim);
    X2=sX1(dim);
    ndX=ndX-1;
    N=sX1(dim)*[1 1];
end
dX1=setdiff(1:ndX,dim);

% Put subjects in the first dimension
if ~isempty(dX1)
    X=permute(X, [dim dX1]);
end
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
elseif numel(X2)==1 && X2<0 % X2 is the number of samples in the first group
    X2=-X2;
    N=[X2 sX(1)-X2];
elseif numel(X2)==1 && X2>0
else
    error('Check inputs!')
end
clear X2;
X=double(X);
NS=sum(N);
if NS>NMAX_SUBJECTS
    error('Too many subjects!')
end
if dim_p>0 && N(1) ~= N(2)
    error('Paired data should have the same number of samples!')
end
nsX=[size(X) 1 1];
Options.Test.InputSize=nsX;
Options.Test.OuputSize=Options.Test.InputSize;
nsX(1)=[];
Options.Test.OuputSize(1)=[];


%__________________________________________________________________________
%
%% PREPARE DATA FOR SPECIFIC TESTS
%
Options.Test.Name=testoptions{1};
switch(Options.Test.Name)
    case {'ttest' 'pairedttest' 'difftest' 'pseudottest' 'signtest' 'wilcoxon'}
        % Nothing to do
        if verbose, fprintf('The %s statistic will be used\n', Options.Test.Name); end
    case 'edist'
        d={};
        if size(testoptions,2)>1
            d=testoptions{1,2};
        end
        if isempty(d)
            error('You must specify one or many dimension(s) to compute Euclidan Distance');
        elseif ismember(d, dim_m)
            error('Euclidan Distance cannot use the same dimension as dim_m');
        end
        d=d-(dim<d);
        Options.Test.Permute=[1 1+[d setdiff(1:ndX-1,d)]];
        Options.Test.Reshape=[NS sX1(d) nsX(setdiff(1:ndX-1, d)) 1];
        Options.Test.Repmat=[ 1 ];
        Options.Test.OuputSize=nsX;
        Options.Test.OuputSize(d)=1;
        if verbose, fprintf('The eucidian distance (%s) statistic will be used on dimension(s): %s\n', Options.Test.Name, sprintf('%d', d)); end
        clear d;
end
nsX=Options.Test.OuputSize;

%__________________________________________________________________________
%
%% PROCESSING OF THE LOCAL STATISTCS
%
% Default is none:
Options.Local.Function=[];
if size(testoptions, 1)>1
    Options.Local.Function=testoptions{2,1};
    Options.Local.Apply=1;
end
if isempty(Options.Local.Function)
    Options.Local.Apply=0;
end
if Options.Local.Apply
    switch Options.Local.Function
        % This apply a correction factor on the statistisc by replacing
        % each value by the minimum found over a neigbourhood of connected
        % nodes on a mesh
        case 'vertconn_min'
            Options.Local.Dims=1;
            Options.Local.Permute=[1:max(ndX-1,2)];
            Options.Local.Repmat=[1];
            if verbose, fprintf('Local correction using minimal statistic\n'); end

        otherwise
            error('Unknown processing options: %s', Options.Local.Function)
    end
end
%__________________________________________________________________________
%
%% PROCESSING OF THE GLOBAL STATISTICS
%
if isequal(dim_m,0)
    Options.Global.Apply=0;
else
    %SETTING dim_m VARIABLE & SHAPE OF X ALONG IT
    % Default is to compute the maximum T value across all dimensions of the
    % measurement data (dim_m).
    dim_m0=dim_m;
    if isempty(dim_m)
        dim_m=setdiff(1:ndX,dim);
    end
    dim_m=unique(dim_m(:))';
    if max(dim_m)>ndX
        error('Wrong dim_m dimensions!')
    end
    if ismember(dim_p,dim_m)
        error(sprintf('Wrong dim_m dimensions: [%d] is already set as the permuted dimension!\n' , dim))
    end
    dim_m1=dim_m;
    dim_m=dim_m-(dim_m>dim);

    Options.Global.Apply=1;
    % Default: uses the global maximum
    Options.Global.Function='max';
    if size(testoptions, 1)>=3
        Options.Global.Function=testoptions{3,1};
    end
    if isempty(Options.Global.Function)
        Options.Global.Apply=0;
    end
    
end
if Options.Global.Apply
    switch Options.Global.Function
        case {'max', 'quantile'}
            switch Options.Global.Function
                case 'max'
                    Options.Global.FunctionName='Maximum';
                case 'quantile'
                    Options.Global.FunctionName='Quantile';
            end
            if verbose, fprintf('The %s statistic will be computed over dimensions: %s\n', Options.Global.FunctionName, sprintf('%d ', dim_m)); end
            Options.Global.Dims=dim_m;
            Options.Global.Permute=[dim_m setdiff([1:max(ndX-1,2)],dim_m)];
            Options.Global.Reshape=[prod(sX1(dim_m1)) nsX(setdiff(1:ndX-1, dim_m)) 1];
            Options.Global.Repmat=[ prod(sX1(dim_m1)) 1];
        case 'vertconn_max'
            if verbose, fprintf('Maximum Statistic will be computed over a neighbouring vertex in dimension: %d\n', dim_m(1)); end
            Options.Global.Dims=dim_m(1);
            Options.Global.Permute=[dim_m setdiff([1:max(ndX-1,2)],dim_m)];
            Options.Global.Reshape=[prod(sX1(dim_m1)) nsX(setdiff(1:ndX-1, dim_m)) 1];
            Options.Global.Repmat=[ 1 1];
        case 'wyrm'
            if verbose, fprintf('Westfall-Young Randomization Method for multiple comparisons will be used in dimension: %d\n', dim_m(1)); end
            Options.Global.Dims=dim_m(1);
            Options.Global.Permute=[dim_m setdiff([1:max(ndX-1,2)],dim_m)];
            Options.Global.Reshape=[prod(sX1(dim_m1)) nsX(setdiff(1:ndX-1, dim_m)) 1];
            Options.Global.Repmat=[ 1 1];
        otherwise
            error('Unknown processing options: %s', Options.Global.Function)
    end
else
    if verbose, fprintf('No correction for multiple comparisons will be applied.\n'); end
end




%__________________________________________________________________________
%
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
            msg=sprintf([ 'You are under-sampling (with %d permutations)!\nFor this dataset (with %s subjects),'...
                'the possible number of permutations is: %d.'],NP,msg,Nexh);
            
            warning(msg);
            clear msg
        end
    elseif isequal(NP, inf)
        if TimeBar
            if verbose, disp(sprintf('You have requested exhaustive permutations: %d.',Nexh)); end
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


%__________________________________________________________________________
%
%% LIST OF PERMUTATIONS
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

%__________________________________________________________________________
%
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

%__________________________________________________________________________
%
%% PERMUTATION LOOP
for i=0:NP
    if i==0
        % At the 0-th permutation, evaluate original data
        Y=X;
    else
        Y=X(P(i,:),:);       
    end
    Y=reshape(Y,[Options.Test.InputSize]);
    switch(testoptions{1})
        case 'ttest'
            Z=tvalue(Y(1:N(1),:),Y(N(1)+(1:N(2)),:));
        case 'pairedttest'
            Z=tvalue_paired(Y(1:N(1),:),Y(N(1)+(1:N(2)),:));
        case 'difftest'
            Z=sum(Y(1:N(1),:),1)./N(1)-sum(Y(N(1)+(1:N(2)),:),1)./N(2); %this is to use difference of mean instead of T-statistic (KJ)
        case 'pseudottest'
            Z=pseudotvalue(Y(1:N(1),:),Y(N(1)+(1:N(2)),:),testoptions{1,2});
        case 'signtest'
            Z=sign(Y(1:N(1),:)-Y(N(1)+(1:N(2)),:));
            Z=sum(Z,1).^2./sum(abs(Z),1);
        case 'wilcoxon' 
            %This is the signed ranks (not sum of ranks!)
            %Or almost: we don't correct by the denominator because it is
            %the same for all permutations. But it should be when there is
            %no ties: 
            %           Z=sum(Z(:,:),1)./sqrt(n*(n+1)*(2*n+1)/6) 
            %otherwise:
            %           Z=sum(Z(:,:),1)./sum(abs(Z).^2,1)
            Z=Y(1:N(1),:)-Y(N(1)+(1:N(2)),:);
            Z=sign(Z).*tiedrank(abs(Z),1);
            Z=sum(Z(:,:),1);
        case 'edist'
            Y=reshape(Y,Options.Test.InputSize);
            Y=permute(Y,Options.Test.Permute);
            Z=sqrt(sum((sum(Y(1:N(1),:,:),1)./N(1)-sum(Y(N(1)+(1:N(2)),:,:),1)./N(2)).^2,2));
        otherwise
            error('No statistic comput''d!!! Check da f*** m code')
            % 		case 'mann-whitney'
            % 			Z=tiedrank(Y(:,:),1);
            % 			Z=sum(Z(1:N(1),:),1);
            %        case 'plusminus'
            %           Z=sum(Y(1:N(1),:)>Y(N(1)+(1:N(2)),:),1);
    end
    Z=reshape(Z,[Options.Test.OuputSize]);
    if i==0
        S0=Z;
    end
    if tails==2
        Z=abs(Z);
    end
    if Options.Local.Apply
        switch Options.Local.Function
            case 'vertconn_min'
                Z=permute(Z,Options.Local.Permute);
                Z=vertconn_min(Z(:,:),testoptions{2,2});
                Z=ipermute(Z,Options.Local.Permute);
                Z=repmat(Z,Options.Local.Repmat);
        end
        Z=reshape(Z,[Options.Test.OuputSize]); %Z=reshape(Z,nsX);
    end
    if i==0        
        if tails==2
            S0=abs(Z).*sign(S0);
        else
            S0=Z;%abs(Z).*sign(S0);
        end
        sz=size(S0);
        S=zeros(sz);
        if nargout>3
            try;
                PS=zeros([NP sz 1],'single');
            catch
                pack;
                PS=zeros([NP sz 1],'single');
            end
        end
    else
       if Options.Global.Apply
            Z=permute(Z,Options.Global.Permute);
            Z=reshape(Z,Options.Global.Reshape);
            switch Options.Global.Function
                case 'max'
                    [Z]=max(Z,[],1);
                case 'vertconn_max'
                    Z=vertconn_max(Z(:,:),testoptions{3,2});
                case 'quantile'
                    Z=quantile(Z(:,:),testoptions{3,2});
            end
            Z=repmat(Z,Options.Global.Repmat);
            Z=ipermute(Z,Options.Global.Permute);
            Z=reshape(Z,[Options.Test.OuputSize]);
        end
        
        if tails==2
            S=S+(Z>=abs(S0));
            %S=S+(repmat(Z,[nsX(1) 1])>=abs(S0));
        else
            S=S+(Z>=S0);
        end
        % If (and only if) requested, PS is output
        if nargout>3
            PS(i,:)=Z(:)';
        end               
        if ishandle(htimer),try,if isequal(get(htimer, 'tag'), 'timebar'), timebar(htimer,i/NP),else,waitbar(i/NP,htimer);end;catch,end,end
    end
end

%% COMPUTE RESULTING P-VALUES
pv=(S+1)./(NP+1);

%% PROCESSING OUTPUTS

% Put back the dim_m dimension at their original place
% sX1(dim)=[];
% pv=reshape(pv, Options.Test.OutputSize);
% S0=reshape(S0, Options.Test.OutputSize);

if nargout>3
    PS=reshape(PS, [NP nsX]);
end
if ishandle(htimer),try,close(htimer),end,drawnow;end
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