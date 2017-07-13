
%**************************************************************************
%********************    Main simulation    *******************************
%**************************************************************************

%% Setup workspace
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
import AlgoPkg.PsoPnoPkg.*
%//////////////////////////////////////////////////////////////////////////


%% Simulation environment
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
% typeOfAlgo        = psoPnoType;
% typeOfAlgo        = extremumSeekType;
typeOfAlgo        = pnoType;
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
    nIterations = 200;
  elseif strcmp(typeOfUnits, staticFunctionType)
    nIterations = 1000;
  else
    error('Must define a type of units!');
  end
  waitBarModulo = 5;
else
  error('Must define a type of algorithm!');
end

wbh = waitbar(0, ['Sim : ' num2str(0) '/' num2str(nIterations)]);  % Waitbar handle
%//////////////////////////////////////////////////////////////////////////


%% Unit array
%==========================================================================
% nUnits = 40;
nUnits = 5;

if strcmp(typeOfUnits, mfcType)
  InitMfc
elseif strcmp(typeOfUnits, staticFunctionType)
  InitStaticFunc
else
  error('Must define a type of units!');
end
%//////////////////////////////////////////////////////////////////////////


%% Algo init
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


%% Perturbations
%==========================================================================
oDoPerturb = 1;

nPerturbToApply = 1;

nUnitsToPerturb = [nUnits];
perturbIteration = [100];

if strcmp(typeOfUnits, mfcType)
  perturbAmp = -40;
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


%% Simulation
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


%% Plot data
%--------------------------------------------------------------------------

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


%% Analyze convergence time, precision, and tracking efficiency of algorithm
%--------------------------------------------------------------------------
fprintf('\n')
if strcmp(typeOfAlgo, psoType)
  import AlgoPkg.PsoPkg.PsoType
  if psoAlgo == PsoType.PARALLEL_PSO
    fprintf('\n');
    fprintf('***********************************************\n')
    fprintf('*********** PARALLEL PSO ANALYSIS *************\n')
    fprintf('***********************************************\n')
  elseif psoAlgo == PsoType.PSO_1D
    fprintf('\n');
    fprintf('***********************************************\n')
    fprintf('*********** SEQUENTIAL PSO ANALYSIS ***********\n')
    fprintf('***********************************************\n')
  elseif psoAlgo == PsoType.PARALLEL_PSO_PBEST_ABS
    fprintf('\n');
    fprintf('***********************************************\n')
    fprintf('****** PARALLEL PSO PBEST ABS ANALYSIS ********\n')
    fprintf('***********************************************\n')
  else
    error('Whaat');
  end
elseif strcmp(typeOfAlgo, psoPnoType)
  fprintf('\n');
  fprintf('***********************************************\n')
  fprintf('************** PSO-P&O ANALYSIS ***************\n')
  fprintf('***********************************************\n')
elseif strcmp(typeOfAlgo, extremumSeekType)
  fprintf('\n');
  fprintf('***********************************************\n')
  fprintf('********* EXTREMUM SEEKING ANALYSIS ***********\n')
  fprintf('***********************************************\n')
elseif strcmp(typeOfAlgo, pnoType)
  fprintf('\n');
  fprintf('***********************************************\n')
  fprintf('**************** P&O ANALYSIS *****************\n')
  fprintf('***********************************************\n')
else
  error('Must define a type of algorithm!');
end

