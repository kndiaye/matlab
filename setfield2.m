function B = setfield2(A,F,V)
%SETFIELD2 - Set structure field contents (even for arrays)
%    S = SETFIELD(S,F,V) sets the contents of the specified
%    field(s) F to the value(s) V. Structure S, fields F and values V may
%    be array of the same size or expandable scalar. 
%  
%     S = SETFIELD(S,{i,j},'field',{k},V) is equivalent to the syntax
%         S(i,j).field(k) = V; 
%         
%
% ----------------------------- Script History ---------------------------------
% KND  2011-06-08 Creation
%                   
% ----------------------------- Script History ---------------------------------
