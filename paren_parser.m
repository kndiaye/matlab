function [paren_tree]=paren_parser(txt)
% Parsing an expression with parentheses
% [paren_tree]=paren_parser(txt)

paren_op={'(' ')'; '[' ']'};
opens=findstr(paren_op{1,1}, txt); %opening paren
closes=findstr(paren_op{1,2}, txt); %closing paren

error('not working yet!')

if not(isempty(opens))     
    pairs=[];
    open = 1;
    while open<size(idx_op,1);
        pairs=[pairs opens(open)]; 
        nbopen=1;
        close=1;
        while closes(close) > opens(nbopen)
            nbopen=nbopen+1;                        
        end
        open=open+1;
    end 
    pairs=[pairs idx_op{i,1}]
    nbpar=nbpar+1;        
end
return
end
paren_tree=struct('op', '', 'e', {txt});
