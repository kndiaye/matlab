function [h]=plotpatch(y,varargin)
% plotpatch - plots a "crenelated" patch surface along a x axis (piecewise constant)
% see also: pval2patch
if nargin<2
    x=[];
    options={};
elseif nargin>=2
    if ischar(varargin{1})
       options=varargin;
       x=[];
    else
        x=y;
        y=varargin{1};
        options={varargin{2:end}};
    end
end

if isempty(x)
    x=1:length(y);
end
p=logical(p);
% one patch per col
dp=diff(p);
fdp=find(dp);
pfdp=p(fdp);
