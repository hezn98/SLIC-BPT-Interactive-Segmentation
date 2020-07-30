function [Icomb, feat] = segToImg2(origImg, seg)
%seg: the segment returned from segment
    seg_num = max(seg(:));
    centers = get_centers(seg);
    %img1 = zeros(size(seg));
    %img2 = zeros(size(seg));
    %img3 = zeros(size(seg));
    [m, n] = size(seg);
    
    Idata = reshape(origImg,[m*n 3]);
    minVal = min(Idata,[],1);
    maxVal = max(Idata,[],1);
    minImg = repmat(minVal,[m*n 1]);
    maxImg = repmat(maxVal,[m*n 1]);
    
    Idata = (Idata -minImg)./(maxImg-minImg);
   
    Idata = rgb2luv(Idata');
    Idata = Idata';
    
    if (nargin == 2)
        colors = rand(seg_num, 3);
        for i=1:seg_num
            inds = (seg==i);
            %% get features
            feat(i,:) = mean(Idata(inds,1:3),1);
            stdreg(i,:) = std(double(Idata(inds,:)),0,1);
        end
        
    end
    %% update feat
    centers(:,1) = (centers(:,1))/m;
    centers(:,2) = (centers(:,2))/n;
    feat = horzcat(feat, stdreg, centers);
    
    totalIDX = seg  > 0;
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