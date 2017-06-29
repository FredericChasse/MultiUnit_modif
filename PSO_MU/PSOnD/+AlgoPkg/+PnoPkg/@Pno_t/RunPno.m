function [ ] = RunPno( pno, iteration )
%RUNPNO Summary of this function goes here
%   Detailed explanation goes here

% import SimPkg.PnoPkg.*

pno.realTimeElapsed = pno.realTimeElapsed + pno.unitEvalTime;

for i = 1 : pno.nInstances
  pnoi = pno.instances(i);
  simData = pnoi.simData;
  
  % Compute the fitness of the unit
  %--------------------------------------------------------------------
  pno.unitArray.units(i).SetPos(pnoi.u);
  pno.unitArray.EvalUnit(i);
  pnoi.j(1) = pnoi.j(2);
  pnoi.j(2) = pno.unitArray.units(i).fitness;
  if iteration == 1
    pnoi.j(1) = pnoi.j(2);
  end
  %--------------------------------------------------------------------
 
  if pnoi.j(1) > pnoi.j(2)  % If we were better before
    pnoi.k = -pnoi.k;       % Go the other way
  end
  
  simData.AddData(pnoi.u, pnoi.j(2), iteration);
  
  pnoi.u = pnoi.u + pnoi.delta*pnoi.k;
  if pnoi.u < pnoi.umin
    pnoi.u = pnoi.umin;
  elseif pnoi.u > pnoi.umax
    pnoi.u = pnoi.umax;
  end
end
