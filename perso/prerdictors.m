function []=p()
g(1:2,1)=0;
for i=2:1000
    p1=ceil(rand*6);
    [v,p2]=min(sum(k-3.5));
    k
    p2
    k(i)=ceil(rand*6);
    g(i,1)=g(i-1,1)+(p1(i)==k(i));
    g(i,2)=g(i-1,2)+(p2(i)==k(i));
    
    plot(cumsum([g1;g2]))