
%**************************************************************************
%********************    Main simulation    *******************************
%**************************************************************************

% Setup workspace
%==========================================================================
clearvars -except rngState
% clear % Commenting this will ensure the same rng is achieved.
clear RunPpsoPno  % Because of persistent variables
close all

if exist('rngState', 'var')
  rng(rngState);
else
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
import AlgoPkg.PnoPkg.*
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
psoType           = 'pso';
extremumSeekType  = 'extSeek';
pnoType           = 'pno';
psoPnoType        = 'psoPno';

% typeOfAlgo        = psoType;
typeOfAlgo        = psoPnoType;
% typeOfAlgo        = extremumSeekType;
% typeOfAlgo        = pnoType;
%-------------------------------------------

if strcmp(typeOfAlgo, psoType) || strcmp(typeOfAlgo, psoPnoType)
%   nIterations = 75; 
  nIterations = 200;
  waitBarModulo = 5;
elseif strcmp(typeOfAlgo, extremumSeekType)
  if strcmp(typeOfUnits, mfcType)
    nIterations = 500;
  elseif strcmp(typeOfUnits, staticFunctionType)
    nIterations = 1000;
  else
    error('Must define a type of units!');
  end
  waitBarModulo = 50;
elseif strcmp(typeOfAlgo, pnoType)
  if strcmp(typeOfUnits, mfcType)
    nIterations = 500;
  elseif strcmp(typeOfUnits, staticFunctionType)
    nIterations = 1000;
  else
    error('Must define a type of units!');
  end
  waitBarModulo = 50;
else
  error('Must define a type of algorithm!');
end

wbh = waitbar(0, ['Sim : ' num2str(0) '/' num2str(nIterations)]);  % Waitbar handle
%//////////////////////////////////////////////////////////////////////////


% Unit array
%==========================================================================
nUnits = 8;
% nUnits = 6;

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
elseif strcmp(typeOfAlgo, psoPnoType)
  InitPsoPno
elseif strcmp(typeOfAlgo, extremumSeekType)
  InitExtremumSeeking
elseif strcmp(typeOfAlgo, pnoType)
  InitPno
else
  error('Must define a type of algorithm!');
end
%//////////////////////////////////////////////////////////////////////////


% Perturbations
%==========================================================================
oDoPerturb = 1;

nPerturbToApply = 1;

nUnitsToPerturb = [8];
perturbIteration = [100];

if strcmp(typeOfUnits, mfcType)
  perturbAmp = -100;
%     perturbIteration = 4000;
%     perturbIteration = 23;
elseif strcmp(typeOfUnits, staticFunctionType)
  perturbAmp = [70 -3];
%     perturbIteration = 100;
%     perturbIteration = 40;
else
  error('Must define a type of units!');
end

for iPerturb = 1 : nPerturbToApply
%   if mod(array.nUnits, 2)
%     nUnitsToPerturb = 1;
%   else
% %     nUnitsToPerturb = array.nUnits/2;
%     nUnitsToPerturb = array.nUnits - 1;
%   end
  idx = zeros(1, nUnitsToPerturb(iPerturb));
  for i = 1 : nUnitsToPerturb(iPerturb)
    idx(i) = array.units(i).id;
  end
  perturb(iPerturb) = Perturbation_t(1, array, idx, oDoPerturb); %#ok<SAGROW>

%   if strcmp(typeOfUnits, mfcType)
%     perturbAmp = -10;
% %     perturbIteration = 4000;
% %     perturbIteration = 23;
%   elseif strcmp(typeOfUnits, staticFunctionType)
%     perturbAmp = [70 -3];
% %     perturbIteration = 100;
% %     perturbIteration = 40;
%   else
%     error('Must define a type of units!');
%   end

  perturb(iPerturb).SetAmplitude(perturbAmp);
  perturb(iPerturb).SetActiveIteration(perturbIteration(iPerturb));
end
%//////////////////////////////////////////////////////////////////////////


% Simulation
%==========================================================================
for iSim = 1 : nIterations
  if mod(iSim, waitBarModulo) == 0
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
% for iSimData = 1 : algo.nSimData
%   simData = algo.simData{iSimData}{1};
%   eval(['d'       num2str(iSimData) ' = simData.FormatToArray(simData.d);'              ]);
%   eval(['j'       num2str(iSimData) ' = simData.FormatToArray(simData.j);'              ]);
%   eval(['i'       num2str(iSimData) ' = simData.FormatToArray(simData.iteration);'      ]);
%   if strcmp(typeOfAlgo, psoType)
%     eval(['v'       num2str(iSimData) ' = simData.FormatToArray(simData.speed);'          ]);
%     eval(['jSingle' num2str(iSimData) ' = simData.FormatToArray(simData.jSingle);'        ]);
%     eval(['pbest'   num2str(iSimData) ' = simData.FormatToArray(simData.pbest);'          ]);
%     eval(['gbest'   num2str(iSimData) ' = simData.FormatToArray(simData.gbest);'          ]);
%     eval(['ss'      num2str(iSimData) ' = simData.FormatToArray(simData.oInSteadyState);' ]);
%   end
% %   d = simData.FormatToArray(simData.d);
% %   v = simData.FormatToArray(simData.speed);
% %   j = simData.FormatToArray(simData.j);
% %   jSingle = simData.FormatToArray(simData.jSingle);
% %   pbest = simData.FormatToArray(simData.pbest);
% %   gbest = simData.FormatToArray(simData.gbest);
% %   i = simData.FormatToArray(simData.iteration);
% %   ss = simData.FormatToArray(simData.oInSteadyState);
% end
% 
% if strcmp(typeOfAlgo, extremumSeekType)
%   subplot(2,1,1)
%   plot(d1)
%   title('d')
%   subplot(2,1,2)
%   plot(j1)
%   title('j')
% end
% 
% if strcmp(typeOfAlgo, psoType)
%   if dimension == 1
%     subplot(2,1,1)
%     plot(d1)
%     title('d')
%     subplot(2,1,2)
%     plot(j1)
%     title('j')
%   else
%     d1(end,:,:)
%     [i1 ss1]
%   end
% end

% Plot data

figure
% set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
subplot(2,1,1)
hold on
legendStr = {};
for i = 1 : array.nUnits
  legendStr{i} = ['Unit ' num2str(i)]; %#ok<SAGROW>
end
for i = 1 : array.nUnits
  clear t
  t = 1 : array.units(i).nUnitEval;
  t = t .* array.unitEvalTime;
  plot(t, array.units(i).dmem(1,array.units(i).nUnitEval))
end
legend(legendStr)
title('d')
subplot(2,1,2)
hold on
for i = 1 : array.nUnits
  clear t
  t = 1 : array.units(i).nUnitEval;
  t = t .* array.unitEvalTime;
  plot(t, array.units(i).jmem(1,array.units(i).nUnitEval))
end
legend(legendStr)
title('j')

% % For debug
% %---------------
% d = zeros(nIterations, nUnits);
% j = zeros(nIterations, nUnits);
% dsort = zeros(nIterations, nUnits);
% jsort = zeros(nIterations, nUnits);
% dmax = zeros(1, nUnits);
% jmax = zeros(1, nUnits);
% for i = 1 : array.nUnits
%   d(:,i) = array.units(i).dmem(1,nIterations);
%   j(:,i) = array.units(i).jmem(1,nIterations);
%   
%   [dsort(:,i) idx] = sort(d(:,i));
%   jsort(:,i) = j(idx,i);
%   
%   [jmax(i) idx] = max(j(:,i));
%   dmax(i) = d(idx, i);
% end
% 
% figure
% plot(dsort,jsort);
% hold on
% plot(dmax, jmax, 's')
% legendStr{end+1} = 'Max points';
% legend(legendStr)

%---------------
%//////////////////////////////////////////////////////////////////////////

close(wbh)
%//////////////////////////////////////////////////////////////////////////
