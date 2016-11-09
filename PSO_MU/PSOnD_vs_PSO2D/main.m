% This is the main file to be used for simulations of PSO

% Init
%==========================================================================
clear all %#ok<CLSCR>
close all
%//////////////////////////////////////////////////////////////////////////


% Simulation parameters
%==========================================================================
nIterations = 50;

simData = SimData_t;
%//////////////////////////////////////////////////////////////////////////


% MFC array
%==========================================================================
nMfcs = 2;
mfcs = MfcArray_t(nMfcs);
for iUnit = 1 : mfcs.nMfcs
  % S0 = 300 => (Ropt, Popt) = (156.0, 0.001793880437409)
  % S0 = 290 => (Ropt, Popt) = (162.2, 0.001743879612695)
  mfcs.units(iUnit).s0 = 300;
end
mfcs.integrationTime = .5;
mfcs.odeOptions = odeset('RelTol',1e-6,'AbsTol',1e-9);
%//////////////////////////////////////////////////////////////////////////


% PSO settings
%==========================================================================
nParticles = 8;
id = 1;
pso = Pso_t(id, nParticles, mfcs.nMfcs);

c1        = 1;
c2        = 2;
omega     = 0.5;
decimals  = 4;
posRes    = 0.1;
posMin    = 10;
posMax    = 1000;

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


% Simulation
%==========================================================================
wbh = waitbar(0);   % Waitbar handle

for iSim = 1 : nIterations
  waitbar(iSim/nIterations)

  for i = 1 : links.nLinks
    unit = mfcs.units(links.mfcId(i));
    particle = pso.swarms(links.swarmId(i)).particles(links.particleId(i));
    
    unit.rext = particle.pos.curPos(links.dimId(i));
    mfcs.EvaluateMfc(unit.id);

    % To be used when a unit is assigned to one of the dimensions of a particle
    particle.SetDimFitness(unit.pout, links.dimId(i)); 
  end

  for iParticle = 1 : pso.swarms(1).nParticles
    pso.swarms(1).particles(iParticle).ComputeOverallFitness;
    pso.swarms(1).particles(iParticle).ComputePbest;
  end

  pso.swarms(1).ComputeGbest;
  
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
  
  swarm = pso.swarms(1);
  simData.AddData ( swarm.GetParticlesSpeed       ...
                  , swarm.GetParticlesPos         ...
                  , swarm.GetParticlesFitness     ...
                  , swarm.GetParticlesFitnessDim  ...
                  , swarm.GetParticlesPbest       ...
                  , swarm.GetGbest                ...
                  , iSim                          ...
                  );
  
end

close(wbh)
%//////////////////////////////////////////////////////////////////////////
