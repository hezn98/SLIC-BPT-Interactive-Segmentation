function [Icomb, feat, segRefine] = segToImg3(origImg, seg,predict,mask)
%seg: the segment returned from segment
    seg_num = max(seg(:));
    %centers = get_centers(seg);
    img1 = zeros(size(seg));
    img2 = zeros(size(seg));
    img3 = zeros(size(seg));
    [m n] = size(seg);
    segRefine = zeros(m,n);
    %origImg = rgb2hsv(origImg);
    Idata = double(reshape(origImg,[m*n 3]));
    minVal = min(Idata,[],1);
    maxVal = max(Idata,[],1);
    minImg = repmat(minVal,[m*n 1]);
    maxImg = repmat(maxVal,[m*n 1]);
    
    
    
    Idata = (Idata - minImg)./(minImg - maxImg);
    Idata = rgb2luv(Idata');
    Idata = Idata';
        colors = rand(seg_num, 3);
        t = 1;
        for i=1:seg_num
            
            inds = (seg==i);
            if sum(mask(inds))/length(inds) > 0.1  %% regions is large enough
                img1(inds) = colors(i, 1);
                img2(inds) = colors(i, 2);
                img3(inds) = colors(i, 3);

                %% get features
                feat(t,:) = mean(Idata(inds,:));
                stdreg(t,:) = std(double(Idata(inds,:)),0,1);
                [rInd, cInd] = ind2sub([m n],inds);
                centers(t, :) = [mean(rInd), mean(cInd)];
                unetFeat(t,:) = mean(predict(inds));
                segRefine(inds) = t;
                t=t+1;
            end
        end
        
    %% update feat
    
    measurements = regionprops(segRefine, 'Solidity','centroid','area');
    compactness = [measurements.Solidity]';
    c = cat(1, measurements.Centroid);
    areareg = cat(1, measurements.Area);
    [foo idxs] = max(areareg);
    
    centers(:,1) = abs((centers(:,1)-c(idxs,1)))/m;
    centers(:,2) = abs((centers(:,2)-c(idxs,2)))/n;
    
    feat = horzcat(feat,unetFeat,stdreg); %,compactness);
    img(:,:,1) = img1;
    img(:,:,2) = img2;
    img(:,:,3) = img3;
    
   
    edgeImg = zeros(m,n);
    totalIDX = segRefine  > 0;
    edgeImg(totalIDX) = 1;
    
    edgeImg= edge(edgeImg,'canny');
    totalIDX = edgeImg==1;
    R = origImg(:,:,1);
    G = origImg(:,:,2);
    B = origImg(:,:,3);

    R(totalIDX) = 255;
    G(totalIDX) = 255;
    B(totalIDX) = 255;
    Icomb = origImg;
    Icomb(:,:,1) = R;
    Icomb(:,:,2) = G;
    Icomb(:,:,3) = B;
end