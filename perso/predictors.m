function []=p()
g(1,1:2)=0;
k=2;
for i=2:1000
    p1=ceil(rand*6);
    sum(k-3.5)/i
    [p2]=round(3.5-mean(k-3.5))
    k(i)=ceil(rand*6);
    k
    p2
    
    g(i,1)=g(i-1,1)+(p1(i)==k(i));
    g(i,2)=g(i-1,2)+(p2(i)==k(i));
    
end

    plot(cumsum(g))
    drawnow
