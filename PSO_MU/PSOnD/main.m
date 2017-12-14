
%**************************************************************************
%********************    Main simulation    *******************************
%**************************************************************************

%% Setup workspace
%==========================================================================

if ~exist('oDoingLoops', 'var') % No doing tests in loop
  clearvars -except rngState
  clear % Commenting this will ensure the same rng is achieved.
  close all
end
clear RunPpsoPno  % Because of persistent variables

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

typeOfAlgo        = pnoType;
% typeOfAlgo        = psoType;
% typeOfAlgo        = psoPnoType;
% typeOfAlgo        = extremumSeekType;
%-------------------------------------------

if strcmp(typeOfAlgo, psoType) || strcmp(typeOfAlgo, psoPnoType)
%   nIterations = 75; 
  nIterations = 300;
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
    nIterations = 300;
  elseif strcmp(typeOfUnits, staticFunctionType)
    nIterations = 1000;
  else
    error('Must define a type of units!');
  end
  waitBarModulo = 5;
else
  error('Must define a type of algorithm!');
end

% nIterations = 75;

wbh = waitbar(0, ['Sim : ' num2str(0) '/' num2str(nIterations)]);  % Waitbar handle
%//////////////////////////////////////////////////////////////////////////


%% Unit array
%==========================================================================
% nUnits = 40;
nUnits = 10;

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

if oDoPerturb == 1
  nPerturbToApply = 2;
else
  nPerturbToApply = 0;
end

nUnitsToPerturb = [nUnits/2 nUnits/2];
% nUnitsToPerturb = [nUnits nUnits];
perturbIteration = [100 200];

if strcmp(typeOfUnits, mfcType)
  perturbAmp = [-400 400];
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

  perturb(iPerturb).SetAmplitude(perturbAmp(iPerturb));
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

% figure
figure('units','normalized','outerposition',[0 0 1 1])
% set(gcf, 'Position', get(0,'Screensize')); % Maximize figure.
subplot(2,1,1)
hold on
legendStr = {};
for i = 1 : array.nUnits
  legendStr{i} = ['Unité ' num2str(i)]; %#ok<SAGROW>
end
for i = 1 : array.nUnits
  clear t
  t = 1 : array.units(i).nUnitEval;
  t = t .* array.unitEvalTime;
%   plot(t, array.units(i).dmem(1,array.units(i).nUnitEval))
  plot(array.units(i).dmem(1,array.units(i).nUnitEval), 'LineWidth', 1)
end
title('Résistance externe des unités (\Omega)')
xlabel('Itération')
ylabel('R_e_x_t (\Omega)')
set(gca, 'FontSize', 14)
tmpLegendIdx = array.nUnits;
tmpLineStyleIdx = 1;
lineStyles = {'--', ':'};
for iPerturb = 1 : nPerturbToApply
  line([perturbIteration(iPerturb) perturbIteration(iPerturb)], ylim, 'LineStyle', lineStyles{tmpLineStyleIdx}, 'LineWidth', 1)
  tmpLineStyleIdx = tmpLineStyleIdx + 1;
  if tmpLineStyleIdx == 3
    tmpLineStyleIdx = 1;
  end
  tmpLegendIdx = tmpLegendIdx + 1;
  legendStr{tmpLegendIdx} = ['Perturbation ' num2str(iPerturb)];
end
legend(legendStr)

subplot(2,1,2)
hold on
for i = 1 : array.nUnits
  clear t
  t = 1 : array.units(i).nUnitEval;
  t = t .* array.unitEvalTime;
%   plot(t, array.units(i).jmem(1,array.units(i).nUnitEval))
  plot(array.units(i).jmem(1,array.units(i).nUnitEval), 'LineWidth', 1)
