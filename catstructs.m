function [z]=catstructs(dim,x,y,keepfields)
% catstructs - Concatenate structures independently of field order/presence
%
%   [Z]=catstructs(dim, X,Y) will concatenate structures X and Y into Z along
%   dimension dim which MUST be 1 (ie. vertical concatenation) 
%
%   [Z]=catstructs(dim,X,Y,keepfields)
%       keepfields: 1/0(default), keep non-matching fields. Missing values
%       will be set to []
if ~isequal(dim,1)
    error('Concatenated dimension MUST be 1 (until further development!)')
end    
if ~isvector(x) | ~isvector(y)
    error('Structures MSUT be unidimensional')
end
if nargin<4
    keepfields=0;
end 

z=x(:);
y=y(:);

fy=fieldnames(y);
if ~keepfields
    f=fieldnames(z);
    z=rmfield(z,f(~ismember(f,fy)));
    y=rmfield(y,fy(~ismember(fy,f)));
    fy=fy(ismember(fy,f));
end
% if isempty(z)
%     z=y;
% end
for j=1:length(y)
    for i=1:length(fy)
        if i==1
            z(end+1).(fy{i})= y(j).(fy{i});
        else
            z(end).(fy{i})= y(j).(fy{i});
        end
    end
end
    


return

% the following bugs when any argument is a struct array



function A = catstruct(varargin)
% CATSTRUCT - concatenate structures
%
%   X = CATSTRUCT(S1,S2,S3,...) concates the structures S1, S2, ... into one
%   structure X.
%
%   A.name = 'Me' ; 
%   B.income = 99999 ; 
%   X = CATSTRUCT(A,B) ->
%     X.name = 'Me' ;
%     X.income = 99999 ;
%
%   CATSTRUCT(S1,S2,'sorted') will sort the fieldnames alphabetically.
%
%   If a fieldname occurs more than once in the argument list, only the last
%   occurence is used, and the fields are alphabetically sorted.
%
%   To sort the fieldnames of a structure A use:
%   A = CATSTRUCT(A,'sorted') ;
%
%   See also CAT, STRUCT, FIELDNAMES, STRUCT2CELL

% 2005 Jos van der Geest

N = nargin ;

error(nargchk(1,Inf,N)) ;

if ~isstruct(varargin{end}),
    if isequal(varargin{end},'sorted'),
        sorted = 1 ;
        N = N-1 ;
        if N < 1,
            A = [] ;
            return
        end
    else
        error('Last argument should be a structure, or the string "sorted".') ;
    end
else
    sorted = 0 ;
end

for ii=1:N,
    X = varargin{ii} ;
    if ~isstruct(X),
        error(['Argument #' num2str(ii) ' is not a structure.']) ;
    end
    FN{ii} = fieldnames(X) ;
    VAL{ii} = struct2cell(X) ;
end

FN = cat(1,FN{:}) 
VAL = cat(1,VAL{:}) ;
[UFN,ind] = unique(FN) ;

if length(UFN) ~= length(FN),
    warning('Duplicate fieldnames found. Last value is used.') ;
    sorted = 1 ;
end

if sorted,
    VAL = VAL(ind) ;
    FN = FN(ind) 
end

VF = reshape([FN VAL].',1,[]) ;
A = struct(VF{:}) ;
