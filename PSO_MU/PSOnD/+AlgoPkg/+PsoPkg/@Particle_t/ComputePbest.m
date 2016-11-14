function [  ] = ComputePbest( p )

p.pbest.prevPos       = p.pbest.curPos;
p.pbest.prevFitness   = p.pbest.curFitness;

if p.pos.curFitness   > p.pos.prevFitness
  p.pbest.curPos      = p.pos.curPos;
  p.pbest.curFitness  = p.pos.curFitness;
else
  p.pbest.curPos      = p.pos.prevPos;
  p.pbest.curFitness  = p.pos.prevFitness;
end

end

