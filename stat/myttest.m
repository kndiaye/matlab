function [pmap, tmap, df, d, sigma_d, g] = myttest(X1, X2, dim, wtest, varcorr)
%myttest() Student's two-tailed t-tests for N-dimensional array
%
%       [P]= MYTTEST(X1, X2, dim) gives the probability that Student's t
%       calculated on data X1 and X2, sampled from two distributions
%       is higher than observed, i.e. the "significance" level.
%       This is used to test whether two samples have significantly
%       different means: X1 > X2 OR X1 < X2 (i.e. it is a two-tailed test).
%       Observations (ie. subjects) are supposed to be along the given
%       dimension. If not given, perform the test along the first non
%       singleton dimension.
%
%       MYTTEST(X, r,dim) with r single number specifying the dimension
%       from which the two groups are formed, therefore,
%                   size(X,r) must be equal to 2
%       (and r must be different from dim)
%
%       MYTTEST(X1, X2, dim, wtest) : wtest specify the test to be used:
%             'ttest'  : t-test for equal variances [default]
%             'uttest' : t-test for unequal variances
%             'pttest' : t-test for paired samples
%
%       MYTTEST(X1, X2, dim, wtest, varcorr) apply a matrix 'varcorr' on
%       the denominator (ie. on empirical variance) before computing the
%       T-value.
%
%       MYTTEST(X1, [], [dim, ...]) performs a one-sample t-test.
%
%       [P, T, CI, d, g, sigma_d] = TTEST(...) gives this probability P and
%       the value of Student's t in T. The smaller P is, the more
%       significant the difference between the means.
%       d is the Cohen's d measure of the effect size.
%       sigma_d is such that 1.96*sigma is the 95% Confidence Interval on d
%       g is Hedges' measure of effect size ().
%       E.g. if P = 0.05 or 0.01, it is very likely that the
%       two sets are sampled from distributions with different
%       means. An effect size of d=0.2 is considered as small; d=0.5 is
%       medium and d>0.8 indicates a big effect.
%
% Example: X1 and X2 are [ N x [voxelsX x voxelsY x voxelsZ ] fMRI-volume ]
%          corresponding to two conditions run with the same pool
%          of (N) subjects
%          To test whether some voxel value differ significantly
%          between conditions: myttest(X1,X2,1,'pttest')
%

% Adapted from C. Goutte's functions by K. N'Diaye, 2005/04/20
if nargin<4
    wtest='ttest';
end
if nargin==1
    X2=[];
end
if isequal(X2,0) || isempty(X2)
    X2=0.*X1;
    wtest='onesample';
elseif numel(X2)==1;
    if ~isequal(size(X1,X2),2)
        error('MyTTest:WrongDimension','Dimension along which the comparison is made must have only 2 levels')
    end
    r=X2;
    X2=subarray(X1,2,r);
    X1=subarray(X1,1,r);
end
if nargin<3,
    dim=[];
end
UseVarCorr=0;
if nargin>4
    UseVarCorr=1;
end
if not(isnumeric(dim)) & ischar(dim)
    wtest=dim;
    dim=[];
end
if isempty(dim)
    % Determine which dimension to use
    dim = min(find(size(X1)~=1));
    if isempty(dim), dim = 1; end
end
if dim<1
    error('myttest: wrong dimension argument')
end
if dim>1
    p=[ dim, 1:dim-1 dim+1:ndims(X1) ];
    X1=permute(X1, p);
    X2=permute(X2, p);
end

s1=size(X1);
s2=size(X2);
if not(isequal(s1(2:end), s2(2:end)))
    error('myttest: X1 and X2 must be the same size along the variable''s dimension(s)')
end
n1=size(X1,1);
n2=size(X2,1);
X1=X1(:,:);% reshape(X1,[n1 prod(s1)/n1 ]);
X2=X2(:,:);% reshape(X2,[n2 prod(s2)/n2 ]);

tmap=repmat(NaN,1,prod(s1(2:end)));
pmap=tmap;
d=pmap;

