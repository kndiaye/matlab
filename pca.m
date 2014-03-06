function [Y, lbd, cos2, CC] = pca(X, P, labels)
%PCA Principal Components Analysis
%
%       Y = PCA(X, P) returns the first P principal components of X.
%       X must be a NxL matrix of N vectors in L dimensions.
%
%       Y = PCA(X, P, LABELS) displays several plots related to the PCA:
%         . projection of data on the first two principal axes,
%         . correlation circle,
%         . % inertia of the principal components,
%         . angles of the data w.r.t. the PC subspace.
%       If LABELS is a matrix containing N rows of text, each row is used
%       to label the corresponding data point, otherwise data go unlabelled.
%
%       Additional outputs: [Y, LBD, C2, CC] = PCA(X, P [, LABELS]), where
%       Y is the projection of X on the first P principal components,
%       LBD contains the % inertia of the required P components,
%       C2 is the squared cosine between projected data and original data,
%       CC is the correlation between the input features and the first P P.C.
%
% See also: .
if (nargin < 2) or (nargin > 4)
  error('PCANA: wrong number of arguments.')
end

[N, L] = size(X) ;
if (P < 1)
  error('PCANA: must return at least 1 principal component.')
end
if (P > L)
  error('PCANA: can''t get more principal components than dimensions.')
end

if (nargin == 2)
  verbose = 0 ;
end

%%%%%%%%%%

R = corrcoef(X) ;
% XM= ones(N,1) * mean(X') ;
% Xc = X' - XM ;
% [U, S, V] = svd(Xc, 0) ;
[V, S] = eig(R) ;
[l, idx] = sort(diag(S)') ;
l = fliplr(l) ;
idx = fliplr(idx) ;

% Coordonees centrees reduites.
XCR = (X - ones(N,1)*mean(X)) / diag(std(X)) ;
%PC = (Xc * V(:,idx)' + XM)' ;
PC = (XCR * V(:,idx) ) ;

% P first principal components:
Y = PC(:, 1:P) ;

% P first portions of inertia:
lbd = l(1:P) / sum(l) ;

% Squared cosines of projection vs. original data:
cos2 = sum((Y.^2)') ./ sum((XCR.^2)') ;

% Correlations of features with PCs:
CC = V(:,idx) * diag(sqrt(l)) ;

if (nargin == 3)
  figure
  subplot(2,2,1) ;
  plot(PC(:,1), PC(:,2), '+') ;
  if (size(labels, 1) == N)
    for i = 1:N
      text(PC(i,1), PC(i,2), [' ', labels(i,:)]) ;
    end
  end  
  xlabel('First principal axis') ;
  ylabel('Second principal axis') ;
  title('Data projection on the first two principal axes')
  subplot(2,2,2) ;
  plot(cos(2*pi*(0:100)/100), sin(2*pi*(0:100)/100)) ;
  hold on, plot([-1, 1], [0, 0]), plot([0, 0], [-1, 1]) ;
  plot(CC(:,1), CC(:,2), 'x') ;
  for k = 1:L
    text(CC(k,1)+.03, CC(k,2)+.03, num2str(k)) ;
  end
  xlabel('First PC') ;
  ylabel('Second PC') ;
  title('Correlation of features with first 2 PCs')
  subplot(2,2,3) ;
  hh = plot(l/sum(l), '--') ;
  set(hh, 'LineWidth', 3) ;
  hold on, hh = plot(cumsum(l)/sum(l)) ;
  set(hh, 'LineWidth', 3) ;
  axis([1 L 0 1]) ;
  plot([2 2], [0 1]) ;
  xlabel('PC no.') ;
  ylabel('Inertia') ;
  legend('PC inertia', 'Cumulated inertia') ;
  title('Repartition of inertia on the PCs') ;
  subplot(2,2,4) ;
  hold on
  hh = plot(acos(sqrt(cos2))/pi*180, 1:N, '+') ;
  set(hh, 'LineWidth', 3) ;
  hold on
  for i = 1:N
    hh = plot([0, acos(sqrt(cos2(i)))/pi*180], [i, i], '-') ;
    set(hh, 'LineWidth', 3) ;
  end
  set(gca, 'Box', 'on') ;
  set(gca, 'YLim', [1 N]) ;
  if (size(labels, 1) == N)
    set(gca, 'YTick', 1:N) ;
    set(gca, 'YTickLabels', labels) ;
  end
  xlabel('Angle (deg)')
  title('Angle of data with the PC plan')
end

CC = CC(:,1:P) ;
