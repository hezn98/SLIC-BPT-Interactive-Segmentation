%%% create supper pixel

function BPTCreat(imgfile)
close all
%% data folder
datafolder = './EvalData/';

%%% load original image
imgData = imread(strcat(datafolder,'Orig/',imgfile));
imgMask = imread(strcat(datafolder,'mask.png'));

%%% add path of SLIC

addpath('./SLIC-Superpixel-master');

%%% create super pixel
nRegion = 100;

tic
%hsvImg =rgb2hsv(imgData);
sp  = mexGenerateSuperPixel(double(imgData), nRegion);
%%% draw regions on original images
[imgDraw, feat] = segToImg2(imgData,sp+1);
toc

%%% show tree
Y = pdist(feat);
Z = linkage(Y);

%figure(1)
%size(feat)
%dendrogram(Z,0);

%%% trace for foreground
markFG = [31 33 52 55 56];
for i=1:numel(markFG)
    tempID = traverse(Z,markFG(i));
    size(tempID)
    if i==1 
        nodeIDs_fg = tempID;
    else
        nodeIDs_fg = horzcat(nodeIDs_fg,tempID);
    end
end
nodeIDs_fg = unique(nodeIDs_fg);
nodeIDs_bg = traverse(Z,19);


%%% search the conflicted nodes

idx_cfNodes = searchConflictNodes(nodeIDs_fg,nodeIDs_bg)


regID_bg = traceReg(Z, nodeIDs_bg, idx_cfNodes(2));
regID_bg = unique(regID_bg)


regID_fg = traceReg(Z,nodeIDs_fg,idx_cfNodes(1));
regID_fg = unique(regID_fg)



bgpixelIDs = getPixels(regID_bg, sp);
fgpixelIDs = getPixels(regID_fg, sp);

length(bgpixelIDs)
length(fgpixelIDs)

numel(sp)
pause
[m n] = size(sp);
labelImg = zeros(m,n);
labelImg(bgpixelIDs) = 1;
labelImg(fgpixelIDs) = 2;
figure
imagesc(labelImg);
axis image;

edgeImg = edge(labelImg,'canny');
idx = find(edgeImg);
R = imgData(:,:,1);
G = imgData(:,:,2);
B = imgData(:,:,3);
R(idx) = 255;
G(idx) = 255;
B(idx) = 255;
newImg(:,:,1) = R;
newImg(:,:,2) = G;
newImg(:,:,3) = B;

figure
imshow(newImg,[]);

function pixelIDs = getPixels(regID, seg)

for i=1:length(regID)
    inds = find(seg ==regID(i));
    if i==1 
        pixelIDs = inds;
    else
        pixelIDs = [pixelIDs;inds];
    end
end

function nodeIDs_conflict = searchConflictNodes(nodeIDs_fg,nodeIDs_bg)

D = pdist2(nodeIDs_fg',nodeIDs_bg');

[r ,c] = find(D==0,1,'first');

nodeIDs_conflict= [r c] ;  %% the positions where node conflict exists




%%% this function trace nodesID from lowest level to a higher level
function allRegID = traceReg(Z,nodeIDs,stopNodeIDX)

%% total regions
allRegID=[];
for i=1:stopNodeIDX-1
    %[r c] = find(Z == nodeIDs(i));
    
    %currNodes = Z(r,1:2)
    regID = tracedown(Z,nodeIDs(i));
    
    
%     if (currNodes(1) < m) && (currNodes(2) < m)
%        regID =  currNodes;
%     end
%     
%     if (currNodes(1) < m) && (currNodes(2) > m)
%         regID = [currNodes(1), lookingTree(Z,currNodes(2))];
%     end
%     
%     if (currNodes(1) > m) && (currNodes(2) < m)
%         regID = [currNodes(2), lookingTree(Z,currNodes(1))];
%     end
%     
%     if (currNodes(1) > m) && (currNodes(2) > m)
%         regID = [lookingTree(Z,currNodes(1)), lookingTree(Z,currNodes(2))];
%         pause
%     end
   
    if i==1
        allRegID = regID;
    else
        allRegID = horzcat(allRegID, regID);
    end
    
    
end


function out = tracedown(tree, ID1)
result =[];
m= size(tree,1)+1;
if ID1 > m
   r =  ID1 - m;
   a = tree(r,1);
   b = tree(r,2);
   result = [result, tracedown(tree, a), tracedown(tree,b)];
else
    result = [result,ID1];
    
end
out = result;
    