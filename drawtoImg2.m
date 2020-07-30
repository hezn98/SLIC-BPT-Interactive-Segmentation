function imgtemp = drawtoImg2(maskAll, img, alpha, color)
%R = img(:,:,1);
%G = img(:,:,2);
%B = img(:,:,3);

edgeImg = edge(maskAll,'canny');
se = strel('disk',1,4);
edgeImg = imdilate(edgeImg,se);

%idx = find(edgeImg > 0);

%R(idx) = 255;
%G(idx) = 0;
%B(idx) = 255;

%imgtemp(:,:,1) =R;
%imgtemp(:,:,2) =G;
%imgtemp(:,:,3) =B;
switch color
    case 1
        imgbg  = cat(3, zeros(size(edgeImg)), 255*ones(size(edgeImg)), zeros(size(edgeImg)));
    case 2
        imgbg  = cat(3, 255*ones(size(edgeImg)), 255*ones(size(edgeImg)), zeros(size(edgeImg)));
    case 3
        imgbg  = cat(3, 255*ones(size(edgeImg)), zeros(size(edgeImg)), 255*ones(size(edgeImg)));
end
imgtemp= blending(imgbg, img, edgeImg, alpha);

function imgRes = blending(imgfg,imgbg, imgMask, alpha)

imgfg = double(imgfg)./255;
imgbg = double(imgbg)./255;

[m, n, ~] = size(imgfg);

idx = imgMask > 0;
alphaImg = zeros(m,n);
alphaImg(idx) = alpha;

imgRes(:,:,1) =imgfg(:,:,1).*alphaImg + imgbg(:,:,1).*(1-alphaImg);
imgRes(:,:,2) =imgfg(:,:,2).*alphaImg + imgbg(:,:,2).*(1-alphaImg);
imgRes(:,:,3) =imgfg(:,:,3).*alphaImg + imgbg(:,:,3).*(1-alphaImg);
