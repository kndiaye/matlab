function [t] = cdf(a)

% Computes the cumulative distribution function of the histogram of image "a".
% How to use: 
% (1) Read the image into the workspace: Ex, a = imread('image.tif');
% (2) Define the variable to use for the cumm dist function: Ex, s = cdf(a);
%  NOTE: The output is normalized to the range [0,1]. 

% Get histogram of image

	h=imhist(a);			%This MATLAB function gives a 256X1 histogram if "a" is uint8.

	m=length(h);

%First normalize the histogram to make sure that its area is unity (i.e., that it is a valid pdf).

	sum=0;

	for k=1:m;
		sum=sum + h(k);
	end

	coeff=1/sum;

%Multiply each component of h by coeff

	h = h.*coeff;

%Now compute the pdf

	for k=1:m;
		sum=0;
			for j=1:k;
				sum=sum + h(j);
		end
	t(k)=sum;
	end

% Convert to a column vector

	t=t';

% End of function 





  