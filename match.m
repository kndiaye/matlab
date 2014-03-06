function [I]=match(A,B,varargin)
% match() - find indices of matching items from an array
if iscell(A) && iscell(B)
    if all(vertvec(cellfun(@ischar,A))) && ...
            all(vertvec(cellfun(@ischar,B)))        
        I=cellfun2(@strmatch,A,B,'exact');
        v=cellfun(@isempty,I);
        if any(v(:))
            warning('match:Nonmatchs','Some values from A are not in B, these indices were set to 0');
            I(v)={0};
        end
        I=cell2mat(I);
    end
end
