function A = fread2(file,precision,volume,selection,offset)
%FREAD2 - Optimize fread call for reading subsets of N-dimensional data
%   A = fread2(FILE,PRECISION,SIZE,SUBS) reads N-dimensional binary data
%   from specified file  
%   Inputs:
%       FILE: File name or FID (from FOPEN)
%       PRECISION: See help FREAD
%       SIZE: a N-element vector equals to the size of the data in the file
%       SUBS: a N-element cell array of the list of indices of the elemnts
%       to read in the file, may be non-continuous ranges.
%
%   Example
%   >> fread2('data.bin','float32',[100 3 12],{ [1:50 55 6] [-2] 'all' })
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
% KND  2010-05-12 Creation
%                   
% ----------------------------- Script History ---------------------------------

error('not yet')

switch(precision)
    case {'uint8','int8','uchar','schar','char'}
        f_bytes = 2;
    case {'uint16','int32','short','ushort'}
        f_bytes = 2;
    case {'float32','single', 'float','uint32','int32','int','uint','long'}
        f_bytes = 4;
    case {'float64','double','uint64','int64'}
        f_bytes = 8;
    otherwise
        precision = 'float32';
        % error('read_lena:UnknownPrecision','Unknown precision: %s -- Go through the Full monthy', precision);
        % return
end
if nargin<5
    offset = 0;
end

ndim = numel(selection);
%% Bounding box
% Compute the bounding box of the volume of data to read 
range = zeros(4,ndim);
f_selection = cell(1,ndim);
for i=1:ndim
    range(1:2,i)=[min(selection{i});max(selection{i})];
    f_selection{i} = selection{i}-range(1,i)+1;    
end
% Line 3 of 'range' is the length of the bounding box on each dimension
% equivalent to what would be f_volume in the convtion used here
range(3,:)= range(2,:)-range(1,:)+1; 
% Line 4 of 'range' is the number of elements outsidethe bounding box
range(4,:) = volume-range(3,:)
volume
%% Segments to read
cumvol = cumprod([1 volume])
% The first segment to read starts after skipping a whole block of data
f_offset = sum(cumvol(1:end-1).*(range(1,:)-1))
% To skip between each read
f_skip = sum(cumvol(1:end-1).*(range(4,:)))
% Extent of the segment to read
f_selection = [cumvol(1:end-2).*(range(3,1:end-1)-1)]
f_selection(1) = 1+f_selection(1); 
%f_size = (1+cumsum(f_selection(1:end)))./cumprod([1
%f_selection(1:end-1)+1])
f_precision = sum(f_selection);

f_size = [ f_selection(1) f_precision/f_selection(1)]


fid = fopen(file, 'rb');

fseek(fid,offset + f_offset,'bof');
A = fread(fid,f_size,[num2str(f_precision) '*' precision], f_skip*f_bytes); 
numel(A)
A = reshape(A,range(3,:));
fclose(fid);
