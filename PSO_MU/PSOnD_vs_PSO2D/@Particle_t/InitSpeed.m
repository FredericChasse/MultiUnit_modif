function [] = InitSpeed( p, s )
randValues = rand(s.dimension, 2);
for iDim = 1 : s.dimension
  p.prevSpeed(iDim) = p.curSpeed(iDim);
  p.curSpeed (iDim) = round                                                                     ...
                    ( rand                                                                      ...
                    + s.omega * p.prevSpeed(iDim)                                               ...
                    + s.c1 * randValues(iDim, 1) * (p.pbest.curPos(iDim) - p.pos.curPos(iDim))  ...
                    + s.c2 * randValues(iDim, 2) * (s.gbest.curPos(iDim) - p.pos.curPos(iDim))  ...
                    , s.decimals);
end

end

