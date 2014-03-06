function [ho]=raiseobj(ho,n)
%raiseobj - Raise a graphic object at the top of its peers in an axe.
% ho = raiseobj : raises current graphic object
%
% ho = raiseobj(ho) : raises the object(s) whose handle(s) is/are ho
%
% ho = raiseobj({tag, 'value'}) raises object(s) that match the tag/value
%       pair
%
% ho = raiseobj(ho,n)
%       If n<0 : move n layers towards the first position, makes it overlay
%       the other objects. If n=-Inf: at the top (default) 
%       If n>0 : move n layers upwards, if n=+Inf: at the bottom 
%

%not anymore
% NB: All objects (ho) should belong to the same axes

% Created by KND, 2004/??/??

if nargin==0
    ho=[];
    n=[];
end
if nargin==1
    n=[];
    if isnumeric(ho)
        if length(ho)>1
            % eif not(ishandle(ho))
        elseif ~ishandle(ho)
            n=ho;
            ho=[];
        end
    elseif iscell(ho)
        ho=findobj(ho{:});
        if isempty(ho)
            warning('raiseobj:NoMatch', 'No object found matching the serach')
            return
        end
    end
end
if isempty(ho)
    ho=gco;
end
if isempty(n)
    n=+Inf;
end
for io = 1:numel(ho)
    ha=get(ho(io), 'Parent');
    % find peers of the current object
    hp=get(ha, 'Children');
    % gets its rank among its peers
    idx=find(ho(io)==hp);
    hp(idx)=[];
    idx=idx-n-length(idx);
    idx=max(idx, 0);
    idx=min(idx, length(hp));
    hp=[hp(1:idx); ho(io); hp(idx+1:end)];
    set(ha, 'Children', hp);
    if ~isequal(ha,0)
    else
        % object is thus a figure
    end
end