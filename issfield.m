function tf = issfield(s,f)
%ISSFIELD True if field.subfield is in structure array
%   F = SISFIELD(S,'field.subfield...') returns true if 'field.subfield' is the
%   name of a field and its subfield in the structure array S.
%
%   See also SSTRUCT, SSETFIELD, SFIELDNAMES.

if isa(s,'struct')  
  tf = any(strcmp(sfieldnames(s(1)),f));
else
  tf = logical(0);
end
