function [Channel]=xyz2channel(x)
Channel=[];
for i=1:size(x,1);
  Channel(i).Loc=x(i,:)';
end
