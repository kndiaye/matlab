function t = strcell(s)
%strcell() - Create cell array of strings from character array.
%   [T] = STRCELL(S) converts S into a cell array T where every cell
%   contains a character array: 
%       * char array are unmodified
%       * empty elements or empty arrays are converted to '' 
%       * numbers are converted with num2str
%       * non convertible elements (cell array, etc) are converted to ''
%
%   See also STRINGS, CHAR, ISCELLSTR, CELLSTR.

res = cellfun('isclass',s,'char');
if all(res(:)); t=s; return; end
t = cell(size(s));
t(res)=s(res);      
for i=find(~res(:)')
    try
        t{i}=num2str(s{i});
    catch
        t{i}='';
    end
end