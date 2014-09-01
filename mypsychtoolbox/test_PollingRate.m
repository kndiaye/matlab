%% Keyboard
KbName('UnifyKeyNames');
ListenChar(2);
keys = 'sdfghjklm';
n_keys = numel(keys);
n_stop = 100;
k_keys=[];
for i=1:n_keys
    k_keys(i)=KbName(keys(i));
end
i_key=1;
secs=NaN*zeros(1,n_keys);
keyCode=cell(1,n_keys);

while true
    [keyIsDown, secs(i_key), keyCode{i_key}, deltaSecs] = KbCheck;
    if (i_key==1 && keyCode{1}(KbName(keys(1)))) || ...
            (i_key>1 && ~isequal(keyCode{i_key}(k_keys),keyCode{i_key-1}(k_keys)))
        i_key=i_key+1;
        
    end
    if i_key>n_stop
        break
    end
end
ListenChar(0);
%% analyse
secs=secs-secs(1);
[ cellfun(@KbName,cellfun(@(x)find(x,1,'last'), keyCode,'UniformOutput',0),'UniformOutput', 0)' ...
    num2cell([0;diff(secs)'])]
