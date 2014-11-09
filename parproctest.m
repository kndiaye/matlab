%% Test parallel processing toolbox on MATLAB 2014a
parpool(3)
spmd
% build magic squares in parallel
q = magic(labindex + 2);
end
for ii=1:length(q)
% plot each magic square
figure, imagesc(q{ii});
delete(gcp)