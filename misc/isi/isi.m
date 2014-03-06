titles=textread('jcr_recs.txt', '%s%*[^\n]', 'delimiter', ';');
address='http://jcr02.isiknowledge.com/JCR/JCR?RQ=IMPACT&rank=1&journal='
%ic=zeros(length(titles),5)*NaN;
for i=i:length(titles)
    titles{i}
    [s,b,u] = web([address strrep(titles{i},' ', '+')]);    
    txt=get(b, 'Htmltext');
    p=findstr('Impact Factor', txt);
    p=fliplr(p(4:end-2));
    for j=1:length(p)
        z=0;
        %z=findstr('Cites to recent articles', txt(p(j)+[1:3000]))        
        z=z+findstr('dataTable', txt(p(j)+z+[1:2000]));
        ic(i,j)=str2num(strrep(strrep(strrep(txt(p(j)+z(6)+[14:19]),'<', ''), '/', ''), 'b', ''));        
    end
    ic(i,:)
    
    
end



return



ANNU+REV+NEUROSCI