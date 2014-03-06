function [t]=lowerfields(s,force)
% lowerfields - lower case the fields of a struct
if nargin<2
    force=0;
end

fn=fieldnames(s);
t=[];
for i=1:length(fn)
    if force 
        t=setfield(t, lower(fn{i}), getfield(s, fn{i}));
    else
        if length(strmatch(lower(fn{i}), lower(fn)))>1 & ~isequal(lower(fn{i}), fn{i})
            if nargin<2
                warning(sprintf('Field %s is not lower-cased (use option force=1 to override)', fn{i}))
            end
            t=setfield(t, fn{i}, getfield(s, fn{i}));
        else
            t=setfield(t, lower(fn{i}), getfield(s, fn{i}));
        end
    end 
end
    
