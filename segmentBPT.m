%%% segment by BPT tree

function regID = segmentBPT(Z,markFG,markBG)


%% search nodes of FG
nodeIDs_bg = searchNode(Z,markBG);
nReg_fg = length(markFG);

for i=1:nReg_fg
    nodeIDs_fg = searchNode(Z,markFG(i));
    %% find conflict node
    idx_cfNodes = searchConflictNodes(nodeIDs_fg,nodeIDs_bg);
    tempNode = traceReg(Z, nodeIDs_fg, idx_cfNodes(1));
    if i==1
        regID = tempNode;
    else
        regID = horzcat(regID,tempNode);
    end
end
end
function nodeIDs = searchNode(Z,markReg)

for i=1:numel(markReg)
    tempID = traverse(Z,markReg(i));
    if i == 1 
        nodeIDs = tempID;
    else
        nodeIDs = horzcat(nodeIDs,tempID);
    end
end
nodeIDs = unique(nodeIDs);
end
function nodeIDs_conflict = searchConflictNodes(nodeIDs_fg,nodeIDs_bg)

D = pdist2(nodeIDs_fg',nodeIDs_bg');

[r ,c] = find(D==0,1,'first');

nodeIDs_conflict= [r c] ;  %% the positions where node conflict exists
end
function allRegID = traceReg(Z,nodeIDs,stopNodeIDX)

%% total regions
allRegID=[];
for i=1:stopNodeIDX-1
    regID = tracedown(Z,nodeIDs(i));
    if i==1
        allRegID = regID;
    else
        allRegID = horzcat(allRegID, regID);
    end
end
end

function out = tracedown(tree, ID1)
result =[];
m= size(tree,1)+1;
if ID1 > m
   r =  ID1 - m;
   a = tree(r,1);
   b = tree(r,2);
   result = [result, tracedown(tree, a), tracedown(tree,b)];
else
    result = [result,ID1];
end
out = result;
end