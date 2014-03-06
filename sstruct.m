function [s]=sstruct(varargin)
%SSTRUCT - Special struct construction for dealing with fields & subfields 
%      [S]=SSTRUCT('field1',VALUES1,'field2.subfield1',VALUES2,...) creates
%      a structure array with the specified fields, subfields and values.
%
%   NB: Contrary to the native STRUCT, SSTRUCT doesn't create structure
%   arrays from arrayed values.
%
% See also: sfield, issfield, sfieldnames
s=[];
for i=1:2:length(varargin)
    if ~ischar(varargin{i})
        error('KND:SSTRUCT:InvalidFieldname', 'Field names should be of type CHAR.');
    end
    s=ssetfield(s, varargin{i}, varargin{i+1});
end
