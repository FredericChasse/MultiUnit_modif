function [] = ComputeSpeed( p, s )
if s.oMoveParticles == 1
  randValues = rand(s.dimension, 2);
  for iDim = 1 : s.dimension
    p.prevSpeed(iDim) = p.curSpeed(iDim);
    p.curSpeed (iDim) = round                                                                     ...
                      ( s.omega * p.prevSpeed(iDim)                                               ...
                      + s.c1 * randValues(iDim, 1) * (p.pbest.curPos(iDim) - p.pos.curPos(iDim))  ...
                      + s.c2 * randValues(iDim, 2) * (s.gbest.curPos(iDim) - p.pos.curPos(iDim))  ...
                      , s.decimals);
%     if p.curSpeed(iDim) > 350
%       p.curSpeed(iDim) = 350;
%     elseif p.curSpeed(iDim) < -350
%       p.curSpeed(iDim) = -350;
%     end
  end
else
  for iDim = 1 : s.dimension
    p.prevSpeed(iDim) = p.curSpeed(iDim);
    p.curSpeed (iDim) = 0;
  end
end
end

