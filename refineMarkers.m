function [FGMark, BGMark] = refineMarkers(FGMark, BGMark)

D = pdist2(FGMark,BGMark,'euclidean');
[r c]= find(D==0);

FGMark(r) = [];
BGMark(c) = [];
end