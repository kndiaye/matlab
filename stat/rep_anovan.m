function [p,t,stats,terms] = rep_anovan(tit,y,group,model,sstype,gnames)
% claculates repeated measureas anova and returns both the N- factor anova
% and n-factor repeated measures anova
% subjects should be highest level i.e. first variable in group
[RP,RT,RSTATS,RTERMS]=ANOVAN(y,group,model,sstype,gnames);
[r,c]=size(group);
Rep_T=RT;

prevjk=0;
for k=1:c
    jk=factorial(c) ./(factorial(c-k)*factorial(k));  % nCr r begins from 1
    for i=1:jk
        ij=i+prevjk+1;
        Rep_T{ij,6}=[]; Rep_T{ij,7}=[];
    end
    prevjk=prevjk+jk;
end


prevjk=0;
for k=1:c-1
    jk=factorial(c) ./(factorial(c-k)*factorial(k));  % nCr r begins from 1
    rs=factorial(c-1) ./(factorial(c-1-(k-1))*factorial(k-1)); % (n-1)C(r-1)
    st=factorial(c-1) ./(factorial(c-1-(k))*factorial(k)); % (n-1)C(r)
    for i=1+rs:jk
        ij=i+prevjk+1;
        Rep_T{ij,6}=RT{ij,5}/RT{ij+st,5}; % col 6 is F, col 5 is Mean Sq
        Rep_T{ij,7}=1-fcdf(Rep_T{ij,6},RT{ij,3},RT{ij+st,3}); % col 7 is p val, col 3 is df
    end
    prevjk=prevjk+jk;
end


fprintf('Source\tSum Sq\tdf\tMean Sq\tF val\tp\n');
prevjk=0;
for k=1:c
    jk=factorial(c) ./(factorial(c-k)*factorial(k));  % nCr r begins from 1
    for i=1:jk
        ij=i+prevjk+1;
        fprintf('%s\t%f\t%d\t%f\t%f\t%f\n',Rep_T{ij,1},Rep_T{ij,2},Rep_T{ij,3}, ...
        Rep_T{ij,5},Rep_T{ij,6},Rep_T{ij,7});
    end
    prevjk=prevjk+jk;
end

switch(sstype)
    case 1,    cap = 'Sequential (Type I) sums of squares.';
    case 2,    cap = 'Hierarchical (Type II) sums of squares.';
    otherwise, cap = 'Constrained (Type III) sums of squares.';
end
digits = [-1 -1 -1 -1 -1 2 4];
statdisptable(Rep_T, 'N-Way ANOVA', [tit,'rep-ANOVA'], cap, digits);