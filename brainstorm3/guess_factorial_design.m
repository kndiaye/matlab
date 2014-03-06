function [output,fx] = guess_factorial_design(Conditions,OutputStyle)
% 
SamplesA=Conditions.SamplesA;

[E,I,K]=unique({SamplesA.Condition});

fx=[1 1;2 2];
switch lower(OutputStyle)
    case 'cell'
    %        output
    case 'textarea'
        output = cellstr(num2str(fx));        
        output = sprintf('%s\n',output{:});
        output(end)=[];
end