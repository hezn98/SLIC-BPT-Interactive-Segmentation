%%% draw regions

function  [maskAll] = drawtoImg(FGMark,seg)
nRegion = length(FGMark);
[m n] = size(seg);
maskAll = zeros(m,n);

for i=1:nRegion    
    inds = find(seg==FGMark(i));
    maskAll(inds) = 1;
end

maskAll = imfill(maskAll,'holes');