end
title('Puissance de sortie des unités (W)')
xlabel('Itération')
ylabel('P_o_u_t (W)')
set(gca, 'FontSize', 14)
tmpLineStyleIdx = 1;
for iPerturb = 1 : nPerturbToApply
  line([perturbIteration(iPerturb) perturbIteration(iPerturb)], ylim, 'LineStyle', lineStyles{tmpLineStyleIdx}, 'LineWidth', 1)
  tmpLineStyleIdx = tmpLineStyleIdx + 1;
  if tmpLineStyleIdx == 3
    tmpLineStyleIdx = 1;
  end
end
legend(legendStr)

set(gcf, 'Color', 'w')


%% Analyze convergence time, precision, and tracking efficiency of algorithm
%--------------------------------------------------------------------------
fprintf('\n\t\t\t\t\t\t\t***********************************************\n')
if strcmp(typeOfAlgo, psoType)
  import AlgoPkg.PsoPkg.PsoType
  if psoAlgo == PsoType.PARALLEL_PSO
    fprintf('\t\t\t\t\t\t\t*********** PARALLEL PSO ANALYSIS *************\n')
  elseif psoAlgo == PsoType.PSO_1D
    fprintf('\t\t\t\t\t\t\t*********** SEQUENTIAL PSO ANALYSIS ***********\n')
  elseif psoAlgo == PsoType.PARALLEL_PSO_PBEST_ABS
    fprintf('\t\t\t\t\t\t\t****** PARALLEL PSO PBEST ABS ANALYSIS ********\n')
  else
    error('Whaat');
  end
elseif strcmp(typeOfAlgo, psoPnoType)
  fprintf('\t\t\t\t\t\t\t************** PSO-P&O ANALYSIS ***************\n')
elseif strcmp(typeOfAlgo, extremumSeekType)
  fprintf('\t\t\t\t\t\t\t********* EXTREMUM SEEKING ANALYSIS ***********\n')
elseif strcmp(typeOfAlgo, pnoType)
  fprintf('\t\t\t\t\t\t\t**************** P&O ANALYSIS *****************\n')
else
  error('Must define a type of algorithm!');
end
fprintf('\t\t\t\t\t\t\t***********************************************\n')

if oDoPerturb
  len = perturbIteration(1);
else
  len = nIterations;
end
dBefore = zeros(len, nUnits);
jBefore = zeros(len, nUnits);
optPosBefore = zeros(1, nUnits);
optPowerBefore = zeros(1, nUnits);
for iUnit = 1 : nUnits
  dBefore (:, iUnit) = array.units(iUnit).dmem(1, len);
  jBefore (:, iUnit) = array.units(iUnit).jmem(1, len);
  [optPowerBefore(iUnit), idx] = max(jBefore(:,iUnit));
  optPosBefore(iUnit) = dBefore(idx, iUnit);
end
steadyStateBefore = zeros(1, nUnits);
convergenceBefore = zeros(1, nUnits);
meanPowerBefore = zeros(1, nUnits);
ssOscBefore = zeros(1, nUnits);
precisionBefore = zeros(1, nUnits);
efficiencyBefore = zeros(1, nUnits);
joulesBefore = zeros(1, nUnits);
tBefore = (1:len) * array.unitEvalTime * 24 * 60 * 60;

oscAmp = 0.05;
for iUnit = 1 : nUnits
  for iIteration = 1 : len
    clear meanJ
    meanJ = mean(jBefore(iIteration:end, iUnit));
    if (max(jBefore(iIteration:end, iUnit)) - meanJ) / meanJ < oscAmp && (meanJ - min(jBefore(iIteration:end, iUnit)))/meanJ < oscAmp
      break;
    end
  end
  steadyStateBefore(iUnit) = iIteration;
  precisionBefore(iUnit) = 100 - abs((mean(dBefore(iIteration:end, iUnit) - optPosBefore(iUnit)))) / optPosBefore(iUnit) * 100;
  efficiencyBefore(iUnit) = 100 - abs(mean(jBefore(:,iUnit)) - optPowerBefore(iUnit)) / optPowerBefore(iUnit) * 100;
  joulesBefore(iUnit) = trapz(tBefore, jBefore(:,iUnit));

  for iIteration = 1 : len
    if length(dBefore(iIteration:end, iUnit)) < 3
      break;
    end
    [maxPeaks maxIdx] = findpeaks(dBefore(iIteration:end, iUnit));
    dInv = 1.01*max(dBefore(iIteration:end, iUnit)) - dBefore(iIteration:end, iUnit);
    [minPeaks minIdx] = findpeaks(dInv);
    dTemp = dBefore(iIteration:end, iUnit);
    minPeaks = dTemp(minIdx);
    if ~isempty(maxPeaks) && ~isempty(minIdx)
      if (max(maxPeaks) - mean(maxPeaks)) / mean(maxPeaks) < oscAmp/2 && (mean(minPeaks) -  min(minPeaks)) / mean(minPeaks) < oscAmp
        if dTemp(1) ~= max(dTemp) && dTemp(1) ~= min(dTemp)
          break;
        end
      end
    else
      if isempty(maxPeaks) && isempty(minIdx)
        break;
      elseif isempty(maxPeaks)
        if (mean(minPeaks) -  min(minPeaks)) / mean(minPeaks) < oscAmp/2
          if dTemp(1) ~= max(dTemp) && dTemp(1) ~= min(dTemp)
            break;
          end
        end
      else % isempty(minIdx)
        if (max(maxPeaks) - mean(maxPeaks)) / mean(maxPeaks) < oscAmp/2
          if dTemp(1) ~= max(dTemp) && dTemp(1) ~= min(dTemp)
            break;
          end
        end
      end
    end
  end
  convergenceBefore(iUnit) = iIteration;
  meanPowerBefore(iUnit) = mean(jBefore(iIteration:end, iUnit));
  ssOscBefore(iUnit) = max(abs(jBefore(iIteration:end, iUnit) - meanPowerBefore(iUnit))) * 100 / meanPowerBefore(iUnit);
  totalPowerBefore = sum(jBefore(:,:), 2);
  maxPowerBefore = max(totalPowerBefore);
  totalEfficiencyBefore = mean(totalPowerBefore)/maxPowerBefore * 100;
  
  if exist('oDoingLoops', 'var')
    convTime (iLoop, iUnit, 1) = convergenceBefore(iUnit);
  end
end

if exist('oDoingLoops', 'var')
  joulesMem(iLoop, 1) = sum(joulesBefore(:));
end
  
fprintf('\n==========================================================================================================\n')
fprintf('\t\t\t\t\t\t\t\t********  Before perturbation  ********\n')
fprintf('==========================================================================================================\n')
%   fprintf(['Unit\tS0\t\t\t\tPrecision\t\tConvergence\t\tEfficiency\tJoules\n']);
fprintf(['Unit\tS0\t\t\tPrecision\tSS @ ±' num2str(uint16(oscAmp*100)) '%%\tEfficiency\tJoules\t\tConvergence time\tConvergence power [mW]\n']);
for iUnit = 1 : nUnits
  fprintf([num2str(uint16(iUnit)) '\t\t'])
  if (unitsS0(iUnit) < 100)
    fprintf(' ')
  end
  fprintf([num2str(unitsS0(iUnit), '%.4f') '\t'])
  fprintf([num2str(precisionBefore(iUnit), '%.2f') '\t\t'])
  fprintf([num2str(uint16(steadyStateBefore(iUnit))) '\t\t\t'])
  fprintf([num2str(efficiencyBefore(iUnit), '%.2f') '\t\t'])
  if joulesBefore(iUnit) < 1000
    fprintf(' ')
  end
  fprintf([num2str(joulesBefore(iUnit), '%.3f') '\t'])
  fprintf([num2str(uint16(convergenceBefore(iUnit))) '\t\t\t\t\t'])
  fprintf([num2str(meanPowerBefore(iUnit)*1000, '%.4f') ' ±' num2str(ssOscBefore(iUnit), '%.2f') '%%'])
  fprintf('\n')
