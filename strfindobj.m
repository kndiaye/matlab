function [h]=strfindobj(varargin)
%strfindobj - Find obj whose property match with a given string
%   h=strfindobj(S,H,P)
%       String,Handles[gca],Property[Tag], 

S=varargin{1};
switch nargin
    case 1
        P='Tag';
        H=findobj(gca);
    case 2
        H=varargin{2};
        P='Tag';
    case 3
        H=varargin{2};
        P=varargin{2};
end

r=get(H,P);
h=[];
for i=1:length(r)
    if ~isempty(strfind(lower(r{i}),lower(S)))
        h=[h;H(i)];
    end
end
