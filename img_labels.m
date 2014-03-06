function [h]=img_labels(xyz,ref,labels)
% img_labels - add labels on a MR slice 
% [h]=img_labels(xyz,ref,labels)

if nargin<3
    labels=cellstr(num2str([1:max(ref)]'));
end
h=[];
for i=unique(ref)'
    if i>0
        centroid=mean(xyz(find(i==ref),:),1);
        h=[h; ....
            text( centroid(1),centroid(2),centroid(3), labels{i}) ...
            plot3(centroid(1),centroid(2),centroid(3), 'x', 'MarkerSize', 10)];
        
    end
end
set(h(:,1), 'Interpreter', 'none')