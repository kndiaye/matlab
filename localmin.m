function [values,ix] = localmin(x)
N = length(x);               % N: Number of elements in time series
x_prev = [x(1) x(1:(N-1))];  % x_prev: Previous element in time series
x_next = [x(2:N) x(N)];      % x_next: Next element in time series
f = ( (x<=x_prev) & (x<=x_next) );  % f:  True where x takes on a local
                                    %     minimum value


