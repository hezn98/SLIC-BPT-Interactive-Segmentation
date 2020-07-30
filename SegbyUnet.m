function [imgtemp, UnetPredictMask] = SegbyUnet(img,  UnetPredict ,thresh)  
   
    idx = find(UnetPredict > thresh);
    [m n]= size(UnetPredict);
    UnetPredictMask = zeros(m, n);
    UnetPredictMask(idx) = 1;

     %% to remove too small regions
    UnetPredictMask = bwareaopen(UnetPredictMask, 100);
    
    %% to fill holes
    UnetPredictMask = imfill(UnetPredictMask,'holes');
    
    edgeImg= edge(UnetPredictMask,'canny');
    se = strel('disk',1,4);
    edgeImg = imdilate(edgeImg,se);
    totalIDX = edgeImg==1;
    R = img(:,:,1);
    G = img(:,:,2);
    B = img(:,:,3);
  
    idx=   find(edgeImg > 0);
    R(idx) = 255;
    G(idx) = 0;
    B(idx) = 255;

    imgtemp(:,:,1) =R;
    imgtemp(:,:,2) =G;
    imgtemp(:,:,3) =B;
end