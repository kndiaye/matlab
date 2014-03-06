function [X,nX,cX] = normalize(X,P,D,varargin)
% normalize() - normalize a vector or a matrix
%[Y,nX,cX]=NORMALIZE(X,P,D)
% Vector-byvector normalization of data X
% X: vector or 2D matrix of data
% P: norm to be used, is a number [default: 2] of -inf or +inf or:
%     - 'center'/'centered' set the mean to 0
%     - 'unity' range of data is linearly mapped to [0:1]
%        (the signed maximum is set to 1; the signed minimum is set to 0)
%     - 'rms' normalize by the rootmeansquare
%     - 'z' z-transform
%     - 'baseline' e.g. NORMALIZE(X,'baseline',1,[1:50]) to compute the
%                       baseline on the first 50 samples
%     - 'baseline', dim, [samples], function, options...
%       to compute baseline using a specific norm. E.g.
%       normalize(X,'baseline',2,'median',[1:100]) normalize according to
%       median of the 100 first samples
%
%    See: norm()
% D: dimension(s) along which to normalize (default: first non singleton)
% Y: normalized data
% nX: value(s) of the norm(s)
% cX: centering value

% if ndims(X)>2
%     error('Normalize apply only to vector or 2D-matrices')
% end
%
sX=[size(X)];

if nargin<3
    if max(sX)==prod(sX)
        % it is a vector
        [ignore, D]=max(size(X));
    else
        % it is a matrix
        D=1;
    end
end
sX=[sX ones(1,1+length(D))];
if nargin<2
    P=[];
end
if isempty(P)
    P=2;
end

pX=[];
if length(D)>1
    pX=[D setdiff(1:length(sX),D)];
    X=permute(X,pX);
    X=reshape(X, prod(sX(D)), []);
    D=1;
end

[cX,nX] = normalize2(X,P,D,varargin{:});

nsX=size(X);
nsX(~ismember(1:length(sX),D))=1;
if ~isequal(cX,0) 
    if numel(cX)>1
        cX=repmat(cX,nsX);
    end
    X=X-cX;
end
if ~isequal(nX,1)
    if numel(nX)>1
        nX=repmat(nX,nsX);
    end
    X=X./nX;
end
if ~isempty(pX)
    X=reshape(X,sX(pX));
    X=ipermute(X,pX);
end

return

function [cX,nX] = normalize2(X,P,D,varargin)
sX=[size(X)];
cX=0;
if isnumeric(P)
    switch P
        case inf
            nX=max(abs(X),[],D);
        case -inf
            nX=min(abs(X),[],D);
        otherwise
            nX=sum(abs(X).^P,D).^(1/P);
    end
else
    if ischar(P)
        P=lower(P);
        switch P           
            case {'center', 'centered'}
                cX=mean(X,D);
                nX=.0*cX+1;
                if nargin>3
                    error('There should be no extra argument for norm ''%s''',P);
                end
            case 'rms'
                nX=sqrt(mean(abs(X).^2,D));
                if nargin>3
                    error('There should be no extra argument for norm ''%s''',P);
                end
            case 'unity' % rescale between 0 and 1
                cX=min(X,[],D);
                nX=max(X,[],D)-cX;
                if nargin>3
                    error('There should be no extra argument for norm ''%s''',P);
                end                
            case {'z', 'zscore', 'z-score'}
                cX=mean(X,D);
                nX=std(X,[],D);
                if nargin>3
                    error('There should be no extra argument for norm ''%s''',P);
                end
            case 'baseline'
                if nargin<4
                    error('# of samples for baseline not specified!');
                end
                b = varargin{1};
                if isempty(b)
                    b=1:sX(D);
                elseif numel(b)==1 && sX(D)>100
                    warning('Baseline on one sample ??? If it''s what you want...');
                end
                if nargin<5 % default baseline correction is centering on mean
                    [cX,nX] = normalize2(subarray(X,b,D),'center',D);
                else
                    [cX,nX] = normalize2(subarray(X,b,D),varargin{2},D,varargin{3:end});                 
                end
            case {'(x-a)/b'}
                if nargin<5
                    error('a and b factors required!');
                end
                cX = varargin{1};
                nX = varargin{2};
            case {'ax+b'}
                if nargin<5
                    error('a and b factors required!');
                end
                a = varargin{1};
                b = varargin{2};
                nX=1./a;
                cX=-b./a;
            case 'max' % rescale between 0 and 1
                cX=max(X,[],D);
                nX=0.*cX+1;
                if nargin>3
                    error('There should be no extra argument for norm ''%s''',P);
                end
            case 'min' % rescale between 0 and 1
                cX=min(X,[],D);
                nX=0.*cX+1;
                if nargin>3
                    error('There should be no extra argument for norm ''%s''',P);
                end

            otherwise
                if strcmp(P,'mean')
                    error('Didn''t you mean ''center'' instead of ''mean''?');
                else
                    error('Unknown norm: ''%s''', P);
                end
        end
    else
        % {'translation' 'scaling'} format
        % e.f. ['mean' 'std'}  for z-score
        if length(P)<2
            error('Missing info in norm: {''translation'' ''scaling''}');
        end
        if isnumeric(P{1})
            cX=X(1,:).*0+P{1};            
        else
            if nargin>3
                cX=feval(P{1},X,varargin{1}{1}{1:end});
            else
                cX=feval(P{1},X);
            end
        end
        if isnumeric(P{2})
            if numel(P{2})==1
                nX=cX.*0+P{2};
            else
                nX=cX;
                nX(:)=P{2}(:);
            end
        else
            if nargin>3 && numel(varargin{1})>1
                nX=feval(P{2},X,varargin{1}{2}{1:end});
            else
                nX=feval(P{2},X);
            end
        end
    end
end
return