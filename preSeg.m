%%% pre-segmentation

function preSeg(imgfile)

datafolder = './EvalData/';

imgData = imread(strcat(datafolder,'Orig/',imgfile));
imgMask = imread(strcat(datafolder,'mask.png'));

%% show img size
size(imgData)
scale = 0.25;
I = imresize(imgData,scale);
imgMask = imresize(imgMask,[size(I,1) size(I,2)]);
idxMask = find(imgMask < 1);
kernel = fspecial('gaussian',[5 5],1.5);
I = imfilter(I,kernel);
%%% get imgSegment
bandwidth = 0.25;
[Ims, labelImg Kms] = Ms2(I,bandwidth,idxMask);


%%% dump labelImg into a mat file

pat = '\.';
prefix = regexp(imgfile,pat,'split');
segfile = strcat(datafolder,'Preseg/',prefix{1},'.mat');
save(segfile,'labelImg');





