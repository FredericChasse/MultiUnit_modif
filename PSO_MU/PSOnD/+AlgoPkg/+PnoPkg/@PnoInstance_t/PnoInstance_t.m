classdef PnoInstance_t < handle
  %PNOINSTANCE_T Summary of this class goes here
  %   Detailed explanation goes here

  properties
    id
    k
    delta
    umin
    umax
    uInit
    j
    u
    simData
  end

  methods

    % Constructor
    function pnoi = PnoInstance_t(id, simData)
      pnoi.id     = id;
      pnoi.k      = 1;
      pnoi.delta  = 1;
      pnoi.umin   = 1;
      pnoi.umax   = 1000;
      pnoi.uInit  = 0;
      pnoi.j      = [0 0];
      pnoi.u      = 0;

      pnoi.simData   = simData;
    end

    % Destructor
    function Del(pnoi)
      delete(pnoi);
    end

    % Set all parameters of instance
    function SetInstanceParameters(pnoi, delta, umin, umax, uInit)
      pnoi.delta  = delta;
      pnoi.umin 	= umin;
      pnoi.umax   = umax;
      pnoi.u      = uInit;
      pnoi.uInit  = uInit;
    end
    
  end
    
end

