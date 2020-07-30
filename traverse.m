function nodeIDs = traverse(mat, firstID)
%% Inputs are
% A mat object with the 3 columns with each row represent:
% 2 child nodes ID and the euclidean cost of them
% The new parent node will have the ID = row + size(mat, 1)
% firstID1: the first nodes which have the label 1 (foreground)
% firstID0: the first nodes which have the label 0 (background)
% currently testing with 1 first node per each label
%% Outputs are
% r1: Vector with each row serve as nodeIDs that will be assigned the label 1
% r0: Vector with each row serve as nodeIDs that will be assigned the label 0
%% Proposed algorithm
% find the row a of the firstID1 then find the next row of the nodeID a +
% size(mat, 1) and then find the next row like this and so on
%% Checking if mat have 3 columns
sz = size(mat);
%% Store the result matrix, nodeID of 1 and 0
m = sz(1)+1;

rfg = [firstID];


%% First phase: Find all parent nodes of the labeled node firstID1

[r, c] = find(mat == firstID); %Find the row of it
n = 0;
while (n < (2 * m-1))
    n = r + m;% NodeID of the parent
    [r, c] = find(mat == n);% Precedent of the parent node
    rfg = [rfg, n]; %Appending nodeID of the parent
end
nodeIDs = rfg;
end

