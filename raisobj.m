function []=raisobj(ho)
%raisebj - Raise a graphical object at the top of its peers in an axe.
if nargin==0
    ho=gco;
end
ha=get(ho, 'Parent');
hp=get(ha, 'Children');
set(ha, 'Children', [setdiff(hp,ho); ho])
