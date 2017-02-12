function [ ] = RunParaPso( pso, iteration )

import AlgoPkg.PsoPkg.*

for iSwarm = 1 : pso.nSwarms
  swarm = pso.swarms(iSwarm);
  
  % Compute the fitness of each unit
  %--------------------------------------------------------------------
  for iParticle = 1 : swarm.nParticles
    p = swarm.particles(iParticle);
    swarm.unitArray.units(iParticle).SetPos(p.pos.curPos(1));
    swarm.unitArray.EvalUnit(iParticle);
    p.SetFitness(swarm.unitArray.units(iParticle).fitness);
  end
  %____________________________________________________________________
end

pso.realTimeElapsed = pso.realTimeElapsed + pso.unitEvalTime;

for iSwarm = 1 : pso.nSwarms
  swarm = pso.swarms(iSwarm);
  swarm.swarmIteration = swarm.swarmIteration + 1;
  
  % Compute pbest and gbest
  %--------------------------------------------------------------------
  for iParticle = 1 : swarm.nParticles
    swarm.particles(iParticle).ComputePbest;
  end
  swarm.ComputeGbest;
  %____________________________________________________________________

  % Check for steady state
  %--------------------------------------------------------------------
  if swarm.swarmIteration == 1
    warning('To be adjusted.')
  end
  if swarm.particles(1).state == ParticleState.SEARCHING;
    swarm.steadyState.AddSample(swarm.GetParticlesPos);
    swarm.steadyState.EvaluateSteadyState;
    if swarm.steadyState.oInSteadyState == 1
      swarm.oMoveParticles = 0;

      for iParticle = 1 : swarm.nParticles
        swarm.particles(iParticle).state = ParticleState.PERTURB_INIT;
      end
    end
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
      
%       if pso.psoType == PsoType.PSO_ND_MULTISWARM
%         unitsPerturbedIdx = swarm.CheckForDimensionalPerturbation(particlesPerturbedIdx);
%         if length(unitsPerturbedIdx) ~= swarm.unitArray.nUnits
%           [aSplit, aKeep, idxToKeep] = pso.unitArray.SplitArray(unitsPerturbedIdx, pso.nSwarms + 1);
% 
%           sSplit = PsoSwarm_t(pso.nSwarms + 1, pso.swarms(1).nParticles, aSplit, PsoSimData_t);
%           sKeep  = PsoSwarm_t(pso.nSwarms + 2, pso.swarms(1).nParticles, aKeep , PsoSimData_t);
% 
%           sSplit.SetSteadyState([pso.swarms(1).nParticles aSplit.nUnits], pso.swarms(1).steadyState.oscAmp, pso.swarms(1).steadyState.nSamplesForSteadyState);
%           sSplit.SetParam(pso.swarms(1).c1, pso.swarms(1).c2, pso.swarms(1).omega, pso.swarms(1).decimals, pso.swarms(1).posRes, pso.swarms(1).posMin, pso.swarms(1).posMax);
%           sSplit.RandomizeParticlesPos();
% 
%           % Copy parameters from original swarm into the swarm that's not 
%           % supposed to move, as we want it to stay put.
%           %================================================================
%           sKeep.SetSteadyState([pso.swarms(1).nParticles aKeep.nUnits], pso.swarms(1).steadyState.oscAmp, pso.swarms(1).steadyState.nSamplesForSteadyState);
%           sKeep.SetParam(pso.swarms(1).c1, pso.swarms(1).c2, pso.swarms(1).omega, pso.swarms(1).decimals, pso.swarms(1).posRes, pso.swarms(1).posMin, pso.swarms(1).posMax);
%           sKeep.RandomizeParticlesPos();
%           
%           for iParticle = 1 : sKeep.nParticles
%             pKeep = sKeep.particles(iParticle);
%             pOld  = swarm.particles(iParticle);
%             
%             prevTotalFit = 0;
%             totalFit     = 0;
%             for iUnit = 1 : sKeep.unitArray.nUnits
%               pKeep.pbest.prevPos   (iUnit) = pOld.pbest.prevPos  (idxToKeep(iUnit));
%               pKeep.pbest.curPos    (iUnit) = pOld.pbest.curPos   (idxToKeep(iUnit));
%               pKeep.pos  .prevPos   (iUnit) = pOld.pos  .prevPos  (idxToKeep(iUnit));
%               pKeep.pos  .curPos    (iUnit) = pOld.pos  .curPos   (idxToKeep(iUnit));
%               pKeep.prevSpeed       (iUnit) = pOld.prevSpeed      (idxToKeep(iUnit));
%               pKeep.curSpeed        (iUnit) = pOld.curSpeed       (idxToKeep(iUnit));
%               
%               pKeep.prevDimFitness  (iUnit) = pOld.prevDimFitness (idxToKeep(iUnit));
%               pKeep.dimFitness      (iUnit) = pOld.dimFitness     (idxToKeep(iUnit));
%               
%               prevTotalFit = prevTotalFit + pKeep.prevDimFitness(iUnit);
%               totalFit     = totalFit     + pKeep.dimFitness    (iUnit);
%             end
%             pKeep.pos.prevFitness = prevTotalFit;
%             pKeep.pos.curFitness  = totalFit;
%           end
%           
%           for iUnit = 1 : sKeep.unitArray.nUnits
%             sKeep.gbest.curPos (iUnit) = swarm.gbest.prevPos(iUnit);
%           end
%           sKeep.ComputeGbest;
%           sKeep.gbest.prevFitness = sKeep.gbest.curFitness;
%           
%           for iUnit = 1 : sKeep.unitArray.nUnits
%             sKeep.gbest.prevPos(iUnit) = swarm.gbest.prevPos(iUnit);
%             sKeep.gbest.curPos (iUnit) = swarm.gbest.curPos (iUnit);
%           end
%           sKeep.ComputeGbest;
%           
%           sKeep.oMoveParticles              = 0;
%           sKeep.oResetParticles             = 0;
%           sKeep.steadyState.oInSteadyState  = 1;
%           
%           % Here, we fake that the swarm was at the same position so the
%           % steady state variable is not affected
%           sKeep.steadyState.AddSample(sKeep.GetParticlesPos);
%           for iSample = 1 : swarm.steadyState.nSamplesForSteadyState - 1
%             sKeep.steadyState.AddSample(sKeep.GetParticlesPos);
%           end
%           %================================================================
%           
%           pso.AddSwarm    (sSplit  );
%           pso.AddSwarm    (sKeep   );
%           pso.nSimData = pso.nSimData+1;
%           pso.simData{pso.nSimData} = {sSplit.simData};
%           pso.nSimData = pso.nSimData + 1;
%           pso.simData{pso.nSimData} = {sKeep.simData};
%           pso.RemoveSwarms(swarm.id);
%           
%           % Don't do the next part of loop as it's not the same swarm(s)
%           % anymore.
%           warning('This only works when there are 2 swarms at the end')
%           break;
%         end
%       end
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
    if swarm.swarmIteration == 1 %&& ~swarm.steadyState.oInSteadyState
      for iParticle = 1 : swarm.nParticles
        swarm.particles(iParticle).InitSpeed (swarm);
        swarm.particles(iParticle).ComputePos(swarm);
      end
    else
      idxToRemove = [];
      particlesToRemove = Particle_t.empty;
      newSwarm = PsoSwarm_t(pso.nSwarms, 0, swarm.unitArray, PsoSimData_t, 1);
      for iParticle = 1 : swarm.nParticles
        p = swarm.particles(iParticle);
        switch p.state
          case ParticleState.SEARCHING
            p.ComputeSpeed(swarm);
            p.ComputePos  (swarm);
            
          case ParticleState.PERTURB_INIT
            p.perturbPos.j  = p.pos.curFitness;
            p.perturbPos.d  = p.pos.curPos;
            p.perturbPos.dminus = p.pos.curPos - swarm.perturbAmp;
            p.perturbPos.dpos   = p.pos.curPos + swarm.perturbAmp;
            
            p.pos.prevPos   = p.pos.curPos;
            p.pos.curPos    = p.pos.curPos - swarm.perturbAmp;
            p.prevSpeed     = p.curSpeed;
            p.curSpeed      = -swarm.perturbAmp;
            p.state         = ParticleState.PERTURB_MINUS;
            
          case ParticleState.PERTURB_MINUS
            p.perturbPos.jminus  = p.pos.curFitness;
            
            p.pos.prevPos   = p.pos.curPos;
            p.pos.curPos    = p.perturbPos.dpos;
            p.prevSpeed     = p.curSpeed;
            p.curSpeed      = 2*swarm.perturbAmp;
            p.state         = ParticleState.PERTURB_POS;
            
          case ParticleState.PERTURB_POS
            p.perturbPos.jpos  = p.pos.curFitness;
            
            p.pos.prevPos   = p.pos.curPos;
            p.pos.curPos    = p.perturbPos.d;
            p.prevSpeed     = p.curSpeed;
            p.curSpeed      = -swarm.perturbAmp;
            p.state         = ParticleState.PERTURB_END;
            
          case ParticleState.PERTURB_END
            % If no perturbation has occured
            if p.pos.curFitness == p.perturbPos.j
              % If the final position is an optimum
              if p.perturbPos.jminus < p.pos.curFitness && p.perturbPos.jpos < p.pos.curFitness
                p.state = ParticleState.STEADY_STATE;
                p.ComputeSpeed(swarm);
                p.ComputePos  (swarm);
              else
                p.state = ParticleState.SEARCHING;
                idxToRemove = [idxToRemove p.id]; %#ok<AGROW>
                particlesToRemove = [particlesToRemove p]; %#ok<AGROW>
%                 warning('And then?')
              end
            else % Perturbation has occured
              p.state = ParticleState.SEARCHING;
              idxToRemove = [idxToRemove p.id]; %#ok<AGROW>
              particlesToRemove = [particlesToRemove p]; %#ok<AGROW>
              if swarm.swarmIteration == 1
                warning('And then?')
              end
            end
            
          case ParticleState.STEADY_STATE
            p.ComputeSpeed(swarm);
            p.ComputePos  (swarm);
            
          otherwise
            error('Invalid state!')
        end
      end
      if isempty(idxToRemove)
        newSwarm.Del;
      else
        if length(idxToRemove) ~= swarm.unitArray.nUnits
          swarm.RemoveParticles(idxToRemove);
          for iParticle = 1 : length(idxToRemove);
            newSwarm.AddParticle(particlesToRemove(iParticle));
          end
          
          [aSplit, aKeep, idxToKeep] = pso.unitArray.SplitArray(idxToRemove, pso.nSwarms + 1);
          
          newSwarm.unitArray  = aSplit;
          swarm.unitArray     = aKeep;

          ss = swarm.steadyState;
          swarm.SetSteadyState([swarm.nParticles 1], pso.swarms(1).steadyState.oscAmp, pso.swarms(1).steadyState.nSamplesForSteadyState);
          ss.Del;
          for i = 1 : swarm.steadyState.nSamplesForSteadyState
            swarm.steadyState.AddSample(swarm.GetParticlesPos);
          end
          swarm.steadyState.EvaluateSteadyState;
          if swarm.steadyState.oInSteadyState == 1
            swarm.oMoveParticles = 0;
          end

          newSwarm.SetSteadyState([newSwarm.nParticles 1], pso.swarms(1).steadyState.oscAmp, pso.swarms(1).steadyState.nSamplesForSteadyState);
          newSwarm.SetParam(pso.swarms(1).c1, pso.swarms(1).c2, pso.swarms(1).omega, pso.swarms(1).decimals, pso.swarms(1).posRes, pso.swarms(1).posMin, pso.swarms(1).posMax);
          newSwarm.RandomizeParticlesPos();

          pso.AddSwarm(newSwarm);
          pso.nSimData = pso.nSimData+1;
          pso.simData{pso.nSimData} = {newSwarm.simData};
        else
          swarm.RandomizeParticlesPos();
          swarm.oResetParticles = 0;
          swarm.oMoveParticles  = 1;
        end
      end
    end
  end
  %________________________________________________________________________
  
end

end

