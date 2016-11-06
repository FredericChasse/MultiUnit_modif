function [  ] = ComputePos( p, s )

p.pos.prevFitness = p.pos.curFitness;

for iDim = 1 : s.dim
  p.pos.prevPos(iDim) = p.pos.curPos(iDim);
  p.pos.curPos(iDim) = p.prevPos(iDim) + p.curSpeed(iDim);
  
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

