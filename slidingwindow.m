function [Y,W] = slidingwindow(X,N,dim,W,Wnorm,padval,fun,direction,varargin)
% SLIDINGWINDOW - Sliding window filter
%   Y = slidingwindow(X,N)
%   Y = slidingwindow(X,N,dim)
%   Computes a sliding window filtering of width N along a given dimension
%   of X (default: use the first non-singleton dimension)
%   Note: The floor(N/2) first and last samples are computed with NaN padding
%         Contrary to BUFFER, SLIDINGWINDOW works on matrices
%   See also: BUFFER
%
%   [Y,w] = slidingwindow(X,N,dim,W,Wnorm)
%   Computes with a given windowing.
%   W can be:
%       - A vector of values (e.g. [0:10 9:-1:0] for a triangular windowing) 
%       - A function name (e.g. 'hanning')
%       - A cell { funname arguments }, e.g. {'gausswin',5} (see: GAUSSWIN)
%   N is not used (i.e. N is forced to the length of the windowing vector.)
%   The W vector can be normalized so that norm(W,Wnorm)=1 (See NORM)
%   Use Wnorm=[] to prevent normalizing W (default). 
%
%   [Y,w] = slidingwindow(X,N,dim,W,Wnorm,padval)
%   padval: padding value on both sides
%
%   Y = slidingwindow(X,N,dim,window,wnorm,fun,direction,funoptions)
%   Instead of computing the sum of windowed values, it will uses
%   'fun' (a function handle/name) using additional options, if any.
%   E.g.
%       >> slidingwindow(X,10,1,[],[],0,'var') will compute local variance

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2005 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND   2005-12-15 Creation
%       2007-04-03 Updated, now allows specific padding
% KND   2009-04-15 Updated: remove borders
%
% ----------------------------- Script History ---------------------------------

% Author: KND
% Created: Dec 2005
% Copyright 2005
if nargin<3 || isempty(dim)
    dim = min(find(size(X)>1));
    if isempty(dim), dim = 1; end
end
if dim>1
    ndX=ndims(X);
    X=permute(X,[dim 1:dim-1 dim+1:ndX]);
end
sX=[size(X) 1];
X=X(:,:);
Y=zeros(size(X));
if numel(N)>1 || numel(dim) > 1 
    error('N and dim should be a single value');
end
if nargin<4
    W=[];    
elseif ~isempty(W)
    N=length(W);
elseif isempty(N)
    error('N and W cannot be both []!')
end
if nargin<5
    Wnorm=[];
end
if nargin<6 || isempty(padval)
    padval=NaN;
end
if nargin<7 || isempty(fun)
    fun='';
end
if nargin<8 || isempty(direction)
    direction = 0;
end

if isempty(W)
    if ~isempty(fun)
        W=ones(N,1);
    else
        W=ones(N,1)/N;
    end
elseif iscell(W)
    W=feval(W{1},N,W{2:end});
elseif ischar(W)
    W=feval(W,N);
elseif isnumeric(W)
    W=W;
end
W=W(:);
if ~isempty(Wnorm)
    W=W./norm(W,Wnorm);
end

