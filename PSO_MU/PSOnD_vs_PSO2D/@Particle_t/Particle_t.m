classdef Particle_t < handle
  
  properties
    id
    pbest
    pos
    dimFitness
    curSpeed
    prevSpeed
  end
  
  methods (Access = public)
    
    % Constructor
    function p = Particle_t(id, dim)
      p.id                  = id;
      p.pbest               = Position_t(dim);
      p.pos                 = Position_t(dim);
      p.curSpeed  (1, dim)  = 0;
      p.prevSpeed (1, dim)  = 0;
      p.dimFitness(1, dim)  = 0;
    end
    
    % Destructor
    function Del(p)
      delete(p);
    end
    
    InitSpeed   ( p, s );
    ComputeSpeed( p, s );
    ComputePbest( p    );
    ComputePos  ( p, s );
    
    function SetFitness (p, f)
      p.pos.prevFitness = p.pos.curFitness;
      p.pos.curFitness  = f;
    end
    
    function SetDimFitness(p, f, dim)
      p.dimFitness(dim) = f;
    end
    
    function ComputeOverallFitness(p)
      f = 0;
      for iDim = 1 : length(p.dimFitness)
        f = f + p.dimFitness(iDim);
      end
      SetFitness(p, f);
    end
    
  end
  
end

