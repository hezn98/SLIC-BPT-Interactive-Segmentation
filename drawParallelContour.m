function imgContour = drawParallelContour(imgPath, maskPath)
image = imread(imgPath);
mask = imread(maskPath);
mask = rgb2gray(mask);
e = edge(mask, 'canny');
se = strel('disk', 1, 4);
edgeImg = imdilate(e, se);
sz = size(rgb2gray(mask));
R = image(:,:,1);
G = image(:,:,2);
B = image(:,:,3);

%idx = find(edgeImg == 1);
[y, x] = find(edgeImg == 1);
disp(size(y));
disp(size(x));
idx = sub2ind(sz, y, x);
[xi, yi, xo, yo, ~, ~, ~, ~] = parallel_curve(x, y, 100, 0, 0);
disp(size(yi));
disp(size(xi));
idxI = sub2ind(sz, uint8(yi), uint8(xi));
idxO = sub2ind(sz, uint8(yo), uint8(xo));
R(idx) = 255;
G(idx) = 255;
B(idx) = 0;
R(idxI) = 0;
G(idxI) = 255;
B(idxI) = 0;
R(idxO) = 0;
G(idxO) = 0;
B(idxO) = 255;
imgContour(:,:,1) =R;
imgContour(:,:,2) =G;
imgContour(:,:,3) =B;
end