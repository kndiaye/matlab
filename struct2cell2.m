%STRUCT2CELL2 - Recursive conversion of structure array to cell array.
%   C = STRUCT2CELL2(S) converts the M-by-N structure S (with P fields)
%   into a P-by-M-by-N cell array C.
%
%   If S is N-D, C will have size [P SIZE(S)].
%
%   Example:
%     clear s, s.category = 'tree'; s.height = 37.4; s.name = 'birch';
%     c = struct2cell(s); f = fieldnames(s);
%
%   See also STRUCT2CELL, struct2list