padding = repmat(padval,floor(N/2),size(X,2));
%padval=2*padval;
switch fun
    case {'', 'sum'}
        %for i=1:size(X,2)
            %ya=       filter(flipud(W),1,[padval+zeros(floor(N/2),1);       X(:,i) ;padval+zeros(floor(N/2),1)]);
            %yb=flipud(filter(W        ,1,[padval+zeros(floor(N/2),1);flipud(X(:,i));padval+zeros(floor(N/2),1)]));
            %ya=ya(N:end-1+mod(N,2));
            %yb=yb(2-mod(N,2):end-N+1);
            %Y(:,i)=(ya+yb)/2;
            %Y(:,i)=filter(W,1,
        %end
        
        Y=filter(W,1,[ padding; X ;padding]);
        Y(1:(N-mod(N,2)),:)=[];

    case 'std'
        warning('Uncjhecked result!!!')
        W=diag(W);
        for i=1:size(X,2)
            ya=W*buffer([X(:,i);padval+zeros(floor(N/2),1)],N,N-1);
            yb=fliplr(W*buffer([flipud(X(:,i));padval+zeros(floor(N/2),1)],N,N-1));
            ya=std(ya(:,floor(N/2)+1:end));
            yb=std(yb(:,1:end-floor(N/2)));
            
            ya=W*buffer([padval+zeros(floor(N/2),1);X(:,i);padval+zeros(floor(N/2),1)],N,N-1);
            yb=fliplr(flipud(fliplr(W))*buffer([padval+zeros(floor(N/2),1);flipud(X(:,i));padval+zeros(floor(N/2),1)],N,N-1));
            ya=std(ya(:,N:end-1+mod(N,2)));
            yb=std(yb(:,2-mod(N,2):end-N+1));
                        
            Y(:,i)=(ya+yb)'/2;
%             Y(:,i)=std(W*buffer(X(:,i),N,N-1),[],1)+fliplr(std(W*buffer(flipud(X(:,i)),N,N-1),[],1))';
%             Y(:,i)=Y(:,i)/2;
        end
        W=diag(W);
    otherwise
        W=diag(W);
        if exist('buffer', 'builtin')
            error('unverified')
            if direction>=0
                for i=1:size(X,2)
                    Y(:,i)=Y(:,i)+feval(fun,W*buffer(X(:,i),N,N-1),varargin{:})                    
                end
            elseif direction <= 0
                for i=1:size(X,2)
                    Y(:,i)=Y(:,i)+fliplr(feval(fun,W*buffer(flipud(X(:,i)),N,N-1),varargin{:}));
                end
            else
                error('Wrong direction');
            end
        else % No buffer function        
            N2 = floor(N/2);
            L = size(X,1);
            if direction>=0
                for i=1:size(X,2)
                    for j=1:L % ceil(N/2):size(X,1)-floor(N/2)                                        
                        Y(j,i)=feval(fun,W*[...
                            padding(end+((N2-(N-j)+1):0),i); ...
                            X(max(1,j-N2):min(L,j+N2),i); ...
                            padding(1:(N2-(L-j)),i)]);
                    end
                end
            elseif direction <= 0
                for i=1:size(X,2)
                    for j=1:L % ceil(N/2):size(X,1)-floor(N/2)                                        
                        Y(j,i)=feval(fun,W*[...
                            padding(end+((N2-(N-j)+1):0),i); ...
                            X(max(1,j-N2):min(L,j+N2),i); ...
                            padding(1:(N2-(L-j)),i)]);
                    end
                end
             else
                error('Wrong direction');
            end
        end
        if direction==0
            Y=Y./2;
        end
        W=diag(W);
end
Y=reshape(Y, [sX(1), sX(2:end)]);
if dim>1
    Y=ipermute(Y,[dim 1:dim-1 dim+1:ndX]);
    %Y=permute(Y, [2:dim 1 dim+1:ndX]);
end

return
% use FILTER instead of BUFFER (which requires the signal processing toolbox)
% Y(:,i)=[mean(w'*buffer(X(:,i),N,N-1),1)+fliplr(mean(w'*buffer(flipud(X(:,i)),N,N-1),1))]';
% Y(:,i)=filter(w,1,X(:,i),[],1);%+flipud(filter(w,1,flipud(X(:,i)),[],1));
% Y(:,i)=Y(:,i)/2;

%             Y(:,i)=(W'*buffer(X(:,i),N,N-1)+fliplr(W'*buffer(flipud(X(:,i)),N,N-1)))'/2;

% FILTER is a causal filter!!
%             ya=[filter(W,1,X(:,i),[],1);zeros(floor(N/2),1)];
%             ya=ya(floor(N/2)+1:end);
%             yb=flipud([ filter(W,1,flipud(X(:,i)),[],1) ; zeros(floor(N/2),1)]);
%             yb=yb(1:end-floor(N/2));
%             Y(:,i)=(ya+yb)/2;            


% OUT OF MEMORY error with buffer 
% for i=1:size(X,2)
%             ya=W'*buffer([X(:,i);padval+zeros(floor(N/2),1)],N,N-1);
%             yb=fliplr(W'*buffer([flipud(X(:,i));padval+zeros(floor(N/2),1)],N,N-1));
%             ya=ya(floor(N/2)+1:end);
%             yb=yb(1:end-floor(N/2));
%             Y(:,i)=(ya+yb)'/2;
%         end