if oDoPerturb && length(perturbIteration) == 1
  dBefore = zeros(perturbIteration(1), nUnits);
  dAfter = zeros(nIterations - perturbIteration(1), nUnits);
  jBefore = zeros(perturbIteration(1), nUnits);
  jAfter = zeros(nIterations - perturbIteration(1), nUnits);
  optPosBefore = zeros(1, nUnits);
  optPosAfter = zeros(1, nUnits);
  optPowerBefore = zeros(1, nUnits);
  optPowerAfter = zeros(1, nUnits);
  for iUnit = 1 : nUnits
    dBefore (:, iUnit) = array.units(iUnit).dmem(1, perturbIteration(1));
    dAfter  (:, iUnit) = array.units(iUnit).dmem(perturbIteration(1)+1, nIterations);
    jBefore (:, iUnit) = array.units(iUnit).jmem(1, perturbIteration(1));
    jAfter  (:, iUnit) = array.units(iUnit).jmem(perturbIteration(1)+1, nIterations);
    [optPowerBefore(iUnit), idx] = max(jBefore(:,iUnit));
    optPosBefore(iUnit) = dBefore(idx, iUnit);
    [optPowerAfter(iUnit), idx] = max(jAfter(:,iUnit));
    optPosAfter(iUnit) = dAfter(idx, iUnit);
  end
  
  convTimeBefore = zeros(1, nUnits);
  convTimeAfter = zeros(1, nUnits);
  precisionBefore = zeros(1, nUnits);
  precisionAfter = zeros(1, nUnits);
  efficiencyBefore = zeros(1, nUnits);
  efficiencyAfter = zeros(1, nUnits);
  
  oscAmp = 0.05;
  for iUnit = 1 : nUnits
    for iIteration = 1 : perturbIteration(1)
      clear meanJ
      meanJ = mean(jBefore(iIteration:end, iUnit));
      if (max(jBefore(iIteration:end, iUnit)) - meanJ) / meanJ < oscAmp && (meanJ - min(jBefore(iIteration:end, iUnit)))/meanJ < oscAmp
        break;
      end
    end
    convTimeBefore(iUnit) = iIteration;
    precisionBefore(iUnit) = 100 - abs((mean(dBefore(iIteration:end, iUnit) - optPosBefore(iUnit)))) / optPosBefore(iUnit) * 100;
    efficiencyBefore(iUnit) = 100 - abs(mean(dBefore(:,iUnit)) - optPosBefore(iUnit)) / optPosBefore(iUnit) * 100;
    
    for iIteration = 1 : nIterations - perturbIteration(1)
      clear meanJ
      meanJ = mean(jAfter(iIteration:end, iUnit));
      if (max(jAfter(iIteration:end, iUnit)) - meanJ) / meanJ < oscAmp && (meanJ - min(jAfter(iIteration:end, iUnit)))/meanJ < oscAmp
        break;
      end
    end
    convTimeAfter(iUnit) = iIteration;
    precisionAfter(iUnit) = 100 - abs((mean(dAfter(iIteration:end, iUnit) - optPosAfter(iUnit)))) / optPosAfter(iUnit) * 100;
    efficiencyAfter(iUnit) = 100 - abs(mean(dAfter(:,iUnit)) - optPosAfter(iUnit)) / optPosAfter(iUnit) * 100;
  end
  
  fprintf('\nBefore perturbation\n')
  fprintf(['Unit\tPrecision\t\tConvergence\t\tEfficiency\n']);
  for iUnit = 1 : nUnits
    fprintf([num2str(uint16(iUnit)) '\t\t' num2str(precisionBefore(iUnit), '%.2f') '\t\t\t' num2str(uint16(convTimeBefore(iUnit))) '\t\t\t\t' num2str(efficiencyBefore(iUnit), '%.2f') '\n']);
  end
  
  fprintf('\nAfter perturbation\n')
  fprintf(['Unit\tPrecision\t\tConvergence\t\tEfficiency\n']);
  for iUnit = 1 : nUnits
    fprintf([num2str(uint16(iUnit)) '\t\t' num2str(precisionAfter(iUnit), '%.2f') '\t\t\t' num2str(uint16(convTimeAfter(iUnit))) '\t\t\t\t' num2str(efficiencyAfter(iUnit), '%.2f') '\n']);
  end
%   disp({'Unit' 'Precision' 'Convergence' 'Efficiency'});
%   for iUnit = 1 : nUnits
%     tableVal = [iUnit precisionBefore(iUnit) convTimeBefore(iUnit) efficiencyBefore(iUnit)];
%     disp(tableVal);
%   end
%   
%   fprintf('\nAfter perturbation\n')
%   disp({'Unit' 'Precision' 'Convergence' 'Efficiency'});
%   for iUnit = 1 : nUnits
%     tableVal = [iUnit precisionAfter(iUnit) convTimeAfter(iUnit) efficiencyAfter(iUnit)];
%     disp(tableVal);
%   end
end



%% Close waitbar handle
%//////////////////////////////////////////////////////////////////////////

close(wbh)
%//////////////////////////////////////////////////////////////////////////
