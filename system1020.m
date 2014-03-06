divch2=setdiff(divch, [9 19])
xyz=getChannelLocs(eegch(divch2));
mass=median(xyz)
R0 = mean(norlig(xyz - ones(62,1)*mass)); % Average distance between the center of mass and the scalp points
[SphereParams,brp] = fminsearch('dist_sph',[median(xyz) R0],[],xyz)
