function [f,index,a] = getfield2(s,varargin)
%GETFIELD2 Get structure field contents (even for array).
%   F = GETFIELD2(S,'field') returns the contents of the specified
%   field. It expands the native GETFIELD to structure arrays.
%   GETFIELD2(F,'field) is equivalent to the syntax F = S.field when S is a
%   1-by-1 structure. If S is NOT a 1-by-1 structure, the output is a cell
%   array with the same size as S.
%
%   F = GETFIELD2(S,{i,j},'field',{k}) is equivalent to the syntax
%        F = S(i,j).field(k).
%
%   F = GETFIELD2(S,N) retrieves the n-th field (to be used with caution!)
%       See: orderfields()
%
%   [F,I,A] = GETFIELD2(S,...) may output:
%       I: vector of indices of S elements which had the requested field
%       A: a struct array equal to the cell array [F{:}]
%
%   See: GETFIELD

% Check for sufficient inputs
if (isempty(varargin))
    error('MATLAB:GETFIELD2:DeprecatedFunction:InsufficientInputs','Not enough input arguments.')
end

index = varargin{1};
if iscell(s)
    warning('MATLAB:GETFIELD2:Cell arrays of struct may not be supported in the future');
    sz=size(s);
    s = [s{:}];
    [f,index]=getfield2(s,varargin{:});
    if numel(f) == prod(sz)
        f = reshape(f,sz);
    end
elseif (length(varargin)==1 && isstr(index))
    % The most common case
    if any(index=='.')
        [f1,f2]=strtok(index,'.');
        % strtok keeps delimiter at the beginning of f2
        % in case f1 is addressing something like : x.f(n)
        paren_f1 = regexp(f1, '\(.*\)');
        if isempty(paren_f1)
            if iscell(s)
                
            else
                s = [s.(deblank(f1))];
            end
        else
            s = [s.(deblank(f1(1:paren_f1-1)))];
            s = eval(['s' f1(paren_f1:end)]);
        end
        if nargout<3
            [f,index]=getfield2(s,f2(2:end));
        else
            [f,index,a]=getfield2(s,f2(2:end));
        end
        return
    else
        if numel(s)==1
            f = s.(deblank(index));
        else
            sf=size(s);
            f = {s.(deblank(index))};
            f=reshape(f, sf);
        end
        %warning('MATLAB:GETFIELD:DeprecatedFunction:SingleInput', ...
        %        sprintf(['GETFIELD is deprecated. Please use: \n' ...
        %        's.(fieldname) instead of getfield(s,fieldname)']));

    end


else
    f = s;
    %warnflag = false;
    for i = 1:length(varargin)
        index = varargin{i};
        if (isa(index, 'cell'))
            f = f(index{:});
        elseif isstr(index)
            if length(f)==1
                f = f.(deblank(index)); % deblank field name
            else
                sf=size(f);
                f = {f.(deblank(index))};
                f=reshape(f, sf);
            end
            %if (~warnflag)
            %warning('MATLAB:GETFIELD:DeprecatedFunction:MultiInput', ...
            %        sprintf(['GETFIELD is deprecated. Please use: \n' ...
            %        's(i,j).(fieldname)(k) instead of getfield(s,{i,j},fieldname,{k}) OR \n' ...
            %        's(i,j).(field1).(field2) instead of getfield(s,{i,j},field1,field2)']));
            %warnflag = true;
            %end
        elseif isnumeric(index)
            if numel(index)>1
                error('Only one field at a time!')
            end
            fn=fieldnames(s);
            index=[fn{index}];
            f = f.(deblank(index));
        else
            error('MATLAB:GETFIELD:DeprecatedFunction:InvalidType', 'Inputs must be either cell arrays or strings.');
        end
    end
end
if nargout<3
    return
end
a  = [f{:}];
if numel(a) == numel(f)
    a=reshape(a,size(f));
else
    warning('The requested field was absent in some elements of the struct array')
end
return

