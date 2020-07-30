function [Icomb, feat] = segToImg2(origImg, seg, clustter)
%seg: the segment returned from segment
    seg_num = max(seg(:));
    centers = get_centers(seg);
    img1 = zeros(size(seg));
    img2 = zeros(size(seg));
    img3 = zeros(size(seg));
    [m n] = size(seg);
    %origImg = rgb2hsv(origImg);
    
    Idata = reshape(origImg,[m*n 3]);
    minVal = min(Idata,[],1);
    maxVal= max(Idata,[],1);
    minImg =repmat(minVal,[m*n 1]);
    maxImg =repmat(maxVal,[m*n 1]);
    
    Idata = (Idata -minImg)./(maxImg-minImg);
   
    Idata = rgb2luv(Idata');
    Idata = Idata';
    
    
    
    if (nargin == 2)
        colors = rand(seg_num, 3);
        for i=1:seg_num
            inds = (seg==i);
            img1(inds) = colors(i, 1);
            img2(inds) = colors(i, 2);
            img3(inds) = colors(i, 3);
            
            %% get features
            feat(i,:) = mean(Idata(inds,1:3),1);
            stdreg(i,:) = std(double(Idata(inds,:)),0,1);
            %gaboram(i) = max(gaborRes(inds));
        end
        
    else
        for m = 1:length(clustter)
            ele = clustter{m};
            color = rand(3,1);
            factor = linspace(1, 1, length(ele));
            
            for i = 1:length(ele)
                inds = seg==ele(i);
                img1(inds) = color(1)*factor(i);
                img2(inds) = color(2)*factor(i);
                img3(inds) = color(3)*factor(i);
            end
        end
    end
    
    %% update feat
    centers(:,1) = (centers(:,1))/m;
    centers(:,2) = (centers(:,2))/n;
    
    
    feat = horzcat(feat,centers);
    img(:,:,1) = img1;
    img(:,:,2) = img2;
    img(:,:,3) = img3;
    
    %figure(333);
    %subplot(121)
    %imshow(img);
    %hold on
    %for i=1:seg_num
    %    plot(centers(i, 2), centers(i, 1), '.');
     %   text(centers(i, 2), centers(i, 1), num2str(i));
    %end
    %hold off
    %subplot(122)
    
    
    edgeImg1 = edge(img1,'canny');
    edgeImg2 = edge(img2,'canny');
    edgeImg3 = edge(img3,'canny');
    
    totalIDX = (edgeImg1+ edgeImg2 + edgeImg3) > 0;
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
    %imshow(Icomb);

end