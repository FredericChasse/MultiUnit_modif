function [] = ComputeSpeed( p, s )
p.ResetOptPos;

% if s.oMoveParticles == 1
if s.swarmIteration == 1
  p.InitSpeed(s);
else
  randValues = rand(1, 2);
  p.prevSpeed = p.curSpeed;
  p.curSpeed  = round                                                   ...
              ( s.omega * p.prevSpeed                                   ...
              + s.c1 * randValues(1) * (p.pbest.curPos - p.pos.curPos)  ...
              + s.c2 * randValues(2) * (s.gbest.curPos - p.pos.curPos)  ...
              , s.decimals);
% else
%   p.prevSpeed = p.curSpeed;
%   p.curSpeed  = 0;
end
end