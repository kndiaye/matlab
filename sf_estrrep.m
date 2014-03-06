function str = sf_estrrep(str,srstr)
%sf_estrrep - Replaces multiples strings
%       str = sf_estrrep(str,srstr) replaces srstr multiple times in str.
%           srstr is a n-by-2 cell array of strings       
%   
% (from SPM2 toolbox)
for i = 1:size(srstr,1)
	str = strrep(str,srstr{i,1},srstr{i,2});
end