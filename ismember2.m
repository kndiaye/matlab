function [tf, loc]=ismember2(a,s)
% ISMEMBER2 : ISMEMBER function compliant with older versions of Matlab
v=ver;
if str2num(v(1).Version)>= 6.5
    [tf, loc]=ismember(a,s);
else
    % In Matlab 6.1, ISMEMBER function does not allow multiple varargout
    [tf]=ismember(a, s);
    for i=find(tf)
        idx=max(find(a(i)==s));
        loc(i)=idx(1);
    end
end
