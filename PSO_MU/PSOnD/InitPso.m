nParticles  = 8;
psoId       = 1;
dimension   = array.nUnits;
oMultiSwarm = 1;
pso = Pso_t(psoId, nParticles, array, oMultiSwarm);

c1        = 1;
c2        = 2;
omega     = 0.4;
decimals  = 4;
posRes    = 0.1;
if strcmp(typeOfUnits, mfcType)
  posMin    = 10;
  posMax    = 500;
elseif strcmp(typeOfUnits, staticFunctionType)
%   posMin    = 10;
%   posMax    = 200;
  posMin    = 1;
  posMax    = 1000;
else
  error('Must define a type of units!');
end

ssOscAmp    = 0.01; % Steady-state defined @±1% oscillation
nSamples4ss = 10;   % For that number of iterations
pso.swarms(1).SetSteadyState([nParticles dimension], ssOscAmp, nSamples4ss);

pso.swarms(1).SetParam(c1, c2, omega, decimals, posRes, posMin, posMax);

pso.swarms(1).RandomizeParticlesPos();

algo = Algo_t(pso);