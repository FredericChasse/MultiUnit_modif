clear all
close all
% clc

oDoFigures = 1;

nIterations = 150;
iPerturb = 60;

kmu = 100;
% kmu = 50;
delta = 20;

% RextMax = 1050;
% RextMin = 50;
RextMax = 200;
RextMin = 10;

% Rres = 0.1;
Rres = 0;

Rinit = 30;
Rinit = 170;
% Rinit = 120;

Rext = zeros(nIterations, 2);

Rext(1, 1) = Rinit - delta/2;
Rext(1, 2) = Rinit + delta/2;
% Rext(1) = rand*(RextMax - RextMin) + RextMin;

u = [0 Rinit];
grad = [0 0];
format short

diff = zeros(nIterations,1);
gradSingle = zeros(nIterations,2);

beta = 0;
% beta = -25;
gamma = 0;
% gamma = 10;

Dopt(1) = 100;
Jopt(1) = 20;
Dopt(2) = 100 - beta;
Jopt(2) = 20  + gamma;

% OCV = 1.2;

J = zeros(2, nIterations);

gradMem = zeros(nIterations, 2);
uMem  = zeros(nIterations, 2);
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

uSign1 = zeros(2, nIterations);

grad1 = zeros(nIterations,2);
grad2 = zeros(nIterations,2);
vecDif = zeros(nIterations,2);

%% Algorithm

uSign1 = 0;
uSign2 = 0;
uSignOld1 = 0;
uSignOld2 = 0;
uSignSlope1 = 0;
uSignSlope2 = 0;
uBest1 = Rext(1, 1);
uBest2 = Rext(1, 2);

tic
waitBarHandler = waitbar(0);
for i = 1 : nIterations
  
  waitbar(i/nIterations);
  
  % Unit 1
  J(1, i) = -0.002 * (Rext(i, 1) - Dopt(1))^2 + Jopt(1);
  
  % Unit 2
  J(2, i) = -0.002 * (Rext(i, 2) - Dopt(2))^2 + Jopt(2);

%   if i == 1
%     Pbest(1, i) = Rext(1, 1);
%     Pbest(2, i) = Rext(1, 2);
%   else
%     if J(1, i) > Pbest(1, i-1)
%       Pbest(1, i) = Rext(i, 1);
%     else
%       Pbest(1, i) = Pbest(1, i-1);
%     end
%     if J(2, i) > Pbest(2, i-1)
%       Pbest(2, i) = Rext(i,2);
%     else
%       Pbest(2, i) = Pbest(2, i-1);
%     end
%   end
  
  diff(i) = J(2, i) - J(1, i);
  
  % Tustin's discrete integrator
  grad(1) = grad(2);
  if i == 1
    grad(2) = kmu * diff(i);
    uSign1 = 0;
    uSign2 = 0;
  else
%     grad(2) = kmu * diff(i);
%     grad(2) = kmu * diff(i) * (sign((J(1,i)-J(1,i-1))*(Rext(i,1)-Rext(i-1,1))) + sign((J(2,i)-J(2,i-1))*(Rext(i,2)-Rext(i-1,2))));
%     grad(2) = kmu * diff(i) * sign((J(1,i)-J(1,i-1))*(Rext(i,1)-Rext(i-1,1)));
%     grad(2) = kmu * diff(i) * sign((J(2,i)-J(2,i-1))*(Rext(i,2)-Rext(i-1,2)));
%     grad(2) = kmu * (J(2,i)+J(2,i-1)-J(1,i)-J(1,i-1));
    uSignOld1 = uSign1;
    uSignOld2 = uSign2;
    uSign1 = sign((J(1,i)-J(1,i-1))*(Rext(i,1)-Rext(i-1,1)));
    uSign2 = sign((J(2,i)-J(2,i-1))*(Rext(i,2)-Rext(i-1,2)));
    uSignSlope1 = uSignOld1 * uSign1;
    uSignSlope2 = uSignOld2 * uSign2;
    
    if i > 2
      uBest1 = (uSignSlope1 - 1) * uBest1 / 2 + (uSignSlope1 + 1) * Rext(i, 1) / 2;
      uBest2 = (uSignSlope2 - 1) * uBest2 / 2 + (uSignSlope2 + 1) * Rext(i, 2) / 2;
      delta = max(0.1, uBest2 - uBest1);
    else
      uBest1 = Rext(i, 1);
      uBest2 = Rext(i, 2);
      delta = uBest2 - uBest1;
    end
    
    grad(2) = kmu / delta * diff(i);
%     grad(2) = (uSign1 + 1) * kmu / 10 * diff(i) + (uSign1 - 1) * kmu / 10 * diff(i);
  end
  u(1) = u(2);
  
%   cmd(2) = cmd(1) + T/2*(grad(1) + grad(2));
%   u(2) = u(1) + grad(2)/delta;
  u(2) = u(1) + grad(2);
%   u(2) = u(1) + grad(2)/(Rext(i,2)-Rext(i,1));

  if abs(u(2) - u(1)) < Rres
    u(2) = u(1);
  end

%   if i == 1
%     Rext(i+1, 1) = cmd(2) - delta/2;
%     Rext(i+1, 2) = cmd(2) + delta/2;
%   else
%     Rext(i+1, 1) = cmd(2) - delta/2 + .8*(Pbest(1, i) - Rext(i,1));
%     Rext(i+1, 2) = cmd(2) + delta/2 + .8*(Pbest(2, i) - Rext(i,2));
%   end

  vecDif(i, :) = [Rext(i,2)-Rext(i,1), J(2,i)-J(1,i)];
  if i > 1
    grad1(i, :) = [Rext(i,1)-Rext(i-1,1), J(1, i)-J(1,i-1)];
    grad2(i, :) = [Rext(i,2)-Rext(i-1,2), J(2, i)-J(2,i-1)];
  end
  
  if i < 3
    Rext(i+1, 1) = u(2) - delta/2;
    Rext(i+1, 2) = u(2) + delta/2;
  else
    Rext(i+1, 1) = uSignSlope1*u(2) - delta/2;
    Rext(i+1, 2) = uSignSlope2*u(2) + delta/2;
%     Rext(i+1, 1) = u(2) - delta/2 + 0.1*(Rext(i,1)-Rext(i-1,1))*(J(1,i)-J(1,i-1));
%     Rext(i+1, 2) = u(2) + delta/2 + 0.1*(Rext(i,2)-Rext(i-1,2))*(J(2,i)-J(2,i-1));
%     Rext(i+1, 1)
%     Rext(i+1, 2)
  end

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
  uMem (i, :) = u;
  
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
  plot(Rext(end-4, :), J(:, end-3), '*')
  plot(Rext(end-3, :), J(:, end-2), 'o')
  plot(Rext(end-2, :), J(:, end-1), 's')
  plot(Rext(end-1, :), J(:, end), '*')
%   plot(Rext(iMem - 1, :), J(:, iMem - 1), 's')
%   legend({'1' '2'})
  currentAxis = axis;
  axis([currentAxis(1) currentAxis(2) 0 currentAxis(4)+5])
  hold off
end

Rext;

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