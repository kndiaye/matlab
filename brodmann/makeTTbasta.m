function [TTbasta]=makeTTbasta(ref,labels,xyz)
% Merge Brodmann regions into bigger ones


% Remove midline points
keep=find(xyz(:,1)~=0);
% Decimate
% keep=keep(1:10:end);
xyz=xyz(keep,:);
ref=ref(keep);


hbar=timebar('...', 'Merging BA clusters');
ba=strmatch('Brodmann', labels);
baref=double(ref);
baref=0.*baref;
for i=1:length(ba)
  timebar(hbar,i/length(ba));
  baref(find(ref==ba(i)))=str2num(labels{ba(i)}(15:end)); 
end
  
[a,labels2]=textread('mergeBA.txt','%s%s', 'delimiter',  '|');
ref2=0.*(baref);
for i=1:length(a)  
  timebar(hbar,i/length(a));
  ref2(find(ismember(baref, str2num(a{i}))))=i;
end
ref2=int16(ref2);
close(hbar)

% add limbic structures to hippocampal region
limbix={'Hippocampus', 'Amygdala'};
hipp=strmatch('hippocampal region', labels2);
for i=1:2
    ref2(find(ref==strmatch(limbix{i}, labels)))=hipp;
end
labels2{hipp}=[ labels2{hipp} ' + hippocampus + amygdala'];

% Separate Left/Right hemisphere 
nl=length(labels2);
ref3=zeros(size(ref2));
for i=1:nl
    l2{2*i-1}=['Left ' labels2{i}];
    l2{2*i}=['Right ' labels2{i}];    
    ref3(find(ref2==i & xyz(:,1)<0))=2*i-1;
    ref3(find(ref2==i & xyz(:,1)>0))=2*i;    
end

TTbasta.ref=int8(ref3);
TTbasta.xyz=int8(xyz);
TTbasta.labels=l2';

% Thalamic nuclei: 2    51    52    54    56    57    59    61    66    67    68    69
