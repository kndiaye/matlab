


% http://www.abdn.ac.uk/~psy317/personal/files/teaching/spheric.htm
% http://www.psych.upenn.edu/~baron/rpsych.pdf
MD497= [420, 420, 480, 480, 600, 780,
420, 480, 480, 360, 480, 600,
480, 480, 540, 660, 780, 780,
420, 540, 540, 480, 780, 900,
540, 660, 540, 480, 660, 720,
360, 420, 360, 360, 480, 540,
480, 480, 600, 540, 720, 840,
480, 600, 660, 540, 720, 900,
540, 600, 540, 480, 720, 780,
480, 420, 540, 540, 660, 780];
% SUBJECT x ANGLE x NOISE
MD497=reshape(MD497(:),10,3,2);

H518=[
49,47,46,47,48,47,41,46,43,47,46,45,
48,46,47,45,49,44,44,45,42,45,45,40,
49,46,47,45,49,45,41,43,44,46,45,40,
45,43,44,45,48,46,40,45,40,45,47,40
];
H518=H518';
%SSUBJECT x SHAPE x COLOR
H518=reshape(H518,12,2,2);

X=H518;

X=MD497;

v=cov(mean(X,3));

NL=size(X,2); %Nb of levels in factor ANGLE
N=10; % NB of subjects

epsilonGG=NL^2*(mean(diag(v)) - mean(v(:))).^2/(NL-1)/(sum(v(:).^2) - 2*NL*sum(mean(v).^2) + NL^2*mean(v(:)).^2)
epsilonHF=(N*(NL-1)*epsilonGG-2)/(NL-1)/(N-1-(NL-1)*epsilonGG)


return

% http://www.linguistics.ucla.edu/faciliti/facilities/statistics/fromoac.htm
% 
X=[100 90 130  ; 90 100 100 ; 110 110 109 ; 100  90 109 ; 100 100 130]; 
X=X';
[p,F]=myanova(X,1,1)




return
% http://www.linguistics.ucla.edu/faciliti/facilities/statistics/fromoac.htm
% Example 2
X=[
 8  9  8   8  9   7   10  9  10;
 9  10 9  10  9  13   8   9   9;
 8  7  7  12  7   9   10  9   7;
 6  8  9   8 10  10   12  9   10;
 7  6  7  11 12   8   8   11  9];
X=X;
X=reshape(X,5,3,3);
% COND TRIAL SUBJECT
X=permute(X,[3 2 1]);
[p,F]=myanova(X,2,1:2)

