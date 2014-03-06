function [tf]=isvector(X)
%isvector - Test whether X is a vector (i.e. unidimensional)
%NB Returns 1 for empty
tf=isequal(prod(size(X)), max(size(X)));
