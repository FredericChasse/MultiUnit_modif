% TBD
%==========================================================================
% Stop when steady-state achieved       DONE
% React to perturbations                DONE
% Implement PSO 1D after nD
% Compare to P&O
% Evaluate MFCs in parallel (mfcModelFastParallel)
% Implement inheritance/polymorphism
%//////////////////////////////////////////////////////////////////////////


%**************************************************************************
%************************    Simulation    ********************************
%**************************************************************************

% Init
%==========================================================================
% if exist('rngState')
%   rng(rngState);
% else
%   rngState = rng;
% end
% clearvars -except rngState
clear all %#ok<CLSCR>
close all
%//////////////////////////////////////////////////////////////////////////


% Simulation environment
%==========================================================================
nIterations = 100;    % Iterations of the main loop

simRealTime = 0;      % Keep track of the "real-time" in days

simData = SimData_t;  % Data structure

wbh = waitbar(0, 'Sim iteration: 0');  % Waitbar handle
%//////////////////////////////////////////////////////////////////////////


% MFC array
%==========================================================================
nMfcs = 10;
mfcs = MfcArray_t(nMfcs);
for iUnit = 1 : mfcs.nUnits
  % S0 = 300 => (Ropt, Popt) = (156.0, 0.001793880437409)
  % S0 = 290 => (Ropt, Popt) = (162.2, 0.001743879612695)
  mfcs.units(iUnit).s0 = 300;
end
mfcs.integrationTime = 0.8;
mfcs.odeOptions = odeset('RelTol',1e-6,'AbsTol',1e-9);
%//////////////////////////////////////////////////////////////////////////


% PSO settings
%==========================================================================
nParticles = 8;
nSwarms = 1;
dimension = mfcs.nUnits;
pso = Pso_t(nSwarms, nParticles, dimension);

c1        = .8;
c2        = 1.5;
% c1        = .86;
% c2        = 1.7;
omega     = 0.4;
decimals  = 4;
posRes    = 0.1;
posMin    = 10;
% posMin    = 130;
% posMax    = 160;
posMax    = 1000;

ssOscAmp    = 0.01; % Steady-state defined @±1% oscillation
nSamples4ss = 10;   % For that number of iterations
pso.swarms(1).SetSteadyState([nParticles dimension], ssOscAmp, nSamples4ss);

pso.swarms(1).SetParam(c1, c2, omega, decimals, posRes, posMin, posMax);

pso.swarms(1).RandomizeParticlesPos();
%//////////////////////////////////////////////////////////////////////////


% Linking PSO's particles to MFC array
%==========================================================================
links = PsoToMfcLink_t;
for iParticle = 1 : pso.swarms(1).nParticles
  for iDim = 1 : pso.swarms(1).dimension
    links.AddLink (mfcs.units(iDim).id                    ...
                  ,pso.swarms(1).id                       ...
                  ,pso.swarms(1).particles(iParticle).id  ...
                  ,iDim                                   ...
                  );
  end
end
%//////////////////////////////////////////////////////////////////////////


% Perturbations
%==========================================================================
idx = zeros(1, mfcs.nUnits);
for i = 1 : mfcs.nUnits
  idx(i) = mfcs.units(i).id;
end
s0Perturb = Perturbation_t(1, mfcs, idx);
% s0Perturb.SetAmplitude(-10);
% s0Perturb.SetActiveIteration(40);
s0Perturb.SetAmplitude(0);
s0Perturb.SetActiveIteration(0);
%//////////////////////////////////////////////////////////////////////////


