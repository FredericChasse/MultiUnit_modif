function [  ] = RunExtSeek( es, iteration )

es.realTimeElapsed = es.realTimeElapsed + es.unitEvalTime;

for i = 1 : es.nInstances
  esi = es.instances(i);
  simData = esi.simData;
  
  % Compute the fitness of the unit
  %--------------------------------------------------------------------
  es.unitArray.units(i).SetPos(esi.d);
  es.unitArray.EvalUnit(i);
  esi.j(1) = esi.j(2);
  esi.j(2) = es.unitArray.units(i).fitness;
  if iteration == 1
    esi.j(1) = esi.j(2);
  end
  %--------------------------------------------------------------------
  
  esi.hpfOutput(1) = esi.hpfOutput(2);
  esi.hpfOutput(2) = es.HpfZ(esi.j(2), esi.j(1), esi.hpfOutput(1), es.unitEvalTime, esi.wh);
  
  perturb = esi.ap * sin(esi.wp*es.realTimeElapsed);
  
  esi.lpfInput(1) = esi.lpfInput(2);
  esi.lpfInput(2) = perturb * esi.hpfOutput(2);
  
  esi.lpfOutput(1) = esi.lpfOutput(2);
  esi.lpfOutput(2) = es.LpfZ(esi.lpfInput(2), esi.lpfInput(1), esi.lpfOutput(1), es.unitEvalTime, esi.wl);
  
  esi.grad(1) = esi.grad(2);
  esi.grad(2) = es.TustinZ(esi.lpfOutput(2), esi.lpfOutput(1), esi.grad(1), es.unitEvalTime);
  
%   dmem(i) = esi.d;
%   jmem(i) = esi.j(2);
  
  simData.AddData(esi.d, esi.j(2), iteration);
  
  esi.d = esi.grad(2)*esi.k + perturb;
end

% es.simData{1}{1}.AddData(dmem, jmem, iteration);