function [pcl2, vc]=merge_cluster(pcl, parcelle)
% merge parcels (pcl) computed from Anael's geod_cluster
% [pcl2, vc]=merge_cluster(pcl, parcelle)
%
% pcl2: merged parcelles
% vc: vector of the parcel number for each source
% pcl: product of geod_cluster
% parcelle: list of {list of seeds} 

for i=1:length(parcelle)
  seeds=[parcelle{i}];
  seeds(seeds>2027)=[];
  pcl2{i}= [pcl{seeds}];
  vc([pcl2{i}])=i;
end