clear all
close all
clc

oDoFigures = 1;

nIterations = 150;
iPerturb = 60;

kmu = 100;
kmu = 50;
delta = 20;

% RextMax = 1050;
% RextMin = 50;
RextMax = 200;
RextMin = 10;

% Rres = 0.1;
Rres = 0;

Rinit = 30;
% Rinit = 170;

Rext = zeros(nIterations, 2);

Rext(1, 1) = Rinit - delta/2;
Rext(1, 2) = Rinit + delta/2;
% Rext(1) = rand*(RextMax - RextMin) + RextMin;

cmd = [0 Rinit];
grad = [0 0];
format short

diff = zeros(nIterations,1);
gradSingle = zeros(nIterations,2);

beta(1) = 0;
beta(2) = 15;
% beta(2) = 0;
gamma(1) = 0;
gamma(2) = 10;
gamma(2) = 0;

Dopt(1) = 100 - beta (1);
Jopt(1) = 20  + gamma(1);
Dopt(2) = 100 - beta (2);
Jopt(2) = 20  + gamma(2);

% OCV = 1.2;

J = zeros(2, nIterations);

gradMem = zeros(nIterations, 2);
cmdMem  = zeros(nIterations, 2);
ni = 1:nIterations;
ni = ni';

T = 0.0001;
% T = 1;

iMem = 0;
oDiffBetweenUnits = 0;

oMultiUnitMode = 1;
oFindOptMode = 0;
oPsoMode = 0;

betaBetweenUnits = 0;
gammaBetweenUnits = 0;

%% Algorithm

tic
waitBarHandler = waitbar(0);
for i = 1 : nIterations
  
  if (i == 1)
    J(1, i) = -0.002 * (Rext(i, 2) - Dopt(1))^2 + Jopt(1);
    J(2, i) = -0.002 * (Rext(i, 2) - Dopt(2))^2 + Jopt(2);
    gammaDiff = J(2,i) - J(1,i);
  end
  
  waitbar(i/nIterations);
  
  % Unit 1
  J(1, i) = -0.002 * (Rext(i, 1) - Dopt(1))^2 + Jopt(1);
%   J(1, i) = OCV^2 * Rext(i, 1) / (Dopt(1) + Rext(i, 1))^2 + gamma(1);
%     J(iData, iUnit) = ocv^2 * d(iData, iUnit) / (rInt + d(iData, iUnit))^2;
  
  % Unit 2
  J(2, i) = -0.002 * (Rext(i, 2) - Dopt(2))^2 + Jopt(2);
%   J(2, i) = OCV^2 * Rext(i, 2) / (Dopt(2) + Rext(i, 2))^2 + gamma(2);

  if oMultiUnitMode
  
    % Tustin's discrete integrator
    grad(1) = grad(2);

    diff(i) = J(2, i) - J(1, i);
    if i ~= 1
      gradSingle(i, 1) = J(1, i) - J(1, i-1);
      gradSingle(i, 2) = J(2, i) - J(2, i-1);
      if sign(gradSingle(i, 1)) < 0 && sign(gradSingle(i,2)) < 0
        grad(2) = -kmu*diff(i);
        oDiffBetweenUnits = 1;
      elseif sign(gradSingle(i, 1)) > 0 && sign(gradSingle(i,2)) > 0 && ~oDiffBetweenUnits
        grad(2) = kmu*diff(i);
      elseif sign(gradSingle(i, 1)) > 0 && sign(gradSingle(i,2)) > 0 && oDiffBetweenUnits
        grad(2) = -kmu*diff(i);
      else
        if iMem == 0
          iMem = i
        end
        grad(2) = 0;
%         oMultiUnitMode = 0;
%         oFindOptMode = 1;
%         oPsoMode = 0;
      end
    else
      gradSingle(i,1) = J(1,i);
      gradSingle(i,2) = J(2,i);
      grad(2) = kmu * diff(i);
    end
  %   grad(2) = kmu * diff(i);
    cmd(1) = cmd(2);
  %   cmd(2) = cmd(1) + T/2*(grad(1) + grad(2));
    cmd(2) = cmd(1) + grad(2)/delta;

    if abs(cmd(2) - cmd(1)) < Rres
      cmd(2) = cmd(1);
    end

    Rext(i+1, 1) = cmd(2) - delta/2;
    Rext(i+1, 2) = cmd(2) + delta/2;

    if Rext(i+1, 2) > RextMax
      Rext(i+1, 1) = RextMax - delta;
      Rext(i+1, 2) = RextMax;
    end
    if Rext(i+1, 1) < RextMin
      Rext(i+1, 1) = RextMin;
      Rext(i+1, 2) = RextMin + delta;
    end

  %   if (i < nIterations)
  %     Rext(i+1) = min(RextMax, cmd(2));
  %     Rext(i+1) = max(RextMin, Rext(i+1));
  %   end
    gradMem(i, :) = grad;
    cmdMem (i, :) = cmd;
  
  end
end
toc

Rfig = RextMin:.1:RextMax;
Jfig1 = -0.002 .* (Rfig - Dopt(1)).^2 + Jopt(1);
Jfig2 = -0.002 .* (Rfig - Dopt(2)).^2 + Jopt(2);
% Jfig1 = OCV^2 .* Rfig ./ (Dopt(1) + Rfig).^2 + gamma(1);
% Jfig2 = OCV^2 .* Rfig ./ (Dopt(2) + Rfig).^2 + gamma(2);

if oDoFigures
  subplot(3,1,1)
  plot(J(1,:))
  hold on
  plot(J(2,:))
  legend({'1' '2'})
  hold off
  
  subplot(3,1,2)
  plot(Rext(:,1))
  hold on
  plot(Rext(:,2))
  legend({'1' '2'})
  hold off
  
  subplot(3,1,3)
  plot(Rfig, Jfig1, Rfig, Jfig2)
  hold on
  plot(Rext(1, :), J(:, 1), 'o')
  plot(Rext(end, :), J(:, end), '*')
  plot(Rext(iMem - 1, :), J(:, iMem - 1), 's')
%   legend({'1' '2'})
  currentAxis = axis;
  axis([currentAxis(1) currentAxis(2) 0 currentAxis(4)+5])
  hold off
end

close(waitBarHandler)

%% Steady-state

ssPrecision = 0.05;

iSteadyState = nIterations + 1;

iStart = 1;

for iData = iStart : nIterations

  meanD = mean(Rext(iData:end, :));
    
  for jData = iData : nIterations
    if ( mean( (Rext(jData, :) <= (1 + ssPrecision).*meanD) & (Rext(jData, :) >= (1 - ssPrecision).*meanD) ) ~= 1 )
      iSteadyState = nIterations + 1;
      break;
    else
      iSteadyState = iData;
    end
  end
  
  if (iSteadyState ~= nIterations + 1)
    break;
  end
end

if iStart ~= 1
  iSteadyState = iSteadyState - iStart;
else
  iSteadyState;
end