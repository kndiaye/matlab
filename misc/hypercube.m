function hypercube(d,p)
% Draws hypercube projections

% Ref:
% http://www4.ncsu.edu/unity/lockers/users/f/felder/public/kenny/papers/4dplots.html


d = 4
p = 3
if p<1|d<1
    error
end
if p>3
    error 'cannot plot beyond 3d'
end

%vertices
nv = 2^d
v = zeros(nv,d);
for i=1:nv
    v(i,:)=bitget(i-1,1:d);
end
colv = rand(nv,3);
%edges
e=[];
for i=1:nv
    for j=i+1:nv
        if  sum(abs(diff([v(i,:);v(j,:)])))==1
            e=[e; i j];
        end
    end
end
ne=size(e,1);
close all
hf = figure;
ha(1) = subplot(2,4,[3]);
ha(2) = subplot(2,4,[4]);
ha(3) = subplot(2,4,[7]);
ha(4) = subplot(2,4,[8]);
ha(5) = subplot(2,4,[1 2 5 6]);
set(ha,'XTick',[],'YTick',[],'Ztick', [], 'XLim',[-1 2], 'Ylim', [-1 2] , 'Zlim', [-1 2] )
D='XYZU';

xy(:,1:p) = nchoosek(1:d,p);
xy(:,p+1:3)=0;
for j=1:d
    axes(ha(j))
    xlabel(D(xy(j,1)))
    ylabel(D(xy(j,2)))
    view(2)
    if xy(j,3)>0
        zlabel(D(xy(j,3)));
        view(3)
    end
    axis square
    grid on
    box on

end


for j=1:d
    axes(ha(j))
    hold on
    for i=1:nv% randperm(nv)
        switch(p)
            case 1
            case 2
            hp(j,i)=plot(v(:,xy(j,1)),v(:,xy(j,2)),'.','MarkerSize',12, 'color', colv(i,:));
            case 3
                            hp(j,i)=plot3(v(:,xy(j,1)),v(:,xy(j,2)),v(:,xy(j,3)),'.','MarkerSize',12, 'color', colv(i,:));
        end
    end
    for i=1:ne
        switch(p)
            case 1
            case 2
                he(j,i)=line(v(e(i,:),xy(j,1)),v(e(i,:),xy(j,2)));

            case 3
                he(j,i)=line(v(e(i,:),xy(j,1)),v(e(i,:),xy(j,2)),v(e(i,:),xy(j,3)));
        end
    end
    hold off
end
set(ha, 'XTick',[], 'YTick',[], 'XLim',[-1 2], 'Ylim', [-1 2] )



function v=rotate(v,r,a)

