function fakebar(varargin)
% fakebar(value) displays progressing waitbars until you press cancel
%   value: how many loops are to be done until a waitbar is full. Try
%   values > 1000 (optional parameter)
%
%   Example:
%   fakebar(20000);
%
%   Creates a waitbar with changing random progress. Use it to show
%   your boss that you can't work at the moment because systemload
%   is 100% and the calculations will take some time -> coffee ;-)
%
%      Version 1.0 by Stefan Eireiner (<a href="mailto:stefan@algorithmus.info?subject=fakebar">stefan@algorithmus.info</a>)
%      last change 18.06.2004

if nargin > 0
    divisor = varargin{1};
else
    divisor = 1000;
end

while(true)
    fb = waitbar(0, 'Calculating Data...', 'CreateCancelBtn', 'delete(get(0,''CurrentFigure''))', 'Name', 'Analyzer 1.0');
	counter = 0;
    while(counter < divisor && ishandle(fb))
        il = round((rand^2)*divisor*0.5);
        adder = rand;
        for m=1:il
            counter = counter + adder^2;
            try
                waitbar(counter/divisor,fb);
            catch
                disp('Calculations done!');
                return;
            end
        end
    end
    if(ishandle(fb))
        delete(fb);
    else
        return;
    end
end