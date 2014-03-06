function [xywh,wh,scr] = RectPosition(wh,scr,varargin)
% RectPosition - Deprecated see RectAlign
warning('MyPsychtoolbox:RectPositionDeprecated', 'RectPosition is deprecated; use RectAlign() instead');
[xywh,wh,scr] = RectAlign(wh,scr,varargin{:});
