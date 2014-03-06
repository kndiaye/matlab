function t=p2b(pmid)
if nargin<1
    pmid = 20070959;
end
if isnumeric(pmid)
    pmid = sprintf('%d',pmid);
end
pubmed = @(pmid) urlread('http://www.ncbi.nlm.nih.gov/sites/entrez', 'post', { 'cmd' 'search' 'db' 'pubmed' 'term' sprintf('%s[pmid]',pmid)  'doptcmdl' 'medline' 'dispmax' '200' 'tool' 'resource'})
t= pubmed(pmid);
t = strread(t, '%s', 'delimiter', '\n')
au=strrep(t(strmatch('AU', t)), 'AU  - ', '');
au = sprintf('%s%s.', sprintf('%s, ', au{1:end-1}), au{end})
ti= regexprep(t{strmatch('TI', t)}, '.*- ', '')
so = regexprep(t{strmatch('SO', t)}, '.*- ', '')

t=sprintf('%s %s. %s',au,ti,so)