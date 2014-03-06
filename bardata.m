function []=bardata(X,Y,varargin)
% bardata - display a bar graph of mean and std deviation
%   [m,s]=bardata(Y)
%   [m,s]=bardata(X,Y)
%   [m,s]=bardata(X,Y1,Y2)
if nargin==1
    Y=X;
    X=1;
end
Y={Y};
for i=1:nargin-2
  Y(end+1)=varargin(i);
end
if length(X) ~= length(Y)
    Y=[{X} Y];
    X=1:length(Y);
end
for i=1:length(Y)
    m(i)=mean(Y{i});
    s(i)=stderr(Y{i});
end
barerrorbar(X,m,s)