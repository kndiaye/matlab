function [X]=ndiags(A,d)
s=[size(A)];
if any(s~=s(1))
    error('Non square matrix')
end
n=1+prod(s(1:end-1))+sum(s(1:end-2))
X=A(1:n:end);
return

error('NDIAGS: Not implemented yet')
if length(d)~=2
    error('d has to be a 2 value vector')
end
if not(size(A,d(1))==size(A,d(2)))
    error('Diagonalized dimensions of A have to form a square, same ')
end;

if ndims(A)==4
   A=permute(A,[2 3 1 4]);
    for i=1:size(A,d(1))
        i
        a=squeeze(A(i, i, :,:));
        d(i,:,:)=a;
    end
    d=permute([2 1 3]); 
end


    