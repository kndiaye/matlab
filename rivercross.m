function [sol]=run
p=ones(1,8);
i=1;
teams=nchoosek(1:8,2);
pt=p;
j=0;
t=[];
fprintf('%d> %s\n',0,sprintf('%+d ',pt));
while any(pt>0) && j<10
    j=j+1;
    h(j,:)=pt;
    t=[t; teams(j,:)];
    [pt,ok]=boat(pt,t(end,:));
    if  ~ok
        t(end,:)=[];
    else
        if ~check(pt)
            t(end,:)=[];
        else
            fprintf('%d> ((%s)) : ', j,sprintf('%+d ',t(end,:)));
            fprintf('%s\n',sprintf('%+d ',pt));
        end
    end

end


function [p2,ok]=boat(p1,j)
p2=p1;
ok=0;
if ~ismember(j, [1 3 4])
    return
end
ok=1;
p2(j)=-p2(j);

function [ok]=check(p)
ok=0;
%police
if p(1).*p(2)<0
    return
end
if p(3)>0 && p(4)<0 && any(p(5:6))<0
    return
end
if p(3)<0 && p(4)>0 && any(p(5:6))>0
    return
end





