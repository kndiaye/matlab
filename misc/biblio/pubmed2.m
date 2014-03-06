f=textread('d:\ndiaye\labo\publis\these\update biblio.txt','%s', 'delimiter', '\n');
f=f(21:end)

for i=1:length(f)
    f{i}
    t=urlread(['http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=' strrep(f{i}, '] "', ']+"')]);

    [a]=strread(t,'%s', 'delimiter','\n');
    a=a(strmatch('<Id>', a));
    a=strrep(a, '<Id>','');
    a=strrep(a, '</Id>','');
    %a=strvcat(a);
    %a=strrep(vectvec(transpose(a))','<Id>', '');a=strrep(a,'</Id>', ',');
    au=[];
    if length(a)==1
    for j=1:length(a)        
        fprintf('%d/%d\n',j,length(a))
        q=a{j};
        rs{j}=urlread(['http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=text&rettype=medline&id=' q]);
        return
    end
    end
    
end

au=[];

for i=1:length(a)
    fprintf('%d/%d\n',i,length(a))
    %    q=a{i}(5:end-5);
    q=a{i};
    rs{i}=urlread(['http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=text&rettype=medline&id=' q]);
    r=strread(rs{i}, '%s', 'delimiter','\n\n');
    b=strrep(r(strmatch('AU  -',r)), 'AU  - ','');
    au=[au, {b(:)'} ];
    %r=urlread(['http://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&retmode=text&rettype=medline&id=' q])
    %     b=findstr(r,char([13 10 13]));
    %     b=r(b(2)+4:b(3)-2)
    %     au=[au ', ' b];
end
o=[au{:}]
[b,i,j]=unique(o)
[m,mm]=histk(j)
b(m(1:10))
mm(1:10)
