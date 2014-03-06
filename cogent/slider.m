function [resp,rt]=slidermouse(trial,questions,map,buf)
resp=[];
rt=[];
if nargin<1
    trial='';
else
    trial=sprintf('%02d/%02d',trial);
end
if nargin<2 || isempty(questions)
    questions={'Intensité' 'Peur' 'Joie' 'Surprise' 'Dégout' 'Colère' 'Tristesse'};
end
if nargin<3
    map=[];
end
if nargin<4
    buf=1;
end

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

if length(dbstack)==1
    % Configure mouse in polling mode with 10ms interval
    config_mouse(10);  
    config_display(1,1,bgcolor,fgcolor,'Arial',20);
    start_cogent;
    if ~isempty(scale)
        cgScale(scale);
    end
    % Define variable map to contain current information about mouse
    map = getmousemap; 
end

if isempty(map)
    error('No mouse map')
    return
end

NQ=length(questions);

for i=1:NQ    
    mx=0;
    trial_start  = time; 
    while 1
        % Update mouse map using readmouse.
        readmouse;     
        
        mx=mx+sum(getmouse(map.X));
        x=(mx-rectx)/rectw+.5;
        x=max(x,0);
        x=min(x,1);        
        
        clearpict( buf );
        for j=1:NQ
            y=recty+(3-j)*vspace*recth;
            if j<i
                cgpencol(.5,.5,.5)
                cgrect(rectx,y,rectw,recth)
                cgpencol(0,0,0)
                cgrect(rectx,y,rectwi,recthi)
                cgpencol(.5,.5,.5)
                cgrect(rectx-rectwi/2*(1-resp(j)),y,resp(j)*rectwi,recthi)
                cgtext(questions{j},rectx,y+recth*1.5)
                
            elseif j==i                
                cgpencol(1,1,1)
                cgrect(rectx,y,rectw,recth)
                cgpencol(1,1,1)
                cgfont('Arial',fontSize)
                cgtext('  0%',rectx-rectw/2,y+recth*1.5)
                cgtext('100%',rectx+rectw/2,y+recth*1.5)
                cgtext([ questions{j} ' ?'],rectx,y+recth*1.5)
                cgpencol(0,0,0)
                cgrect(rectx,y,rectwi,recthi)
                cgpencol(1,1,1)
                cgrect(rectx-rectwi/2*(1-x),y,x*rectwi,recthi)
            else
                cgpencol(.5,.5,.5)
                cgrect(rectx,y,rectw,recth)
                cgtext(questions{j},rectx,y+recth*1.5)                
            end         
            
            cgpencol(.5,.5,.5)
            cgtext(trial,-300,-220)       
        end
        
        drawpict( buf );    
        
        % Exit if left mouse button is pressed
        if isequal(getmouse(map.Button1),128) %~isempty(getmouse(map.Button2)) & any(getmouse(map.Button2) == 128 ) 
            break;
        end
    end
    resp(i)=x;
    rt(i)= time - trial_start ; 
    
end
clearpict( buf );
clearmouse;
if length(dbstack)==1
    stop_cogent;   
end

return
