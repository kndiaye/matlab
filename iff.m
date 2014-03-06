function [x]=iff(test,vt,vf)
% iff -
%   [val] = iff(X,vtrue,vfalse) outputs vtrue (resp. vfalse) if X is true
%                               (resp. false)
%
%   vtrue/vfalse can be numeric, char or a cell of char
%   X can be a ND array
%
%   [val] = iff(X,@fun) returns those values in X that match the test
%   function @fun
%
%   [val] = iff(X,@fun,vf) returns val(i)=X(i) that match the test
%   function @fun, and val(i) = vf otherwise.
%
converted2cell=0;   
if isa(vt, 'function_handle')
    if ~exist('vf','var')
        x=test(vt(test));
        return
    else
        x=test;
        x(~vt(test))=vf;
        return
    end
end
if isempty(vt) | isempty(vf) | (ischar(vt) & length(vt)>1) | (ischar(vf) & length(vf)>1)
    x=repmat([{vt} ; {vf}], [1 size(test)]);
    converted2cell=1;
else
    x=repmat([vt ; vf], [1 size(test)]);
end
x=x([reshape(logical(test), [1 size(test)]) ; reshape(~logical(test), [1 size(test)]) ]);
x=reshape(x, size(test));
if converted2cell
    if length(x)==1
        x=x{1};
    else
        warning('IFF:ConversionToCell', 'array was converted to cell')
    end
end

return
