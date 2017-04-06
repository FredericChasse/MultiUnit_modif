% psoAlgo       = PsoType.PSO_ND_SINGLE_SWARM;
% psoAlgo       = PsoType.PSO_ND_MULTI_SWARM;
% psoAlgo       = PsoType.PSO_1D;
% psoAlgo       = PsoType.PARALLEL_PSO;
psoAlgo       = PsoType.PARALLEL_PSO_PBEST_ABS;

nParticles    = 3;
psoId         = 1;

if psoAlgo == PsoType.PARALLEL_PSO || psoAlgo == PsoType.PARALLEL_PSO_PBEST_ABS || psoAlgo == PsoType.PSO_1D
  dimension  = 1;
  pso = ParaPso_t(psoId, array, psoAlgo);
elseif psoAlgo == PsoType.PSO_1D
  error('No implementation!')
else
  dimension = array.nUnits;
  pso = Pso_t(psoId, array, psoAlgo);
end

c1        = 1;
c2        = 2;
% c1        = .5;
% c2        = 1;
% c1        = 0.4;
% c2        = 1.1;
omega     = 0.4;
decimals  = 4;
posRes    = 0.1;
if strcmp(typeOfUnits, mfcType)
  posMin    = 10;
  posMax    = 500;
%   posMin    = 70;
%   posMax    = 90;
elseif strcmp(typeOfUnits, staticFunctionType)
%   posMin    = 10;
%   posMax    = 200;
  posMin    = 1;
  posMax    = 1000;
else
  error('Must define a type of units!');
end

ssOscAmp    = 0.01; % Steady-state defined @�1% oscillation
nSamples4ss = 5;   % For that number of iterations

for iSwarm = 1 : pso.nSwarms
  pso.swarms(iSwarm).SetSteadyState([pso.swarms(iSwarm).nParticles dimension], ssOscAmp, nSamples4ss);

  pso.swarms(iSwarm).SetParam(c1, c2, omega, decimals, posRes, posMin, posMax);

  pso.swarms(iSwarm).RandomizeParticlesPos();

  if psoAlgo == PsoType.PARALLEL_PSO_PBEST_ABS || psoAlgo == PsoType.PSO_1D || psoAlgo == PsoType.PARALLEL_PSO
    for iUnit = 1 : pso.swarms(iSwarm).unitArray.nUnits
      pso.swarms(iSwarm).unitArray.units(iUnit).SetPos(pso.swarms(iSwarm).particles(iUnit).pos.curPos);
    end
  end
end

algo = Algo_t(pso);