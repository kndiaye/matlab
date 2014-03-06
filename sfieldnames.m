function [f]=sfieldnames(s)
%SFIELDNAMES Get structure field names.
%     NAMES = SFIELDNAMES(S) returns a cell array of strings containing 
%     the structure field and subfields names (under the form:
%     'field.subfield') associated with the structure s 
%  
%     See also SISFIELD, SSETFIELD

f=fieldnames(s);
f=f(:);
i=0;
while i<length(f)    
    i=i+1;
    g=getfield(s(1),f{i});
    if isstruct(g)
        sf=sfieldnames(g(1));
        sf=cellstr([repmat([f{i} '.'], length(sf),1) strvcat(sf)]);
        f=[f(1:i);sf;f(i+1:end)];
        i=i+length(sf);
    end
end

