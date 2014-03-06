function [ y ] = threshold( x , thd , mode , replace )
% threshold - thresholds an array and replace values under threshold
% [ y ] = threshold( x , thd , mode , replace )
%      x: array
%    thd: value of threshold
%   mode: 'value' | '%max' | '%nb' 
%         threshold on value (keeps x>thd)
%                   relative to the max (x > thd*x_max)
%                   percentage of number thd% most intense
if nargin < 3
    mode='value';
end
if nargin < 4
    replace=0;
end
y=x;
switch mode
    case 'value'
        y(x<=thd