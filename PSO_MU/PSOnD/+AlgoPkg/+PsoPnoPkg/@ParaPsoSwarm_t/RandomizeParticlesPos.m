function [  ] = RandomizeParticlesPos( s )
range         = s.posMax - s.posMin;
sectionLength = range / s.nParticles;
sections      = zeros(s.nParticles + 1, 1);
sections(1)   = s.posMin;
sections(end) = s.posMax;
for i = 2 : s.nParticles
  sections(i) = sectionLength * (i - 1);
end

for iParticle = 1 : s.nParticles
  p = s.particles(iParticle);
  
  p.pos.prevPos = s.particles(iParticle).pos.curPos;
%   p.pos.curPos = rand(1, 1) * (s.posMax - s.posMin) + s.posMin;
  p.pos.curPos = rand(1, 1) * sectionLength + sections(iParticle);
  
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
  
  p.pbest.curFitness  = 0;
  p.pbestAbs.fitness  = 0;
end

end

