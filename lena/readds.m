if ~ exist('fic_ds')
  fic_ds=input('Fichier DS ?\n ''/pclxserver/home/ndiaye/DAV/rawdata/S7/aud-avTr22.ds'' ');
end

if ~ exist('F')
  [F,Channel,imegsens,ieegsens,iothersens,irefsens,grad_order_no,no_trials,filter,Time, RunTitle] = ds2brainstorm(fic_ds,0);
end

t=textread('ClassFile.cls','%s');
n=strmatch('BAD',t)
n=strmatch('NUMBER',t(n:end))+n-1

nbad=str2num(t{n(1)+3});
badtrials=[];
for i=1:nbad
  j=i+n(2);
badtrials=[badtrials str2num(t{j})];
end

MARQUEURS={'Tr22' 'Tr23' 'Tr24' 'Tr25' 'Tr26'}
for i=1:length(MARQUEURS)
  t=textread('MarkerFile.mrk','%s');
  mark(i).name=MARQUEURS{i}
  n=strmatch(MARQUEURS{i},t);    
  n=strmatch('SAMPLES',t(n:end))+n-1;
  mark(i).nb=str2num(t{n(1)+1})
  
  for j=1:mark(i).nb
    k=2*j+n(2)+7;
    mark(i).tr(j)=str2num(t{k});
  end
  
end
