clear all

% units = [85 86 90 101 110 114 115 118 120 131 135 150 159 161 165 169 170 171 180 190];
% units = [139.4 135.5 131.6 131.6 131.6 129.3 132.9 129.2 137.6 69.6];
% units = [139.4 135.5 131.6 129.3 132.9 129.2 137.6 205];
% units = [159.8039  179.4118  183.3333  183.3334  187.2549  187.2549  195.0980  199.0196  199.0196  199.0196  218.6275  222.5490  242.1568];
units = [700,700,700,649,600,675,675,675,625,625];

% margin = 20;
% margin = 7.8431;
margin = 10;

nUnits = length(units);

groups = {};
groupsIdx = {};

% % https://stackoverflow.com/questions/6794210/grouping-similar-values-in-matlab
% % for g_u= unique(g), groups{end+ 1}= units(g_u== g); end
% 
% g= round(units/margin);
% g_u = unique(g);
% 
% for i = 1 : length(g_u)
%   groups{end+1} = units(g_u(i) == g);
%   groupsIdx{end+1} = find(g_u(i) == g);
% end
% 
% % for iGroup = 1 : length(groups) - 1
% %   if max(groups{iGroup}) - min(groups{iGroup + 1}) < margin
% %     
% %   end
% % end
% 
% for i = 1 : length(groups)
%   fprintf([num2str(groups{i}) '\n'])
%   fprintf([num2str(units(groupsIdx{i})) '\n'])
% end

[sortPos sortIdx] = sort(units);

iGroup = 1;
nGroups = 1;
groups{iGroup} = sortPos(1);
for iUnit = 2 : nUnits
  if (sortPos(iUnit) - groups{iGroup}(1)) <= margin
    groups{iGroup} = [groups{iGroup} sortPos(iUnit)];
  else
    iGroup = iGroup + 1;
    nGroups = nGroups + 1;
    if length(groups{iGroup - 1}) > 1
      if (sortPos(iUnit) - groups{iGroup - 1}(end)) < (groups{iGroup - 1}(end) - groups{iGroup - 1}(end - 1))
        groups{iGroup} = [groups{iGroup - 1}(end) sortPos(iUnit)];
        groups{iGroup - 1}(end) = [];
      else
        groups{iGroup} = sortPos(iUnit);
      end
    else
      groups{iGroup} = sortPos(iUnit);
    end
  end
end

groupIdx = 0;
for iGroup = 1 : length(groups)
  groupIdx = groupIdx + 1;
  if length(groups{groupIdx}) < 3
    if groupIdx > 1 && groupIdx < length(groups)
      if groups{groupIdx}(1) - groups{groupIdx-1}(end) < groups{groupIdx+1}(1)-groups{groupIdx}(end)
        groups{groupIdx-1} = [groups{groupIdx-1} groups{groupIdx}];
        groups(groupIdx) = [];
        groupIdx = groupIdx - 1;
      else
        groups{groupIdx+1} = [groups{groupIdx} groups{groupIdx+1}];
        groups(groupIdx) = [];
        groupIdx = groupIdx - 1;
      end
    elseif groupIdx == 1
        groups{groupIdx+1} = [groups{groupIdx} groups{groupIdx+1}];
        groups(groupIdx) = [];
        groupIdx = groupIdx - 1;
    else
        groups{groupIdx-1} = [groups{groupIdx-1} groups{groupIdx}];
        groups(groupIdx) = [];
        groupIdx = groupIdx - 1;
    end
  end
end

groupsIdx = cell(1, length(groups));
for i = 1 : length(groups)
  iSame = 0;
  for iUnit = 1 : length(units)
    if find(units(iUnit) == groups{i}, 1)
      iSame = iSame + 1;
      groupsIdx{i}(iSame) = iUnit;
    end
  end
end

for i = 1 : length(groups)
  fprintf([num2str(groups{i}) '\n'])
  fprintf([num2str(groupsIdx{i}) '\n'])
%   fprintf([num2str(units(groupsIdx{i})) '\n'])
end



% nGroups = 0;
% dist = 0;
% iUnit = 1;
% jStart = 1;
% while (iUnit < nUnits)
%   while(dist < margin) && (iUnit < nUnits)
%     dist = sortPos(iUnit+1) - sortPos(iUnit);
%     if dist < margin
%       iUnit = iUnit + 1;
%     else
%       break;
%     end
%   end
%   dist = 0;
%   nGroups = nGroups + 1;
%   curGroup = [];
%   for jUnit = jStart : iUnit
%     curGroup(jUnit - jStart + 1) = sortIdx(jUnit); %#ok<AGROW>
%   end
%   jStart = jUnit + 1;
%   groups{nGroups} = curGroup; %#ok<AGROW>
%   
%   iUnit = iUnit + 1;
% end