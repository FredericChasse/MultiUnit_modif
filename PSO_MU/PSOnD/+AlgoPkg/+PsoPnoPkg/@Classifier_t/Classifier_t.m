classdef Classifier_t < handle
  
  properties
    unitArray
    nUnits
    posMem
    optPos
    margin
  end
  
  methods
    
    % Constructor
    function c = Classifier_t(unitArray, margin)
      import AlgoPkg.*
      
      if isempty(margin) || margin < 0
        error('invalid margin!')
      end
      c.unitArray = unitArray;
      c.nUnits    = unitArray.nUnits;
      c.posMem    = Position_t.empty;
      c.optPos    = Position_t.empty;
      c.margin    = margin;
      
      for iUnit = 1 : c.nUnits
        c.posMem(iUnit) = Position_t(1);
        c.optPos(iUnit) = Position_t(1);
      end
      
    end
    
    % Destructor
    function Del(c)
      delete(c);
    end
    
    % Update values of all units
    function UpdateValues(c)
      for i = 1 : c.nUnits
        c.posMem(i).prevPos       = c.posMem(i).curPos;
        c.posMem(i).prevFitness   = c.posMem(i).curFitness;
        c.posMem(i).curPos        = c.unitArray.units(i).pos;
        c.posMem(i).curFitness    = c.unitArray.units(i).fitness;
        
        if c.optPos(i).curPos == c.posMem(i).curPos && c.optPos(i).curFitness ~= c.posMem(i).curFitness
          c.optPos(i).curFitness = c.posMem(i).curFitness;
        end
        
        if c.posMem(i).curFitness > c.optPos(i).curFitness
          c.optPos(i).prevPos     = c.optPos(i).curPos;
          c.optPos(i).prevFitness = c.optPos(i).curFitness;
          c.optPos(i).curFitness  = c.posMem(i).curFitness;
          c.optPos(i).curPos      = c.posMem(i).curPos;
        end
      end
    end
    
    % Reset values after a perturbation
    function ResetValues(c, idx)
      if isempty(idx)
        error('Must specify an index value')
      end
      for i = 1 : length(idx)
        c.optPos(idx(i)).curPos     = c.posMem(idx(i)).curPos;
        c.optPos(idx(i)).curFitness = c.posMem(idx(i)).curFitness;
      end
    end
    
    % Classify all units
    function [groups, nGroups] = ClassifyAll(c)
      
      g= round(c.optPos(:).curPos/c.margin);

      groupValues = {};
      groups = {};

      g_u = unique(g);

      for i = 1 : length(g_u)
        groupValues{end+1} = c.optPos(:).curPos(g_u(i) == g); %#ok<AGROW>
        groups{end+1} = find(g_u(i) == g); %#ok<AGROW>
      end
      
      nGroups = length(groups);
    end
    
    % Classify certains units together
    function [groups, nGroups] = ClassifySome(c, idx)
      
      if isempty(idx)
        error('Empty index')
      end
      
      optPos = zeros(1,length(idx));
      for i = 1 : length(idx)
        optPos(i) = c.optPos(idx(i)).curPos;
      end
      
      optPosSort = sort(optPos);iGroup = 1;
      
      nGroups = 1;
      groups = {};
      groups{iGroup} = optPosSort(1);
      for iUnit = 2 : length(optPos)
        if (optPosSort(iUnit) - groups{iGroup}(1)) <= c.margin
          groups{iGroup} = [groups{iGroup} optPosSort(iUnit)];
        else
          iGroup = iGroup + 1;
          nGroups = nGroups + 1;
          if length(groups{iGroup - 1}) > 1
            if (optPosSort(iUnit) - groups{iGroup - 1}(end)) < (groups{iGroup - 1}(end) - groups{iGroup - 1}(end - 1))
              groups{iGroup} = [groups{iGroup - 1}(end) optPosSort(iUnit)];
              groups{iGroup - 1}(end) = [];
            else
              groups{iGroup} = optPosSort(iUnit);
            end
          else
            groups{iGroup} = optPosSort(iUnit);
          end
        end
      end

      groupsIdx = cell(1, length(groups));
      for i = 1 : length(groups)
        iSame = 0;
        for iUnit = 1 : length(optPos)
          if find(optPos(iUnit) == groups{i}, 1)
            iSame = iSame + 1;
            groupsIdx{i}(iSame) = idx(iUnit);
          end
        end
      end
      
      groups = groupsIdx;
      
%       idx = sort(idx);
%       
%       optPos = zeros(1,length(idx));
%       for i = 1 : length(idx)
%         optPos(i) = c.optPos(idx(i)).curPos;
%       end
%       
%       g= round(optPos/c.margin);
% 
%       groupValues = {};
%       groups = {};
% 
%       g_u = unique(g);
% 
%       for i = 1 : length(g_u)
%         groupValues{end+1} = optPos(g_u(i) == g); %#ok<AGROW>
%         groups{end+1} = find(g_u(i) == g); %#ok<AGROW>
%       end
%       
%       nGroups = length(groups);
    end
    
    % Get best position of a unit
    function d = GetBestPos(c, idx)
      if isempty(idx)
        error('Empty index')
      end
      
      d = zeros(1, length(idx));
      
      for i = 1 : length(idx)
        d(i) = c.optPos(idx(i)).curPos;
      end
    end
    
  end
  
end

