function varargout = clickableLegend(varargin)
% clickableLegend is a wrapper around the LEGEND function that provides the
% added functionality to turn on and off (hide or show) a graphics object
% (line or patch) by clicking on its text label in the legend. Its usage is
% the same as the <a href="matlab: help legend">LEGEND</a> function. For
% further information please see the LEGEND documentation.
%
% Notes: 
% 1. If you save the figure and re-load it, the toggling functionality
% is not automatically re-enabled. To restore it, simply call clickableLegend
% with no arguments.
%
% 2. To prevent the axis from automatically scaling every time a line is
% turned on and off, issue the command: axis manual
%
% Example 1:
% z = peaks(100);
% plot(z(:,26:5:50))
% grid on;
% axis manual;
% clickableLegend({'Line1','Line2','Line3','Line4','Line5'}, 'Location', 'NorthWest');

% Example 2:
% plot(1:10,1:10,'x', 1:10,10:-1:1,'r-', 1:10,rand(1,10)*5,'b:');
% clickableLegend('Line1','Line2','Line3');
% hgsave(gcf, 'testfig.fig');
% hgload testfig.fig
% clickableLegend


% Create legend as if it was called directly
[varargout{1:nargout(@legend)}] = legend(varargin{:});

% Extract what is needed for the rest of the function and fix varargout
[leghan, objhan, plothan] = varargout{1:4}; %#ok<NASGU>
varargout = varargout(1:nargout);

% At this point, we can quit and behavior would be equivalent to calling
% just legend.

% Set the callbacks
for i = 1:length(plothan)
    set(objhan(i), 'HitTest', 'on', 'ButtonDownFcn',...
        @(varargin)togglevisibility(objhan(i),plothan(i)),...
        'UserData', true);
end


function togglevisibility(hObject, obj)
if get(hObject, 'UserData') % It is on, turn it off
    set(hObject, 'Color', (get(hObject, 'Color') + 1)/1.5, 'UserData', false);
    set(obj,'HitTest','off','Visible','off','handlevisibility','off');
else
    set(hObject, 'Color', get(hObject, 'Color')*1.5 - 1, 'UserData', true);
    set(obj, 'HitTest','on','visible','on','handlevisibility','on');
end
