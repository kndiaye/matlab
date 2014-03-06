function [s]=ssetfield(s,varargin);
%SSETFIELD - Special SETFIELD for "field.subfield" structures 
%   S = SSETFIELD(S,'f.sf',V) sets the contents of the specified
%   subfield "sf" of a given field "f" to the value V.  
%   This would be equivalent to the syntax: S.field.subfield = V.
%   But it creates field "f" when missing.
%   S must be a 1-by-1 structure.  The changed structure is returned.

% KND : 2005-07-06 : Adapted from SETFIELD.

% NOT YET :
%
%   S = SETFIELD(S,{i,j},'field.subfield.subsubfield',{k},{p},{q},V) 
%   is equivalent to the syntax:
%       S(i,j).field(k).subfield(p).subsubfield(q) = V; 
%   Field references are passed as strings.  
% 
%   See: SETFIELD

% Check for sufficient inputs
if (isempty(varargin) | length(varargin) < 2)
    error('KND:SSETFIELD:InsufficientInputs', 'Not enough input arguments.');
end

% The most common case
arglen = length(varargin);
strField = varargin{1};
if isempty(strField)
    error('KND:SSETFIELD:EmptyFieldname', 'Empty field name.');
end
if (arglen==2)
    if ~isempty(findstr('.', strField))
        [f,sf]=strtok(strField,'.');
        s1=ssetfield([], sf(2:end), varargin{end});        
        s=mergestructs(s,setfield([], f, s1));
    else
        s.(deblank(strField)) = varargin{end};
        %warning('MATLAB:SETFIELD:DeprecatedFunction:SingleInput', ...
        %        sprintf(['SETFIELD is deprecated. Please use: \n' ...         
        %        's.(fieldname) instead of setfield(s,fieldname)']));
    end
    return
end
error('KND:SSETFIELD:WrongNumberOfInputs', 'Only 3 inputs are allowed.');
return


% The following needs to bee adapted for recursion into fields &
% subfields.
        
subs = varargin(1:end-1);
for i = 1:arglen-1
    index = varargin{i};
    if (isa(index, 'cell'))
        types{i} = '()';
    elseif isstr(index)        
        types{i} = '.';
        subs{i} = deblank(index); % deblank field name
    else
        error('MATLAB:SETFIELD:DeprecatedFunction:InvalidType','Inputs must be either cell arrays or strings.');
    end
end

% Perform assignment
try
   s = builtin('subsasgn', s, struct('type',types,'subs',subs), varargin{end});
   %warning('MATLAB:SETFIELD:DeprecatedFunction:MultiInput', ...
   %        sprintf(['SETFIELD is deprecated. Please use: \n' ...         
   %        's(i,j).(fieldname)(k) instead of setfield(s,{i,j},fieldname,{k}) OR \n' ...
   %        's(i,j).(field1).(field2) instead of setfield(s,{i,j},field1,field2)']));
catch
   error('MATLAB:SETFIELD:DeprecatedFunction', lasterr)
end

