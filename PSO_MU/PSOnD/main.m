% TBD
%==========================================================================
% Stop when steady-state achieved       DONE
% React to perturbations                DONE
% Implement PSO 1D after nD
% Compare to P&O
% Evaluate MFCs in parallel
%   (mfcModelFastParallel)
% Implement inheritance/polymorphism    DONE
%//////////////////////////////////////////////////////////////////////////


%**************************************************************************
%********************    Main simulation    *******************************
%**************************************************************************

% Setup workspace
%==========================================================================
% if exist('rngState')
%   rng(rngState);
% else
%   rngState = rng;
% end
% clearvars -except rngState
% clear all %#ok<CLSCR>
clear % This will not remove the breakpoints
close all

% Next 2 lines are to close any open waitbar
f = findall(0,'tag','TMWWaitbar');
delete(f);

import SimPkg.*
import SimPkg.UnitPkg.*
import SimPkg.ArrayPkg.*

import AlgoPkg.*
import AlgoPkg.LinkPkg.*
import AlgoPkg.PsoPkg.*
%//////////////////////////////////////////////////////////////////////////


% Simulation environment
%==========================================================================
nIterations = 100;    % Iterations of the main loop

simRealTime = 0;      % Keep track of the "real-time" in days

simData = PsoSimData_t;  % Data structure

wbh = waitbar(0, ['Sim iteration: ' num2str(0)]);  % Waitbar handle
%//////////////////////////////////////////////////////////////////////////


% Unit array
%==========================================================================
nUnits = 2;

mfcType             = 'mfc';
staticFunctionType  = 'static function';

% typeOfUnits = mfcType;
typeOfUnits = staticFunctionType;

if strcmp(typeOfUnits, mfcType)
  InitMfc
elseif strcmp(typeOfUnits, staticFunctionType)
  InitStaticFunc
else
  error('Must define a type of units!');
end
%//////////////////////////////////////////////////////////////////////////


% Algo init
%==========================================================================
psoType = 'pso';

typeOfAlgo = psoType;

if strcmp(typeOfAlgo, psoType)
  InitPso
else
  error('Must define a type of algorithm!');
end
%//////////////////////////////////////////////////////////////////////////


% Perturbations
%==========================================================================
nUnitsToPerturb = array.nUnits/2;
idx = zeros(1, nUnitsToPerturb);
for i = 1 : nUnitsToPerturb
  idx(i) = array.units(i).id;
end
perturb = Perturbation_t(1, array, idx);

if strcmp(typeOfUnits, mfcType)
  perturbAmp = -10;
elseif strcmp(typeOfUnits, staticFunctionType)
  perturbAmp = [10 -3];
else
  error('Must define a type of units!');
end

perturb.SetAmplitude(perturbAmp);
perturb.SetActiveIteration(70);
%//////////////////////////////////////////////////////////////////////////


% Simulation
%==========================================================================
for iSim = 1 : nIterations
  waitbar(iSim/nIterations, wbh, ['Sim iteration: ' num2str(iSim) '/' num2str(nIterations)])
  
  % Run algorithm
  %========================================================================
  algo.RunAlgoIteration(iSim);
  %------------------------------------------------------------------------
  
  % Apply perturbations
  %========================================================================
  perturb.ApplyPerturb(iSim);
  %------------------------------------------------------------------------
end

% For debug purposes
%==========================================================================
simData = pso.swarms(1).simData;
d = simData.FormatToArray(simData.d);
v = simData.FormatToArray(simData.speed);
j = simData.FormatToArray(simData.j);
jSingle = simData.FormatToArray(simData.jSingle);
pbest = simData.FormatToArray(simData.pbest);
gbest = simData.FormatToArray(simData.gbest);
i = simData.FormatToArray(simData.iteration);
ss = simData.FormatToArray(simData.oInSteadyState);
%//////////////////////////////////////////////////////////////////////////

close(wbh)
%//////////////////////////////////////////////////////////////////////////
