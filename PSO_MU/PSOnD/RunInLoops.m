clear all
close all

nLoops = 10;

nSections = 3;  % Must be equal to nPerturbToApply + 1

oDoingLoops = 1;

nUnitsToTest = 1; % Must be equal to nUnits

convTime = zeros(nLoops, nUnitsToTest, nSections);
joulesMem = zeros(nLoops, nSections);

for iLoop = 1 : nLoops
  clearvars -except iLoop nLoops nSections oDoingLoops convTime joulesMem
%   close all
  
  loopStr = ['\nDoing loop #' num2str(iLoop) '\n'];
  fprintf(loopStr)
  main
  
end

meanTotalJoules = zeros(1,nSections);
meanConvTime = zeros(1,nSections);
for iSection = 1 : nSections
  meanTotalJoules(iSection) = mean(joulesMem(:,iSection));
  meanConvTime   (iSection) = mean(mean(convTime (:,:,iSection)));
end

format long g
meanTotalJoules
meanConvTime

clearvars -except meanTotalJoules meanConvTime joulesMem convTime