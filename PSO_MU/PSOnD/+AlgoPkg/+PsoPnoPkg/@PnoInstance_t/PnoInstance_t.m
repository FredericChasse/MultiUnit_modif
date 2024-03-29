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
    margin
    j
    u
    steadyState
    simData
    pbestAbs
    valPos1
    valPos2
    valPos3
    valPosMem
    deltaVal
    
    oFirstSteadyState
    oLastPos
    diversityMaxCount
    diversityCount
    deltaMem
    oInValMode
  end

  methods

    % Constructor
    function pnoi = PnoInstance_t(id, simData)
      import AlgoPkg.PsoPnoPkg.*
      import AlgoPkg.Position_t
      
      pnoi.id           = id;
      pnoi.k            = 1;
      pnoi.delta        = 1;
      pnoi.umin         = 1;
      pnoi.umax         = 1000;
      pnoi.uInit        = 0;
      pnoi.margin       = 0;
      pnoi.j            = [0 0];
      pnoi.u            = [0 0];
      pnoi.steadyState  = SteadyStatePno_t.empty;
      pnoi.oFirstSteadyState = 1;
      pnoi.oLastPos     = 0;
      pnoi.pbestAbs     = Position_t(1);
      pnoi.diversityCount = 0;
      pnoi.diversityMaxCount = 10;
      pnoi.deltaMem = 0;
      
      pnoi.valPos1.d = 0;
      pnoi.valPos1.j = 0;
      pnoi.valPos2.d = 0;
      pnoi.valPos2.j = 0;
      pnoi.valPos3.d = 0;
      pnoi.valPos3.j = 0;
      pnoi.valPosMem = 0;
      pnoi.deltaVal = 3;
      pnoi.oInValMode = 0;

      pnoi.simData      = simData;
    end

    % Destructor
    function Del(pnoi)
      delete(pnoi);
    end

    % Set all parameters of instance
    function SetInstanceParameters(pnoi, delta, umin, umax, uInit, margin)
      pnoi.delta  = delta;
      pnoi.umin 	= umin;
      pnoi.umax   = umax;
      pnoi.u(2)   = uInit;
      pnoi.uInit  = uInit;
      pnoi.margin = margin;
      pnoi.pbestAbs.curPos = uInit;
      pnoi.pbestAbs.prevPos = uInit;
    end
    
    % Set steady state settings
    %======================================================================
    function SetSteadyState(pnoi, oscAmp, nSamples)
      import AlgoPkg.PsoPnoPkg.*;
      pnoi.steadyState = SteadyStatePno_t(1, oscAmp, nSamples, pnoi.delta);
    end
    %//////////////////////////////////////////////////////////////////////
    
  end
    
end

