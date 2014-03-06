function varargout = IOPort(varargin)
% pseudo function for IOPort
[keyIsDown, secs, keyCode] = KbCheck;

varargout={find(keyCode) [] []};
