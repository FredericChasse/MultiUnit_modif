clear all
close all

nLoops = 10;

nSections = 1;  % Must be equal to nPerturbToApply + 1

oDoingLoops = 1;

nUnitsToTest = 10; % Must be equal to nUnits

convTime = zeros(nLoops, nUnitsToTest, nSections);
joulesMem = zeros(nLoops, nSections);
powersMem = zeros(nLoops, nSections);
efficiencyMem = zeros(nLoops, nSections);
precisionMem = zeros(nLoops, nSections);

for iLoop = 1 : nLoops
  clearvars -except iLoop nLoops nSections oDoingLoops convTime joulesMem powersMem efficiencyMem precisionMem
%   close all
  
  loopStr = ['\nDoing loop #' num2str(iLoop) '\n'];
  fprintf(loopStr)
  main
  
end

meanTotalJoules = zeros(1,nSections);
meanConvTime = zeros(1,nSections);
meanPowers = zeros(1, nSections);
meanEfficiency = zeros(1, nSections);
meanPrecision = zeros(1, nSections);

for iSection = 1 : nSections
  meanTotalJoules(iSection) = mean(joulesMem(:,iSection));
  meanConvTime   (iSection) = mean(mean(convTime (:,:,iSection)));
  meanPowers     (iSection) = mean(powersMem(:,iSection)) .* 1000;
  meanEfficiency (iSection) = mean(efficiencyMem(:,iSection));
  meanPrecision  (iSection) = mean(precisionMem(:,iSection));
end

format long g
meanTotalJoules
meanConvTime
meanPowers
meanEfficiency
meanPrecision

clearvars -except meanTotalJoules meanConvTime meanPowers meanEfficiency meanPrecision joulesMem convTime powersMem efficiencyMem precisionMem