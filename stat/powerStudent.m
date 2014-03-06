function [powerStudent] = powerStudent(t,df,c,a)
%Power estimation of a performed Student's t test about mean(s).
%(Estimates the statistical power of a performed Student's t test about mean(s).
%It recalls you the statistical result of the test you should have arrived.)
%
%   Syntax: function [powerStudent] = powerStudent(t,df,c,a) 
%      
%     Inputs:
%          t - Student's t statistic. 
%         df - degrees of freedom.
%          c - specified direction testing (1 = one-tailed; 2 = two-tailed).
%          a - significance level (default = 0.05).
%     Outputs:
%          Specified direction test.
%          (Statistical result of the test you should have arrived).
%          Power.
%
%    Example: From the example 7.9 of Zar (1999, p.108), the estimation of power
%             of a one-sample t test for a two-tailed hypothesis (c = 2) with a 
%             significance level = 0.05 (t = 2.7662, df = 11, c = 2).
%                                       
%     Calling on Matlab the function: 
%             powerStudent(2.7662,11,2)
%
%       Answer is:
%
%    It is a two-tailed hypothesis test.
%    (The null hypothesis was statistically significative.)
%    Power is: 0.7086 
%

%  Created by A. Trujillo-Ortiz and R. Hernandez-Walls
%             Facultad de Ciencias Marinas
%             Universidad Autonoma de Baja California
%             Apdo. Postal 453
%             Ensenada, Baja California
%             Mexico.
%             atrujo@uabc.mx
%
%  January 2, 2003.
%
%  To cite this file, this would be an appropriate format:
%  Trujillo-Ortiz, A. and R. Hernandez-Walls. (2003). powerStudent: Power estimation of a performed
%    Student's t test about mean(s). A MATLAB file. [WWW document]. URL http://www.mathworks.com/
%    matlabcentral/fileexchange/loadFile.do?objectId=2907&objectType=file
%
%  References:
% 
%  Zar, J. H. (1999), Biostatistical Analysis. 4th. ed.   
%           New-Jersey:Upper Saddle River. p. 107-108,135-136,164.

if nargin < 4, 
    a = 0.05; 
end 

if nargin < 3, 
    error('Requires at least three input arguments.'); 
end 

t=abs(t);

if c==1;
   disp('It is a one-tailed hypothesis test.');
   a=a;
   P=1-tcdf(t,df);
   if P >= a;
      disp('(The null hypothesis was not statistically significative.)');
      tp=tinv(1-a,df) - t;  %Power estimation.
      Power=1-tcdf(tp,df);
      disp('  ');
      fprintf('Power is: %2.4f\n\n', Power)
   else
      disp('(The null hypothesis was statistically significative.)');
      tb=t - tinv(1-a,df);  %Power estimation.
      Power=tcdf(tb,df);
      disp('  ');
      fprintf('Power is: %2.4f\n\n', Power)
   end
else c==2;
   disp('It is a two-tailed hypothesis test.');
   a=a/2;
   P=1-tcdf(t,df);
   if P >= a;
      disp('(The null hypothesis was not statistically significative.)');
      tp1=tinv(1-a,df) - t;  %Power estimation.
      Power1=1-tcdf(tp1,df);
      tp2=t + tinv(1-a,df);
      Power2=1-tcdf(tp2,df);
      Power=Power1 + Power2;
      disp('  ');
      fprintf('Power is: %2.4f\n\n', Power)
   else      
      disp('(The null hypothesis was statistically significative.)');
      tb1=t - tinv(1-a,df);  %Power estimation.
      b1=1-tcdf(tb1,df);
      tb2=t + tinv(1-a,df);
      b2=1-tcdf(tb2,df);
      Power=1 - (b1 - b2);
      disp('  ');
      fprintf('Power is: %2.4f\n\n', Power)
   end
end