% Simulation
%==========================================================================
for iSim = 1 : nIterations
  waitbar(iSim/nIterations, wbh, ['Sim iteration: ' num2str(iSim) '/' num2str(nIterations)])
  
  % Apply perturbations
  %========================================================================
  s0Perturb.ApplyPerturb(iSim);
  %------------------------------------------------------------------------

  % Evaluate objective functions
  %========================================================================
  for i = 1 : links.nLinks
    unit = mfcs.units(links.mfcId(i));
    particle = pso.swarms(links.swarmId(i)).particles(links.particleId(i));
    
    unit.rext = particle.pos.curPos(links.dimId(i));
    timeElapsed = mfcs.EvaluateMfc(unit.id);
    simRealTime = simRealTime + timeElapsed;

    % To be used when a unit is assigned to one of the dimensions of a particle
    particle.SetDimFitness(unit.pout, links.dimId(i)); 
  end
  %------------------------------------------------------------------------

  % Compute pbest and gbest
  %========================================================================
  for iParticle = 1 : pso.swarms(1).nParticles
    pso.swarms(1).particles(iParticle).ComputeOverallFitness;
    pso.swarms(1).particles(iParticle).ComputePbest;
  end

  pso.swarms(1).ComputeGbest;
  %------------------------------------------------------------------------
  
  % Check for steadyState
  %========================================================================
  pso.swarms(1).steadyState.AddSample(pso.swarms(1).GetParticlesPos);
  oSteadyState = pso.swarms(1).steadyState.EvaluateSteadyState;
  if oSteadyState == 1
    pso.swarms(1).oMoveParticles = 0;
    
    % Compute gamma and beta
    %**********************************************************************
    meanPos = zeros(1,mfcs.nUnits);
    meanFit = zeros(1,mfcs.nUnits);
    mfcIds  = zeros(1,mfcs.nUnits);
    for iLink = 1 : links.nLinks
      meanPos(links.mfcId(iLink)) = meanPos   (links.mfcId      (iLink))  ...
                                  + pso.swarms(links.swarmId    (iLink))  ...
                                   .particles (links.particleId (iLink))  ...
                                   .pos.curPos(links.dimId      (iLink))  ...
                                  ;
      meanFit(links.mfcId(iLink)) = meanFit   (links.mfcId      (iLink))  ...
                                  + pso.swarms(links.swarmId    (iLink))  ...
                                   .particles (links.particleId (iLink))  ...
                                   .dimFitness(links.dimId      (iLink))  ...
                                  ;
      mfcIds(links.mfcId(iLink))  = mfcs.units(links.mfcId(iLink)).id;
    end
    meanPos = meanPos ./ pso.swarms(1).nParticles;
    meanFit = meanFit ./ pso.swarms(1).nParticles;
    mfcs.ComputeBetaGamma(mfcIds, meanPos, meanFit);
    %**********************************************************************
  else
    pso.swarms(1).oMoveParticles = 1;
  end
  %------------------------------------------------------------------------
  
  % Check for perturbations
  %========================================================================
  particlesPerturbed = pso.swarms(1).CheckForPerturbation;
  if particlesPerturbed ~= 0 % Perturbation occured
    if pso.swarms(1).oMoveParticles == 0
      pso.swarms(1).oResetParticles = 1;
      pso.swarms(1).oMoveParticles  = 1;
    end
  end
  %------------------------------------------------------------------------
  
  % Save iteration data to data structure
  %========================================================================
  swarm = pso.swarms(1);
  simData.AddData ( swarm.GetParticlesSpeed           ...
                  , swarm.GetParticlesPos             ...
                  , swarm.GetParticlesFitness         ...
                  , swarm.GetParticlesFitnessDim      ...
                  , swarm.GetParticlesPbest           ...
                  , swarm.GetGbest                    ...
                  , simRealTime                       ...
                  , swarm.steadyState.oInSteadyState  ...
                  , iSim                              ...
                  );
  %------------------------------------------------------------------------
  
  % Compute next positions
  %========================================================================
  if pso.swarms(1).oResetParticles == 1
    pso.swarms(1).oResetParticles = 0;
    for iParticle = 1 : pso.swarms(1).nParticles
      pso.swarms(1).RandomizeParticlesPos();
      pso.swarms(1).particles(iParticle).InitSpeed (pso.swarms(1));
    end
  else
    if iSim == 1
      for iParticle = 1 : pso.swarms(1).nParticles
        pso.swarms(1).particles(iParticle).InitSpeed (pso.swarms(1));
        pso.swarms(1).particles(iParticle).ComputePos(pso.swarms(1));
      end
    else
      for iParticle = 1 : pso.swarms(1).nParticles
        pso.swarms(1).particles(iParticle).ComputeSpeed(pso.swarms(1));
        pso.swarms(1).particles(iParticle).ComputePos  (pso.swarms(1));
      end
    end
  end
  %------------------------------------------------------------------------
end

% For debug purposes
%==========================================================================
d = simData.FormatToArray(simData.d);
v = simData.FormatToArray(simData.speed);
j = simData.FormatToArray(simData.j);
jSingle = simData.FormatToArray(simData.jSingle);
pbest = simData.FormatToArray(simData.pbest);
gbest = simData.FormatToArray(simData.gbest);
i = simData.FormatToArray(simData.iteration);
ss = simData.FormatToArray(simData.oInSteadyState);
tt = simData.FormatToArray(simData.timeElapsed);
%//////////////////////////////////////////////////////////////////////////

close(wbh)
%//////////////////////////////////////////////////////////////////////////
