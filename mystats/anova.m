function [summary,para,resid] = anova(voie,Y,G,R,int,varargin)
%ANOVA one-way and two-way analysis of variance (ANOVA).
%   [summary,para,resid] = anova(voie,Y,G,R,int)
% DO NOT USE FOR WITHIN SUBJECT EFFECTS!!!

%
% If G isempty (or not specified) columns of Y make each group. No
% repetition is assumed.
% If G is given, Y should be a N*Kvector of length N*R and G a N-by-K matrix
% where the K columns specify the groups.
% R is the repetition factor.


%   ANOVA calls ANOVA1 in case of one-way and 
%               ANOVA2 in case of two-way layout.
%
%   ANOVA1 and ANOVA2 are from the matlab6 version, to have callbacks
if nargin<3
    G=[];
end
if nargin<4
    R=1;
end    
if nargin<5
    int=1;
end

if (voie==1)      
    [p,summary,stats] = anova1(Y',G,'off');
    summary{2,1}='Rows';
    para.mu=mean(mean(Y'));
    para.alpha=stats.means-para.mu;
%    resid=Y-repmat(stats.means',1,R);
resid=NaN;
else
    
    if isvector(Y)
        [sg,sidx]=sortrows(G);
        ng1=length(unique(sg(:,1)));
        ng2=length(unique(sg(:,2)));        
        R=size(G,1)/ng1/ng2;
        Y=Y(sidx);
        Y=reshape(Y, ng1, ng2*R)';      
        n=ng1;
        m=ng2*R;
    else
        if ndims(Y)<=3
            Y=Y(:,:);
        else
            error('Trop de dim!')
        end
            [n,m]=size(Y);
    end
    [p,summary,stats] = anova2(Y',R,'off');
    summary{2,1}='Rows';
    summary{3,1}='Columns';
    para.mu=mean(mean(Y'));
    para.alpha=stats.colmeans-para.mu;
    para.beta=stats.rowmeans-para.mu;
    betainter=repmat(para.beta',1,R)';
    alphaplusbeta=repmat(para.alpha',1,m)+repmat(betainter(:)',n,1);
    if ~(int) % no interaction
        if (R>1)
            % Summation of SC_ab+SC_e
            summary{5,2}=summary{5,2}+summary{4,2};
            summary{5,3}=summary{5,3}+summary{4,3};
            summary{5,4}=summary{5,2}/summary{5,3};
            summary{2,5}=summary{2,4}/summary{5,4};
            summary{3,5}=summary{3,4}/summary{5,4};
            summary{2,6}=1-f_cdf(summary{2,5},summary{2,3},summary{5,3});
            summary{3,6}=1-f_cdf(summary{3,5},summary{3,3},summary{5,3});
            summary(4,:)=[];
        end;
        resid=Y-alphaplusbeta-para.mu;
    else 
        inter=mean(reshape(Y',R,m*n/R));
        para.alphabeta=reshape(inter,m/R,n)'-repmat(para.alpha',1,m/R) ...
            -repmat(para.beta,n,1)-para.mu;
        resid=Y-reshape(repmat(inter,R,1),m,n)';
    end;
end;


function [p,anovatab,stats] = anova1(x,group,displayopt,extra)
%ANOVA1 One-way analysis of variance (ANOVA).
%   ANOVA1 performs a one-way ANOVA for comparing the means of two or more 
%   groups of data. It returns the p-value for the null hypothesis that the
%   means of the groups are equal.
%
%   P = ANOVA1(X,GROUP,DISPLAYOPT)
%   If X is a matrix, ANOVA1 treats each column as a separate group, and
%     determines whether the population means of the columns are equal.
%     This form of ANOVA1 is appropriate when each group has the same
%     number of elements (balanced ANOVA).  GROUP can be a character
%     array or a cell array of strings, with one row per column of
%     X, containing the group names.  Enter an empty array ([]) or
%     omit this argument if you do not want to specify group names.
%   If X is a vector, GROUP must be a vector of the same length, or a
%     string array or cell array of strings with one row for each
%     element of X.  X values corresponding to the same value of
%     GROUP are placed in the same group.
%
%   DISPLAYOPT can be 'on' (the default) to display figures
%   containing a standard one-way anova table and a boxplot, or
%   'off' to omit these displays.
%
%   [P,ANOVATAB] = ANOVA1(...) returns the ANOVA table values as the
%   cell array ANOVATAB.
%
%   [P,ANOVATAB,STATS] = ANOVA1(...) returns an additional structure
%   of statistics useful for performing a multiple comparison of means
%   with the MULTCOMPARE function.
%
%   See also ANOVA2, ANOVAN, BOXPLOT, MANOVA1, MULTCOMPARE.

%   Reference: Robert V. Hogg, and Johannes Ledolter, Engineering Statistics
%   Macmillan 1987 pp. 205-206.
classical = 1;
nargs = nargin;
if (nargin>0 & strcmp(x,'kruskalwallis'))
    % Called via kruskalwallis function, adjust inputs
    classical = 0;
    if (nargin >= 2), x = group; group = []; end
    if (nargin >= 3), group = displayopt; displayopt = []; end
    if (nargin >= 4), displayopt = extra; end
    nargs = nargs-1;
end

error(nargchk(1,3,nargs));

if (nargs < 2), group = []; end
if (nargs < 3), displayopt = 'on'; end
% Note: for backwards compatibility, accept 'nodisplay' for 'off'
willdisplay = ~(strcmp(displayopt,'nodisplay') | strcmp(displayopt,'n') ...
    | strcmp(displayopt,'off'));

% Convert group to cell array from character array, make it a column
if (ischar(group) & ~isempty(group)), group = cellstr(group); end
if (size(group, 1) == 1), group = group'; end

% If X is a matrix with NaNs, convert to vector form.
if (length(x) < prod(size(x)))
    if (any(isnan(x(:))))
        [n,m] = size(x);
        x = x(:);
        gi = reshape(repmat((1:m), n, 1), n*m, 1);
        if (length(group) == 0)     % no group names
            group = gi;
        elseif (size(group,1) == m)
            group = group(gi,:);
        else
            error('X and GROUP must have the same length.');
        end
    end
end

% If X is a matrix and GROUP is strings, use GROUPs as names
if (iscell(group) & (length(x) < prod(size(x))) ...
        & (size(x,2) == size(group,1)))
    named = 1;
    gnames = group;
    grouped = 0;
else
    named = 0;
    gnames = [];
    grouped = (length(group) > 0);
end

if (grouped)
    % Single data vector and a separate grouping variable
    x = x(:);
    lx = length(x);
    if (lx ~= prod(size(x)))
        error('First argument has to be a vector.')
    end
    nonan = ~isnan(x);
    x = x(nonan);
    
    % Convert group to indices 1,...,g and separate names
    group = group(nonan,:);
    [groupnum, gnames] = grp2idx(group);
    named = 1;
    
    % Remove NaN values
    nonan = ~isnan(groupnum);
    if (~all(nonan))
        groupnum = groupnum(nonan);
        x = x(nonan);
    end
    
    lx = length(x);
    xorig = x;                    % use uncentered version to make M
    groupnum = groupnum(:);
    maxi = size(gnames, 1);
    xm = zeros(1,maxi);
    countx = xm;
    if (willdisplay), M = []; end
    if (classical)
        mu = mean(x);
        x = x - mu;                % center to improve accuracy
        xr = x;
    else
        [xr,tieadj] = tiedrank(x);
    end
    
    for j = 1:maxi
        % Get group sizes and means
        k = find(groupnum == j);
        lk = length(k);
        countx(j) = lk;
        xm(j) = mean(xr(k));       % column means
        
        if (willdisplay)           % create matrix for boxplot    
            [r, c] = size(M);
            if lk > r
                tmp = NaN;
                M(r+1:lk,:) = tmp(ones(lk - r,c));
                tmp = xorig(k);
                M = [M tmp];
            else
                tmp = xorig(k);
                tmp1 = NaN;
                tmp((lk + 1):r,1) = tmp1(ones(r - lk,1));
                M = [M tmp];
            end
        end
        
    end
    
    gm = mean(xr);                      % grand mean
    df1 = length(xm) - 1;               % Column degrees of freedom
    df2 = lx - df1 - 1;                 % Error degrees of freedom
    RSS = countx .* (xm - gm)*(xm-gm)'; % Regression Sum of Squares
else
    % Data in matrix form, no separate grouping variable
    [r,c] = size(x);
    lx = r * c;
    if (classical)
        xr = x;
        mu = mean(xr(:));
        xr = xr - mu;           % center to improve accuracy
    else
        [xr,tieadj] = tiedrank(x(:));
        xr = reshape(xr, size(x));
    end
    countx = repmat(r, 1, c);
    xorig = x;                 % save uncentered version for boxplot
    xm = mean(xr);             % column means
    gm = mean(xm);             % grand mean
    df1 = c-1;                 % Column degrees of freedom
    df2 = c*(r-1);             % Error degrees of freedom
    RSS = r*(xm - gm)*(xm-gm)';        % Regression Sum of Squares
end

TSS = (xr(:) - gm)'*(xr(:) - gm);  % Total Sum of Squares
SSE = TSS - RSS;                   % Error Sum of Squares

if (df2 > 0)
    mse = SSE/df2;
else
    mse = NaN;
end

if (classical)
    if (SSE~=0)
        F = (RSS/df1) / mse;
        p = 1 - f_cdf(F,df1,df2);     % Probability of F given equal means.
    elseif (RSS==0)                 % Constant Matrix case.
        F = 0;
        p = 1;
    else                            % Perfect fit case.
        F = Inf;
        p = 0;
    end
else
    F = (12 * RSS) / (lx * (lx+1));
    if (tieadj > 0)
        F = F / (1 - 2 * tieadj/(lx^3-lx));
    end
    p = 1 - chi2cdf(F, df1);
end


Table=zeros(3,5);               %Formatting for ANOVA Table printout
Table(:,1)=[ RSS SSE TSS]';
Table(:,2)=[df1 df2 df1+df2]';
Table(:,3)=[ RSS/df1 mse Inf ]';
Table(:,4)=[ F Inf Inf ]';
Table(:,5)=[ p Inf Inf ]';

colheads = ['Source       ';'         SS  ';'          df ';...
        '       MS    ';'          F  ';'     Prob>F  '];
if (~classical)
    colheads(5,:) = '     Chi-sq  ';
    colheads(6,:) = '  Prob>Chi-sq';
end
rowheads = ['Columns    ';'Error      ';'Total      '];
if (grouped)
    rowheads(1,:) = 'Groups     ';
end

% Create cell array version of table
atab = num2cell(Table);
for i=1:size(atab,1)
    for j=1:size(atab,2)
        if (isinf(atab{i,j}))
            atab{i,j} = [];
        end
    end
end
atab = [cellstr(strjust(rowheads, 'left')), atab];
atab = [cellstr(strjust(colheads, 'left'))'; atab];
if (nargout > 1)
    anovatab = atab;
end

% Create output stats structure if requested, used by MULTCOMPARE
if (nargout > 2)
    if (length(gnames) > 0)
        stats.gnames = gnames;
    else
        stats.gnames = strjust(num2str((1:length(xm))'),'left');
    end
    stats.n = countx;
    if (classical)
        stats.source = 'anova1';
        stats.means = xm + mu;
        stats.df = df2;
        stats.s = sqrt(mse);
    else
        stats.source = 'kruskalwallis';
        stats.meanranks = xm;
        stats.sumt = 2 * tieadj;
    end
end

if (~willdisplay), return; end

digits = [-1 -1 0 -1 2 4];
if (classical)
    wtitle = 'One-way ANOVA';
    ttitle = 'ANOVA Table';
else
    wtitle = 'Kruskal-Wallis One-way ANOVA';
    ttitle = 'Kruskal-Wallis ANOVA Table';
end
statdisptable(atab, wtitle, ttitle, '', digits);

fig2 = figure('pos',get(gcf,'pos') + [0,-200,0,0]);

if (~grouped)
    boxplot(xorig,1);
else
    boxplot(M,1);
    h = get(gca,'XLabel');
    set(h,'String','Group Number');
end

% If there are group names, use them after removing blanks
if (length(gnames) > 0)
    gnames = strrep(gnames, '|', '_');
    gstr = gnames{1};
    for j=2:size(gnames,1)
        gstr = [gstr, '|', gnames{j}];
    end
    h = get(gca,'XLabel');
    if (named)
        set(h,'String','');
    end
    set(gca, 'xtick', (1:df1+1), 'xticklabel', gstr);
end



function [p,Table,stats] = anova2(X,reps,displayopt)
%ANOVA2 Two-way analysis of variance.
%   ANOVA2(X,REPS,DISPLAYOPT) performs a balanced two-way ANOVA for
%   comparing the means of two or more columns and two or more rows of the
%   sample in X.  The data in different columns represent changes in one
%   factor. The data in different rows represent changes in the other
%   factor. If there is more than one observation per row-column pair, then
%   then the argument REPS indicates the number of observations per "cell".
%   A cell contains REPS number of rows.  DISPLAYOPT can be 'on' (the
%   default) to display the table, or 'off' to skip the display. 
%
%   For example, if REPS = 3, then each cell contains 3 rows and the total
%   number of rows must be a multiple of 3. If X has 12 rows, and REPS = 3,
%   then the "row" factor has 4 levels (3*4 = 12). The second level of the 
%   row factor goes from rows 4 to 6.
%
%   [P,TABLE] = ANOVA2(...) returns two items.  P is a vector of p-values
%   for testing row, column, and if possible interaction effects.  TABLE
%   is a cell array containing the contents of the anova table.
%
%   To perform unbalanced two-way ANOVA, use ANOVAN.
%
%   See also ANOVA1, ANOVAN.

%   Reference: Robert V. Hogg, and Johannes Ledolter, Engineering Statistics
%   Macmillan 1987 pp. 227-231. 

if (nargin<3), displayopt = 'on'; end
if (nargin < 1), error('At least one input is required.'); end
if (any(isnan(X(:))))
    error('NaN values in input not allowed.  Use anovan instead.');
end
[r,c] = size(X);
if nargin == 1,
    reps = 1;
    m=r;
    Y = X;
elseif reps == 1
    m=r;
    Y = X;
else
    m = r/reps;
    if (floor(m) ~= r/reps), 
        error('The number of rows must be a multiple of reps.');
    end
    Y = zeros(m,c);
    for i=1:m,
        j = (i-1)*reps;
        Y(i,:) = mean(X(j+1:j+reps,:));
    end
end
colmean = mean(Y);          % column means
rowmean = mean(Y');         % row means
gm = mean(colmean);         % grand mean
df1 = c-1;                  % Column degrees of freedom
df2 = m-1;                  % Row degrees of freedom
if reps == 1,
    edf = (c-1)*(r-1);% Error degrees of freedom. No replication. This assumes an additive model.
else
    edf = (c*m*(reps-1));     % Error degrees of freedom with replicates
    idf = (c-1)*(m-1);        % Interaction degrees of freedom
end
CSS = m*reps*(colmean - gm)*(colmean-gm)';              % Column Sum of Squares
RSS = c*reps*(rowmean - gm)*(rowmean-gm)';              % Row Sum of Squares
correction = (c*m*reps)*gm^2;
TSS = sum(sum(X .* X)) - correction;                    % Total Sum of Squares
ISS = reps*sum(sum(Y .* Y)) - correction - CSS - RSS;   % Interaction Sum of Squares
if reps == 1,
    SSE = ISS;
else
    SSE = TSS - CSS - RSS - ISS;          % Error Sum of Squares
end

ip = NaN;
if (SSE~=0)
    MSE  = SSE/edf;
    colf = (CSS/df1) / MSE;
    rowf = (RSS/df2) / MSE;
    colp = 1 - f_cdf(colf,df1,edf);  % Probability of F given equal column means.
    rowp = 1 - f_cdf(rowf,df2,edf);  % Probability of F given equal row means.
    p    = [colp rowp];
    
    if (reps > 1),
        intf = (ISS/idf)/MSE;
        ip   = 1 - f_cdf(intf,idf,edf);
        p   = [p ip];
    end
    
else                    % Dealing with special cases around no error.
    if (edf > 0)
        MSE = 0;
    else
        MSE = NaN;
    end
    if CSS==0,          % No between column variability.            
        colf = 0;
        colp = 1;
    else                % Between column variability.
        colf = Inf;
        colp = 0;
    end
    
    if RSS==0,          % No between row variability.
        rowf = 0;
        rowp = 1;
    else                % Between row variability.
        rowf = Inf;
        rowp = 0;
    end
    
    p = [colp rowp];
    
    if (reps>1) & (ISS==0)  % Replication but no interactions.
        intf = 0;
        p = [p 1];
    elseif (reps>1)         % Replication with interactions.
        intf = Inf;
        p = [p 0];
    end 
end

if (reps > 1),
    Table{6,6} = [];   %Formatting for ANOVA Table printout with interactions.
    Table(2:6,1)={'Columns';'Rows';'Interaction';'Error';'Total'};
    Table(2:6,2)={CSS; RSS; ISS; SSE; TSS};
    Table(2:6,3)={df1; df2; idf; edf; r*c-1};
    Table(2:5,4)={CSS/df1; RSS/df2; ISS/idf; SSE/edf;};
    Table(2:4,5)={colf; rowf; intf};
else
    Table{5,6} = [];   %Formatting for ANOVA Table printout no interactions.
    Table(2:5,1)={'Columns';'Rows';'Error';'Total'};
    Table(2:5,2)={CSS; RSS; SSE; TSS};
    Table(2:5,3)={df1; df2; edf; r*c-1};
    Table(2:4,4)={CSS/df1; RSS/df2; SSE/edf;};
    Table(2:3,5)={colf; rowf};
end

Table(1,1:6) = {'Source' 'SS' 'df' 'MS' 'F' 'Prob>F'};
Table(2:(1+length(p)),6) = num2cell(p);

if (isequal(displayopt, 'on'))
    digits = [-1 -1 0 -1 2 4];
    statdisptable(Table, 'Two-way ANOVA', 'ANOVA Table', '', digits);
end

if (nargout > 2)
    stats.source = 'anova2';
    stats.sigmasq = MSE;
    stats.colmeans = colmean;   % mean of columns
    stats.coln = m*reps;        % n for estimating column means
    stats.rowmeans = rowmean;
    stats.rown = c*reps;
    stats.inter = (reps>1);     % was an interaction term included?
    stats.pval = ip;            % p-value for interactions
    stats.df = edf;
end



return


function [g,gn] = grp2idx(s)
% GRP2IDX  Create index vector from a grouping variable.
% [G,GN]=GRP2IDX(S) creates an index vector G from the grouping
%   variable S.  S can be a numeric vector, a character matrix (each
%   row representing a group name), or a cell array of strings stored
%   as a column vector.  The result G is a vector taking integer
%   values from 1 up to the number of unique entries in S.  GN is a
%   cell array of names, so that GN(G) reproduces S (aside from any
%   differences in type).

%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/03/13 23:20:16 $

if (ischar(s))
   s = cellstr(s);
end
if (size(s, 1) == 1)
   s = s';
end

[gn,i,g] = uniquep(s);           % b=unique group names

ii = find(strcmp(gn, ''));
if (length(ii) == 0)
   ii = find(strcmp(gn, 'NaN'));
end

if (length(ii) > 0)
   nangrp = ii(1);        % this group should really be NaN
   gn(nangrp,:) = [];     % remove it from the names array
   g(g==nangrp) = NaN;    % set NaN into the group number array
   g = g - (g > nangrp);  % re-number remaining groups
end

% -----------------------------------------------------------
function [b,i,j] = uniquep(s)
% Same as UNIQUE but orders result:
%    if iscell(s), preserve original order
%    otherwise use numeric order

[b,i,j] = unique(s);     % b=unique group names

nb = size(b,1);
i = zeros(nb,1);
if (iscell(s))
   % Restore in original order
   for k=1:size(b,1)
      ii = find(strcmp(s, b(k)));
      i(k) = ii(1);  % find first instance of each element of b
   end
   isort = i;        % sort based on this order
else
   % If b is a vector, put in numeric order
   for k=1:size(b,1)
      ii = find(s == b(k));
      if (length(ii) > 0)
         i(k) = ii(1); % make sure this is the first instance
      end
   end

   % Fix up bad treatment of NaN
   if (any(isnan(b)))  % remove multiple NaNs; put one at the end
      nans = isnan(b);
      b = [b(~nans); NaN];
      x = find(isnan(s));
      i = [i(~nans); x(1)];
      j(isnan(s)) = length(b);
   end
   
   isort = b;          % sort based on numeric values
   isort(isnan(isort)) = max(isort) + 1;
end

[is, f] = sort(isort); % sort according to the right criterion
b = b(f,:);

[fs, ff] = sort(f);    % rearrange j also
j = ff(j);

if (~iscell(b))        % make sure b is a cell array of strings
   b = cellstr(strjust(num2str(b), 'left'));
end
return


Y=[ 7.56 9.68 11.65;
    9.98 9.69 10.69;
    7.23 10.49 11.77;
    8.22 8.55 10.72;
    7.59 8.30 12.36];
