function [  ] = SetParticlesInitState( s )

for iParticle = 1 : s.nParticles
  s.particles(iParticle).pos.prevPos = 0;
  s.particles(iParticle).pos.curFitness = 0;
  s.particles(iParticle).pos.prevFitness = 0;
  s.particles(iParticle).pos.curPos = rand(1, s.dimension) * (s.posMax - s.posMin) + s.posMin;
  
  for iDim = 1 : s.dimension
    if s.particles(iParticle).pos.curPos(iDim) > s.posMax
      s.particles(iParticle).pos.curPos(iDim) = s.posMax;
    elseif s.particles(iParticle).pos.curPos(iDim) < s.posMin
      s.particles(iParticle).pos.curPos(iDim) = s.posMin;
    end
  end
  
  s.particles(iParticle).pbest = s.particles(iParticle).pos;
end

end

