%
% What is your error rate with a D prime of
% http://www.sportsci.org/resource/stats/effectmag.html
%
% NB:
% To take a familiar example of a physical sex difference, the effect size
% for U.S. male-female differences in height is very large at d = 1.93.)
% I found that it means approx. 1/6 men would be categorized as women in a
% cutoff, and 2.7% are below women's mean height)

clear d r m m2 D v er
D= [0:.1:2 2:1:5] % 1.93
for j=1:numel(D)
    r=zeros(1,100);
    for i=1:100
        x=randn(10000,1);
        y=randn(10000,1)+D(j);
        d(i,j)=cohen_d(x,y);
        % percentage below cutoff
        er(i,1)=mean([y<mean([x;y]);x>mean([x;y])]);
        er(i,2)=mean([y<mean([x]) ;x>mean([y])]);
        er(i,3)=mean(y<x);
        er(i,3)=mean(y<x);
        
    end
    m(j,:)=mean(er);
    
end
cla
h=plot(D,[m'],'o-k')
%h=plotyy(D(1:21),[m(1:21)' m2(1:21)'],D(22:end),[m(22:end)' m2(22:end)'],@loglog)
set(h(2:size(m,2)), 'LineStyle', '--')
set(gca, 'Xscale', 'log')
set(gca, 'Yscale', 'log')
%set(gca, 'YLim',[1e-3 .5])
ylabel({'ERROR RATE (b. of wrong categorizations = %below cutoff)'})
xlabel('EFFECT SIZE (d prime)')
L =[0.2  0.6 1.2 2.0 4.0];
h=[h;vline(L)];
legend(h(size(m,2)+1:end),{ ...
    'small (d''= .2)' ...
    'moderate (d''= .6)' ...
    'large (d''= 1.2)' ...
    'very large (d''= 2)' ...
    'nearly perfect (d''= 4)'});

C=[0.0 0.1 0.3 0.5 0.7 0.9 1]