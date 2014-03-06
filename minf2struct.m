function [x]=minf2struct(minf)
% minf2struct - reads .minf file (Brainvisa) and create a structure
% 
%  [s]=minf2struct(minf)
%
% Input:       
%       minf: filename to read (e.g. 'toto.tex.minf')
%
% Output:
%       s : matlab structure
x=[];
fid=fopen(minf, 'rt');
t=[];
% t=fgetl(fid); % skip 1st line
while not(feof(fid))
    t=fgetl(fid);
    t=strrep(t,'attributes = {', '');
    t=strrep(t,'}', '');
    t=rmspaces(t);
    [f,v]=strtok(t,':');
    while not(isempty(v))
        [f2,v2]=strtok(v,':');
        sp=findstr('''', f);
        f=f(sp(1)+1:sp(2)-1);
        sp=findstr('''', f2);
        if not(isempty(v2))
            v=v(2:(sp(end-1)-1));
        else
            v=v(2:end);
        end 
        x=setfield(x, f, eval([ v ';']));
        v=v2;
        if not(isempty(v2))
            f=f2(sp(end-1):end);
        else
            f=[];
        end 
    end
    
    
end
fclose(fid);


function [t]=rmspaces(t)
i=1;
if length(t)==0
    return
end
while t(1)==' '
    t(1)=[];
    if length(t)==0
        break
    end
end
if length(t)==0
    return
end
while t(end)==' '
    t(end)=[];
    if length(t)==0
        break
    end
end
