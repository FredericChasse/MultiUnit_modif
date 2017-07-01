function [] = InitPos( p, s )
  p.pos.prevPos = p.pos.curPos;
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
  
  p.pbest.curFitness = 0;
  p.pbestAbs.fitness = 0;
end

