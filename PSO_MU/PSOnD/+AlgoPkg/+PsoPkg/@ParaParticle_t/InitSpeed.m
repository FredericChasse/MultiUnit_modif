function [] = InitSpeed( p, s )
p.optPos.d      = 0;
p.optPos.j      = 0;
p.optPos.dminus = 0;
p.optPos.dpos   = 0;
p.optPos.jminus = 0;
p.optPos.jpos   = 0;

randValues = rand(1, 2);
p.prevSpeed = p.curSpeed;
p.curSpeed  = round                                                   ...
            ( rand                                                    ...
            + s.omega * p.prevSpeed                                   ...
            + s.c1 * randValues(1) * (p.pbest.curPos - p.pos.curPos)  ...
            + s.c2 * randValues(2) * (s.gbest.curPos - p.pos.curPos)  ...
            , s.decimals);

end

