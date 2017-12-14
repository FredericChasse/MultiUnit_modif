import SimPkg.*
import SimPkg.UnitPkg.*
import SimPkg.ArrayPkg.*

import AlgoPkg.*
import AlgoPkg.PsoPnoPkg.*

nParticles    = 3;
psoId         = 1;

pso = PsoPno_t(psoId, array);

c1        = 0.5;
c2        = 1.2;
omega     = 0.3;
% c1        = 0.8;
% c2        = 1.4;
% omega     = 0.3;
decimals  = 4;
posRes    = 0.1;
if strcmp(typeOfUnits, mfcType)
  posMin    = 10;
  posMax    = 350;
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

ssOscAmp    = 0.01; % Steady-state defined @±1% oscillation
nSamples4ss = 5;   % For that number of iterations
margin = .03;

pso.paraSwarms(1).SetSteadyState([pso.paraSwarms(1).nParticles 1], ssOscAmp, nSamples4ss);
pso.paraSwarms(1).SetParam(c1, c2, omega, decimals, posRes, posMin, posMax, margin);
pso.paraSwarms(1).RandomizeParticlesPos();

for iUnit = 1 : pso.paraSwarms(1).unitArray.nUnits
  pso.paraSwarms(1).unitArray.units(iUnit).SetPos(pso.paraSwarms(1).particles(iUnit).pos.curPos);
end

algo = Algo_t(pso);