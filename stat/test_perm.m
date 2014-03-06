x=randn(30,2); y=randn(size(x))+[.5+rand(size(x,1),1) zeros(size(x,1),1)];
for i=1:100
    z(1,1:4,i)=[permttest(x,y,-1,0,100,0)' permttest(x,y,-1,2,100,0)];
end
for i=1:100
    z(2,1:4,i)=[permttest(x,y,-1,0,1000,0)' permttest(x,y,-1,2,1000,0)];
end
