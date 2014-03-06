function [x]=x2cell(x)
% x2cell - make sure x is cell. DEPRECATED by: forcecell()
warning('MATLAB:x2cell is DEPRECATED')
x=forcecell(x);
