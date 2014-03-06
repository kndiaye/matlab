function [] = questionnaire(textfile,subject)
if nargin<1 
    %error('No questionnaire text file provided!')
    textfile='revised-self-consciousness-fr.txt';
end
if nargin<2
    subject=0;
end
fullscreen = double(nargin>0);
fullscreen = 1;
fullscreen = 0;

clc;    
t=textread(textfile,'%s', 'delimiter', '\n','whitespace','');
scale=[];
rectx=0;
recty=0;
rectw=400;
recth=rectw/40;
rectb=1;
rectwi=rectw-rectb*2; %inside part
recthi=recth-rectb*2; %inside part
vspace=5;

fgcolor=[1 1 1];
bgcolor=[0 0 0];
fontSize=rectw/20;
linewidth=40;
textheight=20;

if length(dbstack)==1
    config_display(fullscreen,1,bgcolor,fgcolor,'Arial',20,25);
    if fullscreen==0
        config_keyboard( 100, 5, 'nonexclusive')
    else
        config_keyboard;        
    end
    config_log; 
    config_results; 
    start_cogent;   
    cogprocess( 'getpriority' )
    cogstd('spriority','NORMAL')
    cogprocess( 'getpriority' )
    keymap=getkeymap;
end
logstring( textfile);
addresults(textfile)
addresults(datestr(now,0))
addresults('Subject', subject)
clearpict( 0 ); 

%% Instructions

clearpict( 1 );                      % Clear display buffer 1
s=find(cellfun('isempty',t));
i=1;
j=2;
while not(isempty(t{i}) & isempty(t{i+1}) )
    nlines=s(min(find(s>i)))-i;    
    for j=1:nlines
        preparestring(t{i+j-1},1,0,(nlines/2-j)*textheight);        
        drawpict(1);
    end 
    waitkeydown(5000+nlines*2000);
    clearpict( 1 );                      % Clear display buffer 1  
    i=i+nlines;
end

%% Response options

i=i+2;
j=0;
while not(isempty(t{i}))
    j =j+1;
    if isempty(t{i+1})
        respoption(j).txt = t{i}; 
        respoption(j).key = getfield(keymap, sprintf('K%d',j));
    else 
        respoption(j).txt = [t{i+1} ' -> ' t{i}];
        if ismember( t{i+1} , '1234567890')
            respoption(j).key =  getfield(keymap,['K' t{i+1}]);
        else
            respoption(j).key =  getfield(keymap,t{i+1});
        end         
    end
    preparestring(respoption(j).txt,2,0,-50-textheight*j);
    respoption(j).buf=2+j;
    preparestring(respoption(j).txt,respoption(j).buf,0,-50-textheight*j);
    respoption(j)
    i=i+2;    
end
preparestring('En cas d''erreur, appuyer sur la flèche gauche pour revenir en arrière',2,0,-50-textheight*(j+2));


%% Questions


iq=1;
iline(iq)=i+1+iq;
if iline > length(t)
    stop_cogent;
    error;
    return
elseif isempty(t{iline})
    stop_cogent;
    return    
end
clearpict( 0 );
drawpict(0);  


while (iline(iq))<=length(t)
    nlines=1;
    ok=(iline(iq)+nlines)<=length(t);
    if ok, ok=ok & ~isempty(t{iline(iq)+nlines}); end
    while ok
        nlines=nlines+1;
        ok=iline(iq)+nlines<=length(t);
        if ok, ok=ok & ~isempty(t{iline(iq)+nlines}); end
    end    
    cgsetsprite(0);
    cgdrawsprite(2,0,0);    
    for j=1:nlines
        preparestring(t{iline(iq)+j-1},0,0,(nlines-j)*textheight);
    end
    t0=drawpict(0);
    wait(300);
    clearkeys;    
    [k,rt] = waitkeydown(inf,[keymap.Delete keymap.Left keymap.Escape respoption.key] );%getkeydown;
    rt=rt-t0+300;
    if isempty(k)
    elseif k(1)==keymap.Delete | k(1)==keymap.Left
        iq=iq-1;
        if iq<1, iq=1; end
        clearpict( 0 );
        drawpict(0);  
        wait(100)
    elseif k(1)==keymap.Escape
        iline(iq)=inf;
    else
        r = find(k(1)==[respoption.key]);        
        r = r(1);
        clearpict( 0 );
        cgsetsprite(0);
        cgdrawsprite(respoption(r).buf,0,0);
        for j=1:nlines
            preparestring(t{iline(iq)+j-1},0,0,(nlines-j)*textheight);
        end
        drawpict(0);    
        wait(500)
        addresults(iq, r, rt)
        iq=iq+1;
        iline(iq)=iline(iq-1)+nlines+1;            
    end
    
end

wait(100);
clearkeys;
stop_cogent;

return

loadpict( face, 1 );                 % Copy face into buffer
clearkeys;                           % Clear all keyboard events
drawpict( 1 );                       % Copy display buffer 1 to screen
wait( 1000 );                        % Wait for 1000ms
drawpict( 2 );                       % Clear screen 
wait( 1000 );                        % Wait for 1000ms
readkeys;     