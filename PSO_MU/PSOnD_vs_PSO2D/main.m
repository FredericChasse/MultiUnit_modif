% This is the main file to be used for simulations of PSO

clear all
close all

nIterations = 50;

mfcs = MfcArray_t(2);
mfcs.units(1).s0 = 300;
mfcs.units(2).s0 = 300;
mfcs.integrationTime = .5;

odeOptions = odeset('RelTol',1e-6,'AbsTol',1e-9);

pso = Pso_t(1, 8, 2);

links = PsoToMfcLink_t;
for iParticle = 1 : pso.swarms(1).nParticles
  for iDim = 1 : pso.swarms(1).dimension
    links.AddLink(mfcs.units(iDim).id, pso.swarms(1).id, pso.swarms(1).particles(iParticle).id, iDim);
  end
end

c1 = 1;
c2 = 2;
omega = 0.5;
decimals = 4;
posRes = .1;
posMin = 10;
posMax = 1000;

pso.swarms(1).SetParam(c1, c2, omega, decimals, posRes, posMin, posMax);

pso.swarms(1).RandomizeParticlesPos();

waitBarHandler = waitbar(0);
for iSim = 1 : nIterations
  waitbar(iSim/nIterations)

  for i = 1 : links.nLinks
    unit = mfcs.units(links.mfcId(i));
    particle = pso.swarms(links.swarmId(i)).particles(links.particleId(i));
    unit.rext = particle.pos.curPos(links.dimId(i));

    mfcs.IntegrateMfc(unit.id, odeOptions);

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
      pso.swarms(1).particles(iParticle).ComputePos(pso.swarms(1));
    end
  end
  
end

close(waitBarHandler)
