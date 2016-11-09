function [] = ComputeGbest( s )

units = zeros(1, s.nParticles);

for iParticle = 1 : s.nParticles
  units(iParticle) = s.particles(iParticle).pos.curFitness;
end

idx = find(units == max(units), 1);

s.gbest.prevPos = s.gbest.curPos;
s.gbest.prevFitness = s.gbest.curFitness;
s.gbest.curPos = s.particles(idx).pos.curPos;
s.gbest.curFitness = s.particles(idx).pos.curFitness;

end

