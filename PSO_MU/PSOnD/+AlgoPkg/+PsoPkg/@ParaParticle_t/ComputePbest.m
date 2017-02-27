function [  ] = ComputePbest( p )
import AlgoPkg.PsoPkg.*

p.pbest.prevPos       = p.pbest.curPos;
p.pbest.prevFitness   = p.pbest.curFitness;

if p.pos.curFitness   > p.pos.prevFitness
  p.pbest.curPos      = p.pos.curPos;
  p.pbest.curFitness  = p.pos.curFitness;
else
  p.pbest.curPos      = p.pos.prevPos;
  p.pbest.curFitness  = p.pos.prevFitness;
end

if p.state ~= ParticleState.VALIDATE_OPTIMUM
  if p.pbest.curFitness > p.pbestAbs.fitness
    p.pbestAbs.pos      = p.pbest.curPos;
    p.pbestAbs.fitness  = p.pbest.curFitness;
  end
end

end

