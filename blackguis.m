function [ output_args ] = blackguis( hf )
%blackguis - Make the (Figure and Axes) black
if nargin<1
    hf=gcf;
end
for ihf=1:length(hf)
    
    set(hf(ihf), 'color', 'k')
    ha=get(hf(ihf), 'children')
    set(ha, 'color', 'k')
    set(ha, 'Xcolor', 'w')
    set(ha, 'Ycolor', 'w')
    set(ha, 'Zcolor', 'w')
    
end