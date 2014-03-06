function [resp,rt]=discretslider(trial,questions,map,buf) 
resp=[]; % the answer
rt=[]; % the reactiontime between each key press
if nargin<1
    trial='';
else
    trial=sprintf('%02d/%02d',trial);
end
if nargin<2 || isempty(questions)
    questions={'Enchantement (heureux, emerveillé)' 'Triomphe (energique, heroïque)' 'Nostalgie (sentimental, rêveur)'...
        'Transcendence (inspiré, spirituel)' 'Sérénité (calme, apaisé)' 'Tendresse (affectueux, doux)'...
        'Joie (euphorique, dansant)' 'Tristesse (deprimé, solonnel)' 'Agitation (tendu, neurveux)'};
end
if nargin<3
    map=[];
end
if nargin<4
    buf=1;
end

scale=[];
rectxa=-190; % x-axis
rectya=100; % y-axis 1st square
rectxb=-60; % x-axis 2nd square
rectxc=60;  % x-axis 3rd square
rectxd=190; % x-axis 4th square

rectw=20; % width
recth=20; % hight 
rectb=1; % thickness of rectangle
rectwi=rectw-rectb*2; %inside part width
recthi=recth-rectb*2; %inside part hight
vspace=50;

fgcolor=[1 1 1];
bgcolor=[0 0 0];
fontSize=20; % textsize

if length(dbstack)==1
    config_display(1,1,bgcolor,fgcolor,'Arial',20);
    config_keyboard;
    start_cogent;
    if ~isempty(scale)
        cgScale(scale);
    end
    % the keyboardsetting
     keys = getkeymap;
end

NQ=length(questions);

for i=1:NQ    
    mx=0;
    trial_start = time; 
    keyout=[];
    while 1  
        clearpict( buf );
        for j=1:NQ
            y=(5-j)*vspace;
            if j<i
                cgpencol(.5,.5,.5)
                cgrect(rectxa,y,rectw,recth) % the outer rects
                cgrect(rectxb,y,rectw,recth)
                cgrect(rectxc,y,rectw,recth)
                cgrect(rectxd,y,rectw,recth)
                cgpencol(0,0,0) 
                cgrect(rectxa,y,rectwi,recthi) % the inner rects
                cgrect(rectxb,y,rectwi,recthi)
                cgrect(rectxc,y,rectwi,recthi)
                cgrect(rectxd,y,rectwi,recthi)
                cgpencol(.5,.5,.5) 
                if resp(j)==28 % corresponds to the '1' key
                    cgrect(rectxa,y,rectwi,recthi)
                end
                if resp(j)==29 % corresponds to the '2' key
                    cgrect(rectxb,y,rectwi,recthi)
                end
                if resp(j)==30 % corresponds to the '3' key
                    cgrect(rectxc,y,rectwi,recthi)
                end
                if resp(j)==31 % corresponds to the '4' key
                    cgrect(rectxd,y,rectwi,recthi)
                end
                cgtext(questions{j},rectxa,y+recth*1.2) % text
                
            elseif j==i           
                cgpencol(1,1,1) 
                cgrect(rectxa,y,rectw,recth)
                cgrect(rectxb,y,rectw,recth)
                cgrect(rectxc,y,rectw,recth)
                cgrect(rectxd,y,rectw,recth)
                cgpencol(1,1,1) 
                cgfont('Arial',fontSize)
                cgtext([ questions{j} ' ?'],rectxa,y+recth*1.2)
                cgtext('zéro',rectxa+35,y) % text with specific alignement
                cgtext('faible',rectxb+38,y) % text
                cgtext('fort',rectxc+29,y) % text
                cgtext('très fort',rectxd+50,y) % text
                cgpencol(0,0,0) 
                cgrect(rectxa,y,rectwi,recthi)
                cgrect(rectxb,y,rectwi,recthi)
                cgrect(rectxc,y,rectwi,recthi)
                cgrect(rectxd,y,rectwi,recthi)
%                 cgpencol(1,1,1) % the chosen rectangle gets white
%                 if keyout == 28
%                     cgrect(rectxa,y,rectw,recth) % outer rectangle
%                     cgrect(rectxa,y,rectwi,recthi) % inner rectangle
%                 end
%                 if keyout == 29
%                     cgrect(rectxa,y,rectw,recth) % outer rectangle
%                     cgrect(rectxa,y,rectwi,recthi) % inner rectangle
%                 end
%                 if keyout == 30
%            
%                     cgrect(rectxa,y,rectw,recth) % outer rectangle
%                     cgrect(rectxa,y,rectwi,recthi) % inner rectangle
%                 end
%                 if keyout == 31
%                     
%                     cgrect(rectxa,y,rectw,recth) % outer rectangle
%                     cgrect(rectxa,y,rectwi,recthi) % inner rectangle
%                 end

            else
                cgpencol(.5,.5,.5)
                cgrect(rectxa,y,rectw,recth)
                cgrect(rectxb,y,rectw,recth)
                cgrect(rectxc,y,rectw,recth)
                cgrect(rectxd,y,rectw,recth)
                cgtext(questions{j},rectxa,y+recth*1.2)                
            end                     
            cgpencol(.5,.5,.5)
            cgtext(trial,-300,-220)       
        end
        drawpict(buf);
        [ keyout, tm, n ] = waitkeydown( Inf );
        drawpict(buf);
        break;
    end % while
    keyout=keyout(1);
    resp(i)=keyout;
    rt(i)= time - trial_start ;
    
end % for (big loop)
drawpict(buf);

for k=1:NQ % to get the actual keys '1 2 3 4' as answer
    if resp(k)==28
        resp(k)=1;
    end
     if resp(k)==29
        resp(k)=2;
     end
     if resp(k)==30
        resp(k)=3;
     end
     if resp(k)==31
        resp(k)=4;
    end
end
%clearmouse;
if length(dbstack)==1
    stop_cogent;   
end

return
