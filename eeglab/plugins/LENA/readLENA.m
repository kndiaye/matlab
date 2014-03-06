% read_lena() - read LENA header & data
%
% Usage:
%   >> [header data lena_tree] = read_lena(lenafile)
%
% Required Input:
%   lenafile = LENA header file
% Available options:
% 	device -> 'ALL' (default)|'MEG'|'EEG'|'EEG+MEG'|'DC'
%	trials -> Trials to import as list of indices (default: [] = 'all')
%	timewindow -> Default: [] = 'all'
%
% Outputs:
%  header = header info (from reading the xml heder file)
%   data = cell array of data (one cell by trial)
%
% Author: Karim N'Diaye, CNRS-UPR640, 01 Jan 2004
%
% See also:
%   POP_READLENA, EEGLAB

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) 2004, CNRS - UPR640, N'Diaye Karim,
% karim.ndiaye@chups.jussieu.Fr
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% $Log: readegi.m,v $
% Revision 0.1  2004/01/01
% First alpha version for EEGLAB release 4.301

function [header data lena_tree] = readLENA(lenafile,varargin)

if nargin < 1
    help(mfilename);
    return;
end;
binary_extensions = {'.bin' '.data'};


lena_tree = xmltree(lenafile);
header = convert(lena_tree);

if nargout<2
    return
end

if nargin==2
    data_filename = varargin{1};
    if isfield(header, 'data_filename')
        warning('Overloading binary data filname from header (%s) to: %s', header.data_filename, data_filename);
    end
    header.data_filename = data_filename;
end


if ~isfield(header, 'data_filename')
    header.data_filename ='';
    for i=1:length(binary_extensions)
        data_filename = [lenafile(1:end-5) binary_extensions{i} ];
        if exist(data_filename, 'file')
            header.data_filename = data_filename;
            warning('Assumed binary data file not specified in header... Found possible match: %s', data_filename);
            break;
        end
    end
end
if isempty(header.data_filename)
    error('No datafile')
end

fprintf('Importing data from binary file...\n')

if strcmp(header.data_format,'LittleEndian')
    data_fid = fopen(header.data_filename,'r','l');
elseif strcmp(header.data_format,'BigEndian')
    data_fid = fopen(header.data_filename,'r','b');
else
    warning('No data_format provided');
    data_fid = fopen(header.data_filename,'r');
end

% Read the offset because this info is not provided in header!
header.data_offset = getData_offset(lena_tree);
fseek(data_fid,data_offset);

% Get data type :
switch(data_type)
    case 'unsigned fixed'
        data_type='uint';
    case 'fixed'
        data_type='int';
    case 'floating'
        data_type='float';
    otherwise
        error('Error : data_type wasn t found, which is required.')
        return
end
% Get the data size :
header.data_size = getData_size(lena_tree);
data = fread(fid,length(time_dim),data_type);
% first sensor 1, from sample 1 to last (537264)


%
% fprintf('Importing channel location information')
% Channel=getfield(load([studyname '_channel']), 'Channel');
% chanlocs=LENAchannels2chanlocs( Channel );
%
% i=1;
% %datafilename=sprintf('%s%d.mat', database , i);
% f=dir(sprintf('%s*.mat', database));
% f=strvcat({f.name});
% f=f(:,length(database)+1:end);
% trials=str2num(char(strrep(cellstr(f), '.mat', '')));
% trials=sort(trials);
%
% h = waitbar(0,'Importing Datafiles. Please wait...');
% for i=1:length(trials)
%     waitbar(i/length(trials),h)
%     datafilename=sprintf('%s%d.mat', database , trials(i));
%     fprintf('Importing %s\n', datafilename)
%     Data(i)=load(datafilename);
%     %channelflag=channelflags & Data(i).ChannelFlag;
%     channelflag=channelflags;
%     Data(i).F=Data(i).F(find(channelflag),:);
% end
%close(h)

return
