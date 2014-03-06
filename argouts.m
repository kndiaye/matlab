function [X] = argouts(f,N)
% argouts - retrieves N outputs from an evaluated expression f into a cell array
%   [X]=argouts(f,N)
%
% Useful if outputs of f depends on the number of argout, e.g. 
% E.g.,              [x{1},x{2}] = find(rand(2)>.5)  
% is not the same as:          x = {find(rand(2)>.5)}
% but (tada!) can be written:  x = argouts('find(rand(2)>.5)',2)

ev=sprintf('X{%d},', 1:N);
ev(end)=[];
ev=[ '[' ev '] = ' f ';'];
eval(ev);
