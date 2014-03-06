function  varargout = figure_call(name, focus)
%FIGURE_CALL - One line description goes here.
%   [hf] = figure_call(name) creates figure with name if it does not exist
%   [hf] = figure_call(name,focus) if focus=1 (default) the figuer get the
%   focus (it is then the current window)
%   
%   Example
%       >> figure_call(name,focus)
%
%   See also: 

% Author: K. N'Diaye (kndiaye01<at>yahoo.fr)
% Copyright (C) 2010 
% This program is free software; you can redistribute it and/or modify it
% under the terms of the GNU General Public License as published by  the
% Free Software Foundation; either version 2 of the License, or (at your
% option) any later version: http://www.gnu.org/copyleft/gpl.html
%
% ----------------------------- Script History ---------------------------------
% KND  2010-01-21 Creation
%                   
% ----------------------------- Script History ---------------------------------

hf = findobj(0,'-depth', 1, 'type', 'figure', 'name',name);
if isempty(hf)
    hf=figure('name',name);
    set(hf, 'PaperType', 'a4letter');
end
if nargin<2 || isempty(focus)
    focus=1;
end
if focus
    figure(hf)
end
if nargout>0
    vaerargout= {hf};
end
% 
% % Example how to adjust your figure properties for
% % publication needs
% s = hf;
% % Select the default font and font size
% % Note: Matlab does internally round the font size
% % to decimal pt values
% set(s, 'DefaultTextFontSize', 10); % [pt]
% set(s, 'DefaultAxesFontSize', 10); % [pt]
% set(s, 'DefaultAxesFontName', 'Times New Roman');
% set(s, 'DefaultTextFontName', 'Times New Roman');
% % Select the preferred unit like inches, centimeters,
% % or pixels
% set(s, 'Units', 'centimeters');
% pos = get(s, 'Position');
% pos(3) = 8; % Select the width of the figure in [cm]
% pos(4) = 6; % Select the height of the figure in [cm]
% set(s, 'Position', pos);
% set(s, 'PaperType', 'a4letter');
% % From SVG 1.1. Specification:
% % "1pt" equals "1.25px"
% % "1pc" equals "15px"
% % "1mm" would be "3.543307px"
% % "1cm" equals "35.43307px"
% % "1in" equals "90px"