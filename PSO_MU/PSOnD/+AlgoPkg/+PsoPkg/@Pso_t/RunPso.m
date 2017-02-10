function [ ] = RunPso( pso, iteration )

import AlgoPkg.PsoPkg.*

for iSwarm = 1 : pso.nSwarms
  swarm = pso.swarms(iSwarm);
  swarm.swarmIteration = swarm.swarmIteration + 1;
  
  % Compute the fitness of each unit
  %--------------------------------------------------------------------
  for iParticle = 1 : swarm.nParticles
    p = swarm.particles(iParticle);
    
    % This condition here simulates the parallel evaluation of the units'
    % objective functions
    if iSwarm == 1
      pso.realTimeElapsed = pso.realTimeElapsed + pso.unitEvalTime;
    end
    
    for iDim = 1 : swarm.dimension
      swarm.unitArray.units(iDim).SetPos(p.pos.curPos(iDim));
      swarm.unitArray.EvalUnit(iDim);
      p.SetDimFitness(swarm.unitArray.units(iDim).fitness, iDim);
    end
  end
  %____________________________________________________________________
  
  % Compute pbest and gbest
  %--------------------------------------------------------------------
  for iParticle = 1 : swarm.nParticles
    swarm.particles(iParticle).ComputeOverallFitness;
    swarm.particles(iParticle).ComputePbest;
  end
  swarm.ComputeGbest;
  %____________________________________________________________________

  % Check for steady state
  %--------------------------------------------------------------------
  swarm.steadyState.AddSample(swarm.GetParticlesPos);
  swarm.steadyState.EvaluateSteadyState;
  if swarm.steadyState.oInSteadyState == 1
    swarm.oMoveParticles = 0;
  end
  %____________________________________________________________________

  % SimData
  %--------------------------------------------------------------------
  swarm.simData.AddData ( swarm.GetParticlesSpeed           ...
                        , swarm.GetParticlesPos             ...
                        , swarm.GetParticlesFitness         ...
                        , swarm.GetParticlesFitnessDim      ...
                        , swarm.GetParticlesPbest           ...
                        , swarm.GetGbest                    ...
                        , swarm.steadyState.oInSteadyState  ...
                        , swarm.swarmIteration              ...
                        );
  %____________________________________________________________________

  % Check for perturbations
  %--------------------------------------------------------------------
  particlesPerturbedIdx = swarm.CheckForPerturbation;
  if particlesPerturbedIdx ~= 0 % Perturbation occured
    if swarm.oMoveParticles == 0
      swarm.oResetParticles = 1;
      swarm.oMoveParticles  = 1;
      
      if pso.oMultiSwarm == 1
        unitsPerturbedIdx = swarm.CheckForDimensionalPerturbation(particlesPerturbedIdx);
        if length(unitsPerturbedIdx) ~= swarm.unitArray.nUnits
          [aSplit, aKeep, idxToKeep] = pso.unitArray.SplitArray(unitsPerturbedIdx, pso.nSwarms + 1);

          sSplit = PsoSwarm_t(pso.nSwarms + 1, pso.swarms(1).nParticles, aSplit, PsoSimData_t);
          sKeep  = PsoSwarm_t(pso.nSwarms + 2, pso.swarms(1).nParticles, aKeep , PsoSimData_t);

          sSplit.SetSteadyState([pso.swarms(1).nParticles aSplit.nUnits], pso.swarms(1).steadyState.oscAmp, pso.swarms(1).steadyState.nSamplesForSteadyState);
          sSplit.SetParam(pso.swarms(1).c1, pso.swarms(1).c2, pso.swarms(1).omega, pso.swarms(1).decimals, pso.swarms(1).posRes, pso.swarms(1).posMin, pso.swarms(1).posMax);
          sSplit.RandomizeParticlesPos();

          % Copy parameters from original swarm into the swarm that's not 
          % supposed to move, as we want it to stay put.
          %================================================================
          sKeep.SetSteadyState([pso.swarms(1).nParticles aKeep.nUnits], pso.swarms(1).steadyState.oscAmp, pso.swarms(1).steadyState.nSamplesForSteadyState);
          sKeep.SetParam(pso.swarms(1).c1, pso.swarms(1).c2, pso.swarms(1).omega, pso.swarms(1).decimals, pso.swarms(1).posRes, pso.swarms(1).posMin, pso.swarms(1).posMax);
          sKeep.RandomizeParticlesPos();
          
          for iParticle = 1 : sKeep.nParticles
            pKeep = sKeep.particles(iParticle);
            pOld  = swarm.particles(iParticle);
            
            prevTotalFit = 0;
            totalFit     = 0;
            for iUnit = 1 : sKeep.unitArray.nUnits
              pKeep.pbest.prevPos   (iUnit) = pOld.pbest.prevPos  (idxToKeep(iUnit));
              pKeep.pbest.curPos    (iUnit) = pOld.pbest.curPos   (idxToKeep(iUnit));
              pKeep.pos  .prevPos   (iUnit) = pOld.pos  .prevPos  (idxToKeep(iUnit));
              pKeep.pos  .curPos    (iUnit) = pOld.pos  .curPos   (idxToKeep(iUnit));
              pKeep.prevSpeed       (iUnit) = pOld.prevSpeed      (idxToKeep(iUnit));
              pKeep.curSpeed        (iUnit) = pOld.curSpeed       (idxToKeep(iUnit));
              
              pKeep.prevDimFitness  (iUnit) = pOld.prevDimFitness (idxToKeep(iUnit));
              pKeep.dimFitness      (iUnit) = pOld.dimFitness     (idxToKeep(iUnit));
              
              prevTotalFit = prevTotalFit + pKeep.prevDimFitness(iUnit);
              totalFit     = totalFit     + pKeep.dimFitness    (iUnit);
            end
            pKeep.pos.prevFitness = prevTotalFit;
            pKeep.pos.curFitness  = totalFit;
          end
          
          for iUnit = 1 : sKeep.unitArray.nUnits
            sKeep.gbest.curPos (iUnit) = swarm.gbest.prevPos(iUnit);
          end
          sKeep.ComputeGbest;
          sKeep.gbest.prevFitness = sKeep.gbest.curFitness;
          
          for iUnit = 1 : sKeep.unitArray.nUnits
            sKeep.gbest.prevPos(iUnit) = swarm.gbest.prevPos(iUnit);
            sKeep.gbest.curPos (iUnit) = swarm.gbest.curPos (iUnit);
          end
          sKeep.ComputeGbest;
          
          sKeep.oMoveParticles              = 0;
          sKeep.oResetParticles             = 0;
          sKeep.steadyState.oInSteadyState  = 1;
          
          % Here, we fake that the swarm was at the same position so the
          % steady state variable is not affected
          sKeep.steadyState.AddSample(sKeep.GetParticlesPos);
          for iSample = 1 : swarm.steadyState.nSamplesForSteadyState - 1
            sKeep.steadyState.AddSample(sKeep.GetParticlesPos);
          end
          %================================================================
          
          pso.AddSwarm    (sSplit  );
          pso.AddSwarm    (sKeep   );
          pso.nSimData = pso.nSimData+1;
          pso.simData{pso.nSimData} = {sSplit.simData};
          pso.nSimData = pso.nSimData + 1;
          pso.simData{pso.nSimData} = {sKeep.simData};
          pso.RemoveSwarms(swarm.id);
          
          % Don't do the next part of loop as it's not the same swarm(s)
          % anymore.
          warning('This only works when there are 2 swarms at the end')
          break;
        end
      end
    end
  end
  %____________________________________________________________________
  
  % Compute next positions
  %--------------------------------------------------------------------
  if swarm.oResetParticles == 1
    swarm.oResetParticles = 0;
    for iParticle = 1 : swarm.nParticles
      swarm.RandomizeParticlesPos();
      swarm.particles(iParticle).InitSpeed(swarm);
    end
  else
    if swarm.swarmIteration == 1 && ~swarm.steadyState.oInSteadyState
      for iParticle = 1 : swarm.nParticles
        swarm.particles(iParticle).InitSpeed (swarm);
        swarm.particles(iParticle).ComputePos(swarm);
      end
    else
      for iParticle = 1 : swarm.nParticles
        swarm.particles(iParticle).ComputeSpeed(swarm);
        swarm.particles(iParticle).ComputePos  (swarm);
      end
    end
  end
  %________________________________________________________________________
  
end

end

