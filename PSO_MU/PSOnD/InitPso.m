% psoAlgo       = PsoType.PSO_ND_SINGLE_SWARM;
% psoAlgo       = PsoType.PSO_ND_MULTI_SWARM;
% psoAlgo       = PsoType.PSO_1D;
psoAlgo       = PsoType.PARALLEL_PSO;

nParticles = 3;
psoId         = 1;

if psoAlgo == PsoType.PARALLEL_PSO 
  dimension  = 1;
  nParticles = array.nUnits;
elseif psoAlgo == PsoType.PSO_1D
  dimension  = 1;
else
  dimension = array.nUnits;
end

pso = Pso_t(psoId, nParticles, array, psoAlgo);

c1        = 1;
c2        = 2;
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
pso.swarms(1).SetSteadyState([nParticles dimension], ssOscAmp, nSamples4ss);

pso.swarms(1).SetParam(c1, c2, omega, decimals, posRes, posMin, posMax);

pso.swarms(1).RandomizeParticlesPos();

algo = Algo_t(pso);