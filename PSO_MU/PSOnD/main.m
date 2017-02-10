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
% clearvars -except rngState

if ~exist('rngState', 'var')
  rngState = rng;
end

rng(rngState);

% Next 2 lines are to close any open waitbar
f = findall(0,'tag','TMWWaitbar');
delete(f);

import SimPkg.*
import SimPkg.UnitPkg.*
import SimPkg.ArrayPkg.*

import AlgoPkg.*
import AlgoPkg.LinkPkg.*
import AlgoPkg.PsoPkg.*
import AlgoPkg.ExtSeekPkg.*
%//////////////////////////////////////////////////////////////////////////


% Simulation environment
%==========================================================================

% Type of unit
%-------------------------------------------
mfcType             = 'mfc';
staticFunctionType  = 'static function';

typeOfUnits = mfcType;
% typeOfUnits = staticFunctionType;
%-------------------------------------------

% Type of algo
%-------------------------------------------
psoType = 'pso';
extremumSeekType = 'extSeek';
% typeOfAlgo = psoType;
typeOfAlgo = extremumSeekType;
%-------------------------------------------

if strcmp(typeOfAlgo, psoType)
  nIterations = 200;
elseif strcmp(typeOfAlgo, extremumSeekType)
  if strcmp(typeOfUnits, mfcType)
    nIterations = 10000;
  elseif strcmp(typeOfUnits, staticFunctionType)
    nIterations = 1000;
  else
    error('Must define a type of units!');
  end
else
  error('Must define a type of algorithm!');
end

wbh = waitbar(0, ['Sim : ' num2str(0) '/' num2str(nIterations)]);  % Waitbar handle
%//////////////////////////////////////////////////////////////////////////


% Unit array
%==========================================================================
nUnits = 1;

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

if strcmp(typeOfAlgo, psoType)
  InitPso
elseif strcmp(typeOfAlgo, extremumSeekType)
  InitExtremumSeeking
else
  error('Must define a type of algorithm!');
end
%//////////////////////////////////////////////////////////////////////////


% Perturbations
%==========================================================================
oDoPerturb = 0;

nPerturbToApply = 1;

for iPerturb = 1 : nPerturbToApply
  if array.nUnits == 1
    nUnitsToPerturb = 1;
  else
    nUnitsToPerturb = array.nUnits/2;
  end
  idx = zeros(1, nUnitsToPerturb);
  for i = 1 : nUnitsToPerturb
    idx(i) = array.units(i).id;
  end
  perturb(iPerturb) = Perturbation_t(1, array, idx, oDoPerturb); %#ok<SAGROW>

  if strcmp(typeOfUnits, mfcType)
    perturbAmp = -10;
    perturbIteration = 4000;
  elseif strcmp(typeOfUnits, staticFunctionType)
    perturbAmp = [30 -3];
    perturbIteration = 100;
  else
    error('Must define a type of units!');
  end

  perturb(iPerturb).SetAmplitude(perturbAmp);
  perturb(iPerturb).SetActiveIteration(1500);
end
%//////////////////////////////////////////////////////////////////////////


% Simulation
%==========================================================================
for iSim = 1 : nIterations
  if mod(iSim, 50) == 0
    waitbar(iSim/nIterations, wbh, ['Sim iteration: ' num2str(iSim) '/' num2str(nIterations)])
  end
  
  % Run algorithm
  %========================================================================
  algo.RunAlgoIteration(iSim);
  %------------------------------------------------------------------------
  
  % Apply perturbations
  %========================================================================
  for iPerturb = 1 : nPerturbToApply
    perturb(iPerturb).ApplyPerturb(iSim);
  end
  %------------------------------------------------------------------------
end

% For debug purposes
%==========================================================================
for iSimData = 1 : algo.nSimData
  simData = algo.simData{iSimData}{1};
  eval(['d'       num2str(iSimData) ' = simData.FormatToArray(simData.d);'              ]);
  eval(['j'       num2str(iSimData) ' = simData.FormatToArray(simData.j);'              ]);
  eval(['i'       num2str(iSimData) ' = simData.FormatToArray(simData.iteration);'      ]);
  if strcmp(typeOfAlgo, psoType)
    eval(['v'       num2str(iSimData) ' = simData.FormatToArray(simData.speed);'          ]);
    eval(['jSingle' num2str(iSimData) ' = simData.FormatToArray(simData.jSingle);'        ]);
    eval(['pbest'   num2str(iSimData) ' = simData.FormatToArray(simData.pbest);'          ]);
    eval(['gbest'   num2str(iSimData) ' = simData.FormatToArray(simData.gbest);'          ]);
    eval(['ss'      num2str(iSimData) ' = simData.FormatToArray(simData.oInSteadyState);' ]);
  end
%   d = simData.FormatToArray(simData.d);
%   v = simData.FormatToArray(simData.speed);
%   j = simData.FormatToArray(simData.j);
%   jSingle = simData.FormatToArray(simData.jSingle);
%   pbest = simData.FormatToArray(simData.pbest);
%   gbest = simData.FormatToArray(simData.gbest);
%   i = simData.FormatToArray(simData.iteration);
%   ss = simData.FormatToArray(simData.oInSteadyState);
end

if strcmp(typeOfAlgo, extremumSeekType)
  subplot(2,1,1)
  plot(d1)
  title('d')
  subplot(2,1,2)
  plot(j1)
  title('j')
end
%//////////////////////////////////////////////////////////////////////////

close(wbh)
%//////////////////////////////////////////////////////////////////////////
