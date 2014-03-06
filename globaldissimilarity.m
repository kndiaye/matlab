function [gd]=globaldissimilarity(F1,F2);
%globalfieldpower() - compute global dissimilarity between two fields
% 
% [gd]=globaldissimilarity(F1,F2)
% F1 and F2 are two [N (N2=N1) channels]x[T samples] fields
% 
% Defined in Lehman & Skandries, 1980 as:
% gd=rms(F1/rms(F1) - F2/rms(F2));
% 
% Typical use: 
%  >> g=globaldissimilarityd(F(:,1:end-1), F(:,2:end))
% will give you maxima when the field abruptly change.
%
% See also: rootmeansquare()
%
% Ref: 
% Lehmann D (1987): Principles of spatial analysis. In: Gevins
% AS , R?mond A , editors. Methods of analysis of brain electrical
% and magnetic signals. EEG handbook. Vol. 1. Amsterdam: Elsevier.
% 
% Brandeis D, Lehmann D. Event-related potentials of the brain
% and cognitive processes: approaches and
% applications. Neuropsychologia 1986; 24: 151-168). 

gd=F1./repmat(std(F1,1,1),[ size(F1,1) 1 ])- ...
   F2./repmat(std(F2,1,1),[ size(F2,1) 1 ]);
gd=std(gd,1,1);


