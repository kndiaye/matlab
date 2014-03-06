function [handles,ee]=barerrorbar(x, y, e, orient, varargin)
%BARERRORBAR : Bar graph with error bars.
%    BARERRORBAR(X,Y,E,ORIENT) draws the columns of the M-by-N matrix Y as
%    M groups of N vertical bars.
%    The M-long vector X must be monotonically increasing or decreasing.
%    Error E should also be M-by-N matrices (absolute value is used).
%    Orientation of moustaches is set by ORIENT 1:up, -1:down, 0:both
%    (default), NaN:one-sided
%
%   BARERRORBAR(Y)
%
if nargin==1
    y=x;
    e=stderr(y,ndims(y));
    x=1:size(y,1);
    y=mean(y, ndims(y));
elseif nargin<3
    if length(x)==size(y,1)
        e=stderr(y,ndims(y));
        y=mean(y, ndims(y));
    else
        e=y;
        y=x;
        x=1:size(y,1);
    end
end
% if size(y,1)==1
%     y=y';
% end
% if size(e,1)==1
%     e=e';
% end
if length(x) ~= size(y,1) | length(x) ~= size(e,1) | size(y,1) ~= size(e,1)
    error('BARERRORBAR: X-length, Y-lines, E-lines dimensions don''t match!')
end
hb=bar(x,y, varargin{:});
xb=get(hb, 'XData');
if ~iscell(xb)
    xb={xb};
end
if nargin<4
    orient=0;
end
hold on

for ibar=1:length(xb)
    %       xe=xb{ibar}([1 3],:);
    %       xe=mean(xe);
    %       xe=xe(1,:)+sum(diff(xe(1,:)))/2;
    if str2num(version('-release'))<=13
        xe=get(hb,'Xdata');
    else
        xe=forcecell(get(cell2mat(forcecell(get(hb, 'Children'))),'Xdata'));
        xe=xe{ibar};
    end
    if iscell(xe)
        xe=xe{ibar};
    end
    xe=xe(1:2:end,:);
    xe=mean(xe);

    if orient>0
        ee(:,2)=e(:,ibar);
        ee(:,1)=0;
    elseif orient<0
        ee(:,1)=e(:,ibar);
        ee(:,2)=0;
    elseif isnan(orient)
        ee(:,1)=(1-sign(y(:,ibar))).*e(:,ibar);
        ee(:,2)=(1+sign(y(:,ibar))).*e(:,ibar);
    else
        ee(:,1)= e(:,ibar);
        ee(:,2)=-e(:,ibar);
            
    end

    try
        if verLessThan('matlab', '7') % str2num(version('-release'))<=13
            h=errorbar(xe,y(:,ibar), ee(:,1), ee(:,2) ,'.k');
        else
            h=errorbar('v6', xe,y(:,ibar),ee(:,1), ee(:,2) ,'.k');
        end
    catch
            h=errorbar('v6', xe,y(:,ibar),ee(:,1), ee(:,2) ,'.k');
    end
    delete(h(2));


    % set(h(2), 'marker', 'none')
    he(ibar)=h(1);
    c=get(hb(ibar), 'FaceColor');
    if isnumeric(c)
        set(he(ibar), 'Color', c);
    else
        c=get(hb(ibar), 'EdgeColor');
        if isnumeric(c)
            set(he(ibar), 'Color', c);
        end
    end
end
hold off
% p=get(gca, 'Children');
% set(gca, 'Children', p([end-1 end 1:end-2]));
% flipud(get(gca, 'Children')))
if nargout > 0
    handles=[hb,he];
end