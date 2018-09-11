% ==========================================================
% Copyright (C) Damien Berget 2013
% This code is only usable for non-commercial purpose and 
% provided as is with no guaranty of any sort
% ==========================================================
% 
% Matlab STL Slicer step 1.
% See http://exploreideasdaily.wordpress.com for details.

clear *
dbstop if error

fileName = 'flatCircle_S20-W0.5-H2.stl';

[vertices, tessellation] = readStl(fileName);

layerThickness = 0.5;

%build top amd bottom Z triangle list
[triBottomList, triTopList] = buildTopBotLists(vertices, tessellation);

%for display get limits
xLimits = [min(vertices(:,1)) max(vertices(:,1))];
yLimits = [min(vertices(:,2)) max(vertices(:,2))];

%current plan Z
currZ = triBottomList(1,1);

%Index in the top/bot list
botIdx = 0; topIdx = 0;
%list of currently 'active' triangles
currTri = [];

%go through all the Z plans
figure(1)
hdl = subplot(1,1,1);
while currZ <= triTopList(end, 1)
    %add triangle upto currZ (from bottom list)
    if botIdx < numel(triBottomList)
       while triBottomList(botIdx + 1, 1) <= currZ
           currTri(end + 1) = triBottomList(botIdx + 1, 2);
           botIdx = botIdx + 1;
           if botIdx == size(triBottomList,1)
               break;
           end
       end
    end

    %remove triangle under currZ (from top list)
    if topIdx < numel(triTopList)
        remList = [];
        while triTopList(topIdx + 1, 1) < currZ
            remList(end + 1) = triTopList(topIdx + 1, 2);
            topIdx = topIdx + 1;
            if topIdx == size(triTopList,1)
                break;
            end
        end
        
        currTri = setdiff(currTri, remList);
    end
    
    %compute interections of all current triangles with current Z
    currIntersect = {};
    for idxTri = 1:numel(currTri)
        triCoo = vertices(tessellation(currTri(idxTri),:), :);
        currIntersect{end + 1} = triPlanIntersect(triCoo, currZ);
    end
    
    %display all the intersections
    cla(hdl)
    hold all
    axis equal
    xlim(xLimits)
    ylim(yLimits)
    for idxObj = 1: numel(currIntersect)
        switch size(currIntersect{idxObj}, 1)
            case 1
                plot(currIntersect{idxObj}(:,1), currIntersect{idxObj}(:,2), '+');
            case 2
                plot(currIntersect{idxObj}(:,1), currIntersect{idxObj}(:,2), '-');
            case 3
                fill(currIntersect{idxObj}(:,1), currIntersect{idxObj}(:,2), rand(1,3));
        end
    end
    title(sprintf('Slice Z = %4.2f', currZ))
    drawnow
    pause(0.2)
    
    %move to next plan
    currZ = currZ + layerThickness;
end





