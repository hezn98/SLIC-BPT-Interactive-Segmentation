%%% analyze data

function PreSegAna(imgfile)
close all
datafolder = './EvalData/';
imgData = imread(strcat(datafolder,'Orig/',imgfile));

%% show img size
size(imgData)
scale = 0.25;
I = imresize(imgData,scale);
prefix = getPrefix(imgfile)

%%% load segmentation result
preSegFile = strcat(datafolder,'PreSeg/',prefix,'.mat');
load(preSegFile,'labelImg')

size(labelImg)
imgSeg = label2rgb(labelImg);
nlabel = max(max(labelImg))

[I, feat, pos] = getCombine(I,labelImg);
%%% 
figure(111)
subplot(121)
imshow(I)
title(imgfile,'fontsize',14)

subplot(122)
imagesc(imgSeg);
axis image
colormap hsv
hold on
for i=1:nlabel
    text(pos(i,1),pos(i,2),num2str(i),'fontsize',14);
    hold on
end
title(strcat('nClass = ',num2str(nlabel)),'fontsize',14);

%%% show tree
Y = pdist(feat);
Z = linkage(Y);
%leaforder  =optimalleaforder(Z,Y);
figure(222)
dendrogram(Z,0);

function prefix = getPrefix(imgfile)

pat = '\.';
prefix = regexp(imgfile,pat,'split');
prefix = prefix{1};


function [Icomb, feat, pos]= getCombine(I,labelImg)

%edgeImg = edge(labelImg,'canny',[0.1 0.5]);
nlabel = max(max(labelImg));
[m n] = size(labelImg);
Idata = reshape(I,size(I,1)*size(I,2), 3);

for i=1:nlabel
    mask = zeros(m,n);
    idx = find(labelImg == i);
    mask(idx) = 1;
    edgeImg = edge(mask,'canny');
    edgeidx = find(edgeImg > 0);
    feat(i,:) = mean(Idata(idx,:),1);
    [c,r] = ind2sub(size(labelImg),idx);
    pos(i,:) = [floor(mean(r)) floor(mean(c))];
    if i==1
        totalIDX = edgeidx;
        
    else
        totalIDX = vertcat(totalIDX,edgeidx);
    end
end

%se = strel('disk',1,0);
%edgeImg = imdilate(edgeImg,se);


R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);

R(totalIDX) = 255;
G(totalIDX) = 255;
B(totalIDX) = 255;

Icomb = I;
Icomb(:,:,1) = R;
Icomb(:,:,2) = G;
Icomb(:,:,3) = B;


