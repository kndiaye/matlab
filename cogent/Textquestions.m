function [tx]=Textquestions(questions3,examples,keys)
if nargin ==0
    warning('no subject name - will use default name')
    sname = 'test';
    listnum=1;
end
if nargin<1 || isempty(questions3)
    questions3={'Est-ce que cette musique vous evoque des sensations corporelles ?' ...
        'Est-ce que cette musique vous evoque des images ?'};
    examples={'(par exemple des frissons ou besoin d''un mouvement)' '(par exemple des couleurs ou paysages)'};
end
if nargin<2
    keys=[];
end

tx=[];

if length(dbstack)==1
    
    global cogent
    config_keyboard;
    config_display(1, 2, [0 0 0], [1 1 1], 'Arial', 25, 4 )
    % config_log(['C:\Documents and Settings\SCHWARTZ\My Documents\MATLAB\Wiebke\myresults\' sname '.log']);
    % config_results(['C:\Documents and Settings\SCHWARTZ\My Documents\MATLAB\Wiebke\myresults\' sname '.res']);
    % datafilename= ['C:\Documents and Settings\SCHWARTZ\My Documents\MATLAB\Wiebke\mylists\datafile_' num2str(listnum) '.dat'];
    % config_data(datafilename);
    % config_sound;

    start_cogent

    fontName = 'Helvetica'; fontSize = 20; % font parameters (optional)
    cgalign('c','c');
    keys=[];
    keys=getkeymap;

end

% thechar=char(fieldnames(themap));
% thechar= {'A','B','C','D','E','F','G','H','I','J',...
%           'K','L','M','N','O','P','Q','R','S','T',...
%           'U','V','W','X','Y','Z','K0','K1','K2','K3',...
%           'K4','K5','K6','K7','K8','K9','F1','F2','F3','F4',...
%           'F5','F6','F7','F8','F9','F10','F11','F12','F13','F14',...
%           'F15','Escape','Minus','Equals','BackSpace','Tab','LBracket','RBracket','Return','LControl',...
%           'SemiColon','Apostrophe','Grave','LShift','BackSlash','Comma','Period','Slash','RShift','LAlt',...
%           'Space','CapsLock','NumLock','Scroll','Pad0','Pad1','Pad2','Pad3','Pad4','Pad5',...
%           'Pad6','Pad7','Pad8','Pad9','PadSubtrack','PadAdd','PadDivide','PadMultiply','PadPeriod','PadEnter',...
%           'RControl','RAlt','Pause','Home','Up','PageUp','Left','Right','End','Down',...
%           'PageDown','Insert','Delete'}
thechar= {'A','B','C','D','E','F','G','H','I','J',...
    'K','L','M','N','O','P','Q','R','S','T',...
    'U','V','W','X','Z','Y','0','1','2','3',...
    '4','5','6','7','8','9','F1','F2','F3','F4',...
    'F5','F6','F7','F8','F9','F10','F11','F12','F13','F14',...
    'F15','Escape','-','=','BackSpace','Space','è','','Return','LControl',...
    'é','à','Grave','LShift','$',',','.','-','RShift','LAlt',...
    'Space','CapsLock','NumLock','Scroll','Pad0','1','2','3','4','5',...
    '6','7','8','9','-','+','/','*','.','Return',...
    'RControl','RAlt','Pause','Home','Up','PageUp','Left','Right','End','Down',...
    'PageDown','Insert','Delete'};
thechar=char( thechar');
thenum=cell2mat(struct2cell(keys));
clearkeys
NQ=length(questions3); 

for k = 1:NQ
    theword={''};
    cgflip(0,0,0)
    cgflip(0,0,0)
    cgtext(questions3{k},0,200)
    cgtext(examples{k},0,150)
    cgflip
    wait(2000);
    cgflip(0,0,0)
    cgflip(0,0,0)

    while 1
        theline=length(theword);
        if length(theword{theline})>50
            lastblank= findstr(theword{theline},' ');
            lastblank= lastblank(end);
            theword{theline+1}=theword{theline}(lastblank+1:end);
            theword{theline} = theword{theline}(1:lastblank) ;
            theline=length(theword);
        end
        
        [ keyout, time, n ] = waitkeydown( Inf );
        keyout= keyout(1);
        if keys.Return == keyout
            break
        else
            cgflip(0,0,0)
            cgflip(0,0,0)
            theletter = deblank(thechar(find(thenum==keyout),:));
            if strcmp(theletter,'Space')
                theword{theline}=[theword{theline} ' '];
            elseif strcmp(theletter,'BackSpace')
                if length(theword{theline})>0
                    theword{theline}=[theword{theline}(1:end-1)];
                end
            else
                theword{theline}=[theword{theline} deblank(thechar(find(thenum==keyout),:))];
            end
            posx= 0;
            posy= 50;
            theresp = '';
            for i=1:theline
                theresp = [theresp theword{i}];
                cgtext(questions3{k},0,200)
                cgtext(examples{k},0,150)
                cgtext(theword{i},posx,posy)
                posy=posy-50;
            end
            
            cgflip
        end
         
        tx{k}=theresp;
       
    end
    if length(theword{1})==1
        tx{k}=['NO'];
    end
    cgflip(0,0,0)
    cgflip(0,0,0)
    wait(1000)
end

if length(dbstack)==1
    stop_cogent;   
end

tx

return