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
    
    function UpdateValues(c)
      for i = 1 : c.nUnits
        c.posMem(i).prevPos       = c.posMem(i).curPos;
        c.posMem(i).prevFitness   = c.posMem(i).curFitness;
        c.posMem(i).curPos        = c.unitArray.units(i).pos;
        c.posMem(i).curFitness    = c.unitArray.units(i).fitness;
        
        if c.posMem(i).curFitness > c.optPos(i).curFitness
          c.optPos(i).prevPos     = c.optPos(i).curPos;
          c.optPos(i).prevFitness = c.optPos(i).curFitness;
          c.optPos(i).curFitness  = c.posMem(i).curFitness;
          c.optPos(i).pos         = c.posMem(i).curPos;
        end
      end
    end
    
    function ClearOptPos(c, idx)
      if isempty(idx)
        error('Must specify an index value')
      end
      for i = 1 : length(idx)
        c.optPos(idx(i)).curPos     = 0;
        c.optPos(idx(i)).curFitness = 0;
      end
    end
    
    function [groups, nGroups] = Classify(c)
      
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
    
  end
  
end

