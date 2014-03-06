function [x]=forcecell(x)
% forcecell - make sure x is cell
% 
% Some functions inconsistently return cell or numeric array (even native
% ones as get: get(h, 'Xdata') returns cells when h is an array of handles,
% but the same would returns a double array when h is a single handle...
if ~iscell(x)
    x={x};
end

