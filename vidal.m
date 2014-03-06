if ~ exist('fic_ds')
   fic_ds='/pclxserver/home/ndiaye/DAV/rawdata/S7/aud01.ds'
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


for i=mark(5).tr+1;,
  if ~ find(badtrials==i),
    keep=[keep i];
end
end
  'Essais à tester :' 
keep

selection=ieegsens;
clear G 
clear allG
clear pente
j=1;
allG(:,:,j)=F{1}(selection,:);
for i=keep(2:end)
     j=j+1;
% G=G + F{i}(selection,:);
allG(:,:,j)= F{i}(selection,:);

end
% G=G/length(keep);
G=mean(allG,3);
for i=1:size(G,1)
     pente(i,1)=linearfit(G(i,64:500), Time(64:500));
     pente(i,2)=linearfit(G(i,501:625), Time(501:625));
end

     [dpente,capteur]=sort(pente(:,1)-pente(:,2));
     
subplot(3,1,1)
bar(pente(capteur(2:end),1))
subplot(3,1,2)
bar(pente(capteur(2:end),2)) 
subplot(3,1,3)
bar(dpente(2:end))
subplot(3,1,3)
hold on
bar(std(std(allG(capteur(2:end),:,:),[],3),[],2),'r')
hold off     
capteur(1:10) 