if isequal(s1, s2)
    k=find(all(X1 == X2));
    pmap(k)=1;
    tmap(k)=0;
else
    k=[];
end

I=find(all(isfinite(X1))&all(isfinite(X2))); % make a test only on 'finite' numbers
I=setdiff(I,k); % remove columns which are identical in X1 and X2
nI=length(I);
if nI<size(X1,2)
    warning('myttest:SubsetOfSamples', sprintf('ttest will be performed on %d (numeric) values out of %d (others are identical)', nI, ...
        size(X1,2)));
end
a1=mean(X1(:,I));
a2=mean(X2(:,I));
v1=var(X1(:,I));
v2=var(X2(:,I));

switch lower(wtest)
    case 'onesample'
        df = n1 - 1;
        n = n1; 
        pvar = v1 ;       
        a2 = 0;       
        if nargout>2
    		d(I)=(a1)./sqrt((v1)./2);
		end

    case 'ttest'
        df = n1 + n2 - 2 ;
        n = 1./(1./n1 + 1./n2);
        % Pooled variance
        pvar = ((n1 - 1) * v1 + (n2 - 1) * v2) ./ df ;        
        
    case 'uttest'
        n =  1./(1./n1 + 1./n2)  ;
        pvar = (v1 ./ n1 + v2 ./ n2) ;
        % Welch-Satterthwaite equation to approximate pooled d.f.:
        df =  pvar .* pvar ./  ( ...
            (v1 ./ n1) .* (v1 ./ n1) ./ (n1 - 1) + ...
            (v2 ./ n2) .* (v2 ./ n2) ./ (n2 - 1) );
        pvar = n.* pvar ;
        
    case {'paired' 'pttest'}
        wtest='paired';
        if ~isequal(s1,s2)
            error('Sizes of X1 and X2 should be equal for paired test.')
        end
        if any(a1(:) ~= a2(:))
            % use abs to avoid numerical errors for very similar data
            % for which v1+v2-2cab may be close to 0.
            df  = n1 - 1 ;
            cab = sum((X1(:,I) - repmat(a1,[n1 1])) .* (X2(:,I) - repmat(a2,[n1 1]))) / (n1 - 1) ;
            n = n1;
            pvar = abs(v1 + v2 - 2 .* cab) ;
            
            if nargout>2
                d(I) = (a1-a2)./sqrt(pvar./2);
                warning('Paired variance used for computing d');
            end
        else
            warning('myttest:IdenticalSamples',['myttest: data are too similar to be compared, try using' ...
                ' ''abs'' on your data']);
            t = zeros(1,nI);
            p = ones(1,nI);
        end
        
    otherwise
        error('Unknown test')
end
if UseVarCorr
    pvar = varcorr*pvar;
end

t = (a1 - a2) ./ sqrt( pvar ./ n ) ;
p = betainc( df ./ (df + t.*t), df/2, 0.5) ;
pmap(I)=p;
tmap(I)=t;

if nargout>3
    d    = pmap.*NaN;
    d(I) = (a1-a2)./sqrt(pvar);
    sigma_d = sqrt(n/n1/n2 + d.^2/2/n); 
    if isequal(wtest,'paired')
        warning('Paired variance used for computing Cohen''s d');
    end
end
if nargout>4    
    g = d.*(1-3./(4*(n1+n2)-9));
end
% reshape the output so that it matches the input dimensions
if length(s1)>2
    rsize = @(x)reshape(x,s1(2:end));
    pmap=rsize(pmap);
    tmap=reshape(tmap,s1(2:end));
    if nargout>3
        d=reshape(d,s1(2:end));
        sigma_d = rsize(sigma_d);
    end
    if nargout>5
        g=reshape(g,s1(2:end));
    end    
end
if nargout == 0
    figure
    if numel(2)==1
        a2=a1.*0+a2;
    end
    if numel(a1)>1
        x=1:numel(a1);
    else x=1:2
    end
    barerrorbar(x, [a1(:) a2(:)]', sqrt([v1(:)/n1 v2(:)/n2])',0)
    legend({'Mean' 'S.E.'})
end
