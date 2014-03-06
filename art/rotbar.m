% g=imread('http://essentialvermeer.20m.com/catalogue_xl/xl_girl_with_a_pearl_earring.jpg');
% % Makes it gray:
% h=mean(g,3)/255;

% size of squares
sq = [20 20];
nq = [10 10];
filling=0.8;

si = floor(size(h)./sq);
r=0.*h;
sh=zeros(si);

%Decimated matrix of gray squares
for ih=1:si(1);
    for iv=1:si(2);
        sh(ih,iv)=sum(sum(h([1:sq(1)]+(ih-1)*sq(1),[1:sq(2)]+(iv-1)*sq(2))))/prod(sq);
    end
end

hh=zeros(si.*sq);

for ih=1:si(1);
    for iv=1:si(2);
        angle=-pi*ih/si(1)+pi*iv/si(2)+rand/100;
        
        adjust=1; %max(sq)/sqrt(filling
        hh([1:sq(1)]+(ih-1)*sq(1),[1:sq(2)]+(iv-1)*sq(2))=...
            rectpix(max([sh(ih,iv) 1]*adjust.*(sq*filling), [1 1]),sq,angle);% * rh(ih,iv);
        if 0 % sh(ih,iv)>.1
            imshow(hh([1:sq(1)]+(ih-1)*sq(1),[1:sq(2)]+(iv-1)*sq(2)))
            title(num2str(sh(ih,iv)))
            pause
        end
    end
end


figure(2);
colormap(gray)
subplot(1,2,1); imagesc(sh); axis image; axis off
subplot(1,2,2); imagesc(hh); axis image; axis off
imwrite(hh, 'test.jpg')