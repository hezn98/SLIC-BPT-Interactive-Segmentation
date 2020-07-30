

function RegID= getRegID(seg,PixelRegion) 

[m, n]= size(seg);

mask = zeros(m,n);
%mask = reshape(mask,[m*n 1]);
idx = sub2ind([m n],PixelRegion(:,2), PixelRegion(:,1));
mask(idx) = 1;
mask = mask.*seg;
RegID = unique(unique(mask));
RegID(1) =[]; %% remove the first one equal to 0