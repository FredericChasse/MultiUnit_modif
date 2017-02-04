classdef Perturbation_t < handle
  
  properties
    id
    amp
    iActive
    unitsToPerturb
    nUnitsToPerturb
    unitArray
  end
  
  methods
    
    % Constructor
    function p = Perturbation_t(id, array, unitsToAffect)
      p.id              = id;
      p.unitArray       = array;
      p.amp             = 0;
      p.iActive         = 0;
      p.unitsToPerturb  = unitsToAffect;
      p.nUnitsToPerturb = length(unitsToAffect);
    end
    
    % Destructor
    function Del(p)
      delete(p);
    end
    
    function ApplyPerturb(p, curIteration)
      if curIteration == p.iActive
        for iUnit = 1 : p.nUnitsToPerturb
          idx = p.unitsToPerturb(iUnit);
          p.unitArray.units(idx).ApplyPerturb(p.amp);
%           p.unitArray.units(idx).unit_input = p.unitArray.units(idx).unit_input + p.amp;
        end
      end
    end
    
    function id = GetUnitsToPerturb(p)
      id = p.UnitsToPerturb;
    end
    
    function SetAmplitude(p, amp)
      p.amp = amp;
    end
    
    function amp = GetAmplitude(p)
      amp = p.amp;
    end
    
    function SetActiveIteration(p, iActive)
      p.iActive = iActive;
    end
    
    function iActive = GetActiveIteration(p)
      iActive = p.iActive;
    end
    
    function IncreaseAmp(p, inc)
      p.amp = p.amp + inc;
    end
    
    function DecreaseAmp(p, dec)
      p.amp = p.amp - dec;
      if p.amp < 0
        p.amp = 0;
      end
    end
    
  end
  
end

