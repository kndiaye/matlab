function [onsets,names,epochs,durations,offsets,header] = read_ptx(filename)
% read_ptx() - read PTX-formatted file
% Usage:
%   [onsets,names,epochs] = read_ptx(filename) reads a PTX formatted file
%   [onsets,names,epochs,durations,offsets,header] = ...
%       also reads extra info (if provided in PTX file)
%
%Nota bene:
%       onsets are in seconds (even for PTX v.1  files)
%       epochs start at 1, if not specified in the file, epochs(:) = NaN
%
% See also: read_lena(), read_lena_events()

% Author: Karim N'Diaye, CRICM, CNRS, 01 Jan 2010

if ~exist(filename, 'file')
    error('read_ptx:FileNotFound','File not found: %s',filename)
end
% version info:
version = textread(filename,'%s',1);
version = version{1};
if ~isequal(regexp(version,'#'),1)
    version = 'PTX_V1.0 (assumed)';
end
header = {};
switch version
    case '#PTX_V2.0'
        content = textread(filename,'%s','delimiter','\n');
        header = content(strmatch('#',content));
        try
            [epochs,onsets,names,durations,offsets]=textread(filename, '%d%f%s%f%f', 'commentstyle', 'shell');
        catch
            [onsets,names,durations,offsets]=textread(filename, '%f%s%f%f', 'commentstyle', 'shell');
            epochs = onsets.*NaN;
        end        
    case { '#PTX_V1.0' 'PTX_V1.0 (assumed)' }
        [onsets,names]=textread(filename, '%f%s', 'commentstyle', 'shell');
        onsets    = onsets/1000;
        epochs    = onsets.*NaN;
        durations = onsets.*NaN;
        offsets   = onsets.*NaN;
    otherwise
        error('Unknown PTX version: %s', version);
end
epochs = epochs+1;
