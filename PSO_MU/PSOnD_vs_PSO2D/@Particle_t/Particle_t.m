classdef Particle_t < handle
  
  properties
    id
    pbest
    pos
    curSpeed
    prevSpeed
  end
  
  methods (Access = public)
    
    % Constructor
    function p = Particle_t(id, dim)
      p.id                = id;
      p.pbest             = Position_t(dim);
      p.pos               = Position_t(dim);
      p.curSpeed (1, dim) = 0;
      p.prevSpeed(1, dim) = 0;
    end
    
    % Destructor
    function Del(p)
      delete(p);
    end
    
    ComputeSpeed( p, s );
    ComputePbest( p    );
    ComputePos  ( p, s );
    
  end
  
end