end
fprintf('----------------------------------------------------------------------------------------------------------\n')
fprintf('Total\t\t\t\t')
fprintf([num2str(mean(precisionBefore(:)), '%.2f') '\t\t\t\t\t'])
%   fprintf([num2str(mean(efficiencyBefore(:)), '%.2f') '\t\t'])
fprintf([num2str(totalEfficiencyBefore, '%.2f') '\t\t'])
fprintf([num2str(sum(joulesBefore(:)), '%.3f') '\t\t'])

% ---------------------------------

for iPerturb = 1 : nPerturbToApply
  
  if iPerturb < nPerturbToApply
    finalIteration = perturbIteration(iPerturb + 1);
  else
    finalIteration = nIterations;
  end
  steadyStateAfter = zeros(1, nUnits);
  convergenceAfter = zeros(1, nUnits);
  meanPowerAfter = zeros(1, nUnits);
  ssOscAfter = zeros(1, nUnits);
  precisionAfter = zeros(1, nUnits);
  efficiencyAfter = zeros(1, nUnits);
  joulesAfter = zeros(1, nUnits);
  tAfter  = (1:finalIteration - perturbIteration(iPerturb)) * array.unitEvalTime * 24 * 60 * 60;


  dAfter = zeros(finalIteration - perturbIteration(iPerturb), nUnits);
  jAfter = zeros(finalIteration - perturbIteration(iPerturb), nUnits);
  optPosAfter = zeros(1, nUnits);
  optPowerAfter = zeros(1, nUnits);
  for iUnit = 1 : nUnits
    dAfter  (:, iUnit) = array.units(iUnit).dmem(perturbIteration(iPerturb)+1, finalIteration);
    jAfter  (:, iUnit) = array.units(iUnit).jmem(perturbIteration(iPerturb)+1, finalIteration);
    [optPowerAfter(iUnit), idx] = max(jAfter(:,iUnit));
    optPosAfter(iUnit) = dAfter(idx, iUnit);
  end
  
  oscAmp = 0.05;
  for iUnit = 1 : nUnits
    for iIteration = 1 : finalIteration - perturbIteration(iPerturb)
      clear meanJ
      meanJ = mean(jAfter(iIteration:end, iUnit));
      if (max(jAfter(iIteration:end, iUnit)) - meanJ) / meanJ < oscAmp && (meanJ - min(jAfter(iIteration:end, iUnit)))/meanJ < oscAmp
        break;
      end
    end
    steadyStateAfter(iUnit) = iIteration;
    precisionAfter(iUnit) = 100 - abs((mean(dAfter(iIteration:end, iUnit) - optPosAfter(iUnit)))) / optPosAfter(iUnit) * 100;
    efficiencyAfter(iUnit) = 100 - abs(mean(jAfter(:,iUnit)) - optPowerAfter(iUnit)) / optPowerAfter(iUnit) * 100;
    joulesAfter(iUnit) = trapz(tAfter, jAfter(:,iUnit));

    for iIteration = 1 : perturbIteration(iPerturb)
      if length(dAfter(iIteration:end, iUnit)) < 3
        break;
      end
      [maxPeaks maxIdx] = findpeaks(dAfter(iIteration:end, iUnit));
      dInv = 1.01*max(dAfter(iIteration:end, iUnit)) - dAfter(iIteration:end, iUnit);
      [minPeaks minIdx] = findpeaks(dInv);
      dTemp = dAfter(iIteration:end, iUnit);
      minPeaks = dTemp(minIdx);
      if ~isempty(maxPeaks) && ~isempty(minIdx)
        if (max(maxPeaks) - mean(maxPeaks)) / mean(maxPeaks) < oscAmp/2 && (mean(minPeaks) -  min(minPeaks)) / mean(minPeaks) < oscAmp
          if dTemp(1) ~= max(dTemp) && dTemp(1) ~= min(dTemp)
            break;
          end
        end
      else
        if isempty(maxPeaks) && isempty(minIdx)
          break;
        elseif isempty(maxPeaks)
          if (mean(minPeaks) -  min(minPeaks)) / mean(minPeaks) < oscAmp/2
            if dTemp(1) ~= max(dTemp) && dTemp(1) ~= min(dTemp)
              break;
            end
          end
        else % isempty(minIdx)
          if (max(maxPeaks) - mean(maxPeaks)) / mean(maxPeaks) < oscAmp/2
            if dTemp(1) ~= max(dTemp) && dTemp(1) ~= min(dTemp)
              break;
            end
          end
        end
      end
    end
    convergenceAfter(iUnit) = iIteration;
    meanPowerAfter(iUnit) = mean(jAfter(iIteration:end, iUnit));
    ssOscAfter(iUnit) = max(abs(jAfter(iIteration:end, iUnit) - meanPowerAfter(iUnit))) * 100 / meanPowerAfter(iUnit);
    totalPowerAfter = sum(jAfter(:,:), 2);
    maxPowerAfter = max(totalPowerAfter);
    totalEfficiencyAfter = mean(totalPowerAfter)/maxPowerAfter * 100;
    
    if exist('oDoingLoops', 'var')
      convTime (iLoop, iUnit, iPerturb + 1) = convergenceAfter(iUnit);
    end
  end
  if exist('oDoingLoops', 'var')
    joulesMem(iLoop, iPerturb + 1) = sum(joulesAfter(:));
  end

  fprintf('\n==========================================================================================================\n')
  fprintf(['\t\t\t\t\t\t\t\t********  After perturbation ' num2str(uint16(iPerturb)) ' ********\n'])
  fprintf('==========================================================================================================\n')
  %   fprintf(['Unit\tS0\t\t\t\tPrecision\t\tConvergence\t\tEfficiency\tJoules\n']);
  fprintf(['Unit\tS0\t\t\tPrecision\tSS @ ±' num2str(uint16(oscAmp*100)) '%%\tEfficiency\tJoules\t\tConvergence time\tConvergence power [mW]\n']);
  for iUnit = 1 : nUnits
    fprintf([num2str(uint16(iUnit)) '\t\t'])
    if (unitsS0(iUnit) + perturbAmp(iPerturb)) < 100
      fprintf(' ')
    end
    fprintf([num2str(unitsS0(iUnit) + perturbAmp(iPerturb), '%.4f') '\t'])
    fprintf([num2str(precisionAfter(iUnit), '%.2f') '\t\t'])
    fprintf([num2str(uint16(steadyStateAfter(iUnit))) '\t\t\t'])
    fprintf([num2str(efficiencyAfter(iUnit), '%.2f') '\t\t'])
    if joulesAfter(iUnit) < 1000
      fprintf(' ')
    end
    fprintf([num2str(joulesAfter(iUnit), '%.3f') '\t'])
    fprintf([num2str(uint16(convergenceAfter(iUnit))) '\t\t\t\t\t'])
    fprintf([num2str(meanPowerAfter(iUnit)*1000, '%.4f') ' ±' num2str(ssOscAfter(iUnit), '%.2f') '%%'])
    fprintf('\n')
  end
  fprintf('----------------------------------------------------------------------------------------------------------\n')
  fprintf('Total\t\t\t\t')
  fprintf([num2str(mean(precisionAfter(:)), '%.2f') '\t\t\t\t\t'])
  %   fprintf([num2str(mean(efficiencyAfter(:)), '%.2f') '\t\t'])
  fprintf([num2str(totalEfficiencyAfter, '%.2f') '\t\t'])
  fprintf([num2str(sum(joulesAfter(:)), '%.3f') '\t\t'])

end

fprintf('\n');


%% Close waitbar handle
%//////////////////////////////////////////////////////////////////////////

close(wbh)
%//////////////////////////////////////////////////////////////////////////
