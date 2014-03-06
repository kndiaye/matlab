% re-fetch biblio data rom medline
t=textread('d:\ndiaye\labo\jabbib.bib', '%s', 'delimiter', '\n');

return
fid=fopen('d:\ndiaye\labo\jabbib.bib','rt')
t=textscan(fid, '%s');
fclose(fid)



return


t=urlread('http://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=Nature[ta]+brain[TIAB]+"Journal+Article"[PT]&retmax=500');

[a]=strread(t,'%s', 'delimiter','\n');
a=a(strmatch('<Id>', a));
a=strrep(a, '<Id>','');
a=strrep(a, '</Id>','');
%a=strvcat(a);
%a=strrep(vectvec(transpose(a))','<Id>', '');a=strrep(a,'</Id>', ',');

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
