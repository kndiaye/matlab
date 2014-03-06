function [A,B,C] = read_table(filename,varargin)
%READ_TABLE - Reads tabular data from a file
%   [NUMERIC,TXT,RAW] = read_table(filename)
%   [X] = read_table(filename,)
%
%   Example
%       >> read_table
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
% KND  2010-01-28 Creation
%
% ----------------------------- Script History ---------------------------------
%filename = '/data/classical_datasets/chambers_cars.dat';

hl=lower(varargin(1:2:end));
hl = strmatch('headerlines', hl);
if ~isempty(hl)
    a = textread(filename,'%s',hl+1,'delimiter','\n');
else
    a = textread(filename,'%s',1,'delimiter','\n');
end
cols =strread(a{end}, '%s');
nc = numel(cols);
fid=fopen(filename);
C = textscan(fid,repmat('%s',1,nc),varargin{:});
fclose(fid);
TxtCols = [];
A=[];
B={[]};
for i=1:nc
    X=str2double(C{i});
    A=[A X];
    if all(isnan(X))
        B(1:size(A,1),i) = C{i};
    else
        B(1:size(A,1),i)={[]};
    end
end

%A = textread(filename,A);

return


C=textread('%s')
file = textread('fft.m','%s','delimiter','\n','whitespace','')
;