function [  ] = RandomizeParticlesPos( s )

for iParticle = 1 : s.nParticles
  p = s.particles(iParticle);
  
  p.pos.prevPos = s.particles(iParticle).pos.curPos;
  p.pos.curPos = rand(1, s.dimension) * (s.posMax - s.posMin) + s.posMin;
  
  for iDim = 1 : s.dimension
    residue = mod(p.pos.curPos(iDim), s.posRes);
    if residue < s.posRes / 2
      p.pos.curPos(iDim) = p.pos.curPos(iDim) - residue;
    else
      p.pos.curPos(iDim) = p.pos.curPos(iDim) - residue + s.posRes;
    end
    
    if p.pos.curPos(iDim) > s.posMax
     p.pos.curPos(iDim) = s.posMax;
    elseif p.pos.curPos(iDim) < s.posMin
      p.pos.curPos(iDim) = s.posMin;
    end
  end
end

end

