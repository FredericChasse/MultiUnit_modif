function [  ] = RandomizeParticlesPos( s )

for iParticle = 1 : s.nParticles
  s.particles(iParticle).pos.prevPos = s.particles(iParticle).pos.curPos;
%   s.particles(iParticle).pos.prevFitness = s.particles(iParticle).pos.curFitness;
  s.particles(iParticle).pos.curPos = rand(1, s.dimension) * (s.posMax - s.posMin) + s.posMin;
  
  for iDim = 1 : s.dimension
    if s.particles(iParticle).pos.curPos(iDim) > s.posMax
      s.particles(iParticle).pos.curPos(iDim) = s.posMax;
    elseif s.particles(iParticle).pos.curPos(iDim) < s.posMin
      s.particles(iParticle).pos.curPos(iDim) = s.posMin;
    end
  end
end

end

