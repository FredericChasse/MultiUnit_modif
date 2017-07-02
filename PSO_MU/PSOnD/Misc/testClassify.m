clear all

units = [114 85 120 90 118 101 95 86   110 96 115  ];

margin = 10;

nUnits = length(units);

g= round(units/margin);

groups = {};
groupsIdx = {};

% for g_u= unique(g), groups{end+ 1}= units(g_u== g); end

g_u = unique(g);

for i = 1 : length(g_u)
  groups{end+1} = units(g_u(i) == g);
  groupsIdx{end+1} = find(g_u(i) == g);
end

for i = 1 : length(groups)
  fprintf([num2str(groups{i}) '\n'])
  fprintf([num2str(units(groupsIdx{i})) '\n'])
end
% [sortPos sortIdx] = sort(units);
%       
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