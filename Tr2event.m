function [event]=Tr2event(Tr)

disp('Calculating events...')
for i=1:Tr(1).nb
    event(i).ref=Tr(1).a(i);
    event(i).tstim=Tr(2).t(i);
    event(i).tresp=0;
    event(i).choice=0;
    event(i).bad=1; %Eventually BAD, if not answered
end

% Scanning responses
for i=1:Tr(10).nb
    j=1+Tr(10).a(i);
    event(j).tresp=Tr(10).t(i);
    event(j).bad=0; % Not a bad one
end


% Which stim type was shown ?
for k=5:9
for i=1:Tr(k).nb
j=1+Tr(k).a(i);
event(j).type=k;
event(j).length=k*.105-0.035;
end
end

% Which answer was given ?
for k=3:4
for i=1:Tr(k).nb
event(1+Tr(k).a(i)).choice=7-2*k; % No response = 0 ; ok = +1 ; no = -1
end
end

