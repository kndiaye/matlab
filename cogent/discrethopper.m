function [resp,rt]=discrethopper(trial,questions,map,buf) 
resp=[]; % the answer
rt=[]; % the reactiontime between each key press
if nargin<1
    trial='';
else
    trial=sprintf('%02d/%02d',trial); % output of the current number of trial in realation to the total number of trials
end
if nargin<2 || isempty(questions) % in the case of testing the script alone without arguments
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

Reckx = [-180 -140 -100 -60 -20 20 60 100 140 180];
nbr = length(Reckx); % number of rects

rectw=20; % width
recth=20; % hight 
rectb=1; % thickness of rectangle
rectwi=rectw-rectb*2; %inside part width
recthi=recth-rectb*2; %inside part hight
vspace=51; % space between the lines

fgcolor=[1 1 1];
bgcolor=[0 0 0];
fontSize=16; % textsize

if length(dbstack)==1 % in case of calling the script without input variables
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
keyadjust=0;
polpos=5; % the default start position (5=in the middle)


for i=1:NQ  % loop for the questions  
    
    trial_start = time; % the onset time of the trial
    hopper=polpos;
    
    while 1  
        readkeys;
        clearpict( buf );
        keyadjust;
   
        if keyadjust==29
            hopper = hopper + 1;
            if hopper > 10
                hopper = hopper - 1;
            end
        end
        if keyadjust==28
            hopper = hopper - 1;
             if hopper < 1
                hopper = hopper + 1;
            end
        end
        
        for j=1:NQ
            y=(5-j)*vspace;
            if j<i
                cgpencol(.5,.5,.5) % gray
                for r=1:nbr
                    cgrect(Reckx(r),y,rectw,recth) % the outer rects
                end
                
                cgpencol(0,0,0) % black
                for rr=1:nbr
                cgrect(Reckx(rr),y,rectwi,recthi) % the inner rects
                end
                
                cgpencol(.5,.5,.5) % in grey the already chosen ones
                answ=resp(j);
                cgrect(Reckx(answ),y,rectwi,recthi)
                cgtext(questions{j},Reckx(1),y+recth*1.2) % text
                
            elseif j==i           
                cgpencol(1,1,1) % white
                for rrr=1:nbr
                cgrect(Reckx(rrr),y,rectw,recth)
                end

                cgpencol(1,1,1) % white
                cgfont('Arial',fontSize)
                cgtext([ questions{j} ' ?'],Reckx(1),y+recth*1.1)
                cgtext('0',Reckx(1),y-17) % text with specific alignement
                cgtext('10',Reckx(10),y-17) % text
                cgpencol(0,0,0) % black
                for rrrr=1:nbr
                cgrect(Reckx(rrrr),y,rectwi,recthi)
                end
                cgpencol(1,1,1) % the default rectangle in the middle is white
                cgrect(Reckx(hopper),y,rectw,recth) % outer rectangle
                cgrect(Reckx(hopper),y,rectwi,recthi) % inner rectangle

            else
                cgpencol(.5,.5,.5)
                for rrrrr=1:nbr
                cgrect(Reckx(rrrrr),y,rectw,recth)
                end
                cgtext(questions{j},Reckx(1),y+recth*1.2)                
            end                     
            cgpencol(.5,.5,.5)
            cgtext(trial,-400,-340)  % output of current number of trial... at certain position    
      
        end % for
         drawpict(buf);
         [ keyadjust, ti, nb ] = waitkeydown( Inf, [ 28 29 31 ] );
         if keyadjust == 31
             break; % go to next for iteration
         else
              continue; % continue executing the while loop
         end
        
    end % while
    
    resp(i) = hopper;
    rt(i) = time - trial_start ;
    
end % for (big loop)


if length(dbstack)==1 % in the case of calling the script without input variables
    stop_cogent;   
end

return
