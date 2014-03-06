function [ref2,labels2]=mergeBA(ref,labels)
% Merge Brodmann regions into bigger ones

hbar=timebar('...', 'Merging BA clusters');
ba=strmatch('Brodmann', labels);
baref=double(ref);
baref=0.*baref;
for i=1:length(ba)
  timebar(hbar,i/length(ba));
  baref(find(ref==ba(i)))=str2num(labels{ba(i)}(15:end)); 
end
  
[a,labels2]=textread('mergeBA.txt','%s%s', 'delimiter',  '|')
ref2=0.*(baref);
for i=1:length(a)  
  timebar(hbar,i/length(a));
  ref2(find(ismember(baref, str2num(a{i}))))=i;
end
ref2=int16(ref2);
close(hbar)

% add limbic structures to hippocampal region
limbix={'Hippocampus', 'Amygdala', 'Dentate'}
hipp=strmatch('hippocampal region', labels2);
for i=1:3
    ref2(find(ref==strmatch(limbix{i}, labels)))=hipp;
end




% Thalamic nuclei: 2    51    52    54    56    57    59    61    66    67    68    69
