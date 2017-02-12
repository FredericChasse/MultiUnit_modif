function [  ] = RandomizeParticlesPos( s )

for iParticle = 1 : s.nParticles
  p = s.particles(iParticle);
  
  p.pos.prevPos = s.particles(iParticle).pos.curPos;
  p.pos.curPos = rand(1, 1) * (s.posMax - s.posMin) + s.posMin;
  
  residue = mod(p.pos.curPos, s.posRes);
  if residue < s.posRes / 2
    p.pos.curPos = p.pos.curPos - residue;
  else
    p.pos.curPos = p.pos.curPos - residue + s.posRes;
  end

  if p.pos.curPos > s.posMax
   p.pos.curPos = s.posMax;
  elseif p.pos.curPos < s.posMin
    p.pos.curPos = s.posMin;
  end
end

end

