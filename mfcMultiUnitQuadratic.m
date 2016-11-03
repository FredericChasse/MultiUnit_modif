clear all
close all
clc

oDoFigures = 1;

T = 0.2;
% T = 1;

nIterations = 100 / T;
iPerturb = 60;

oDoPerturbStatic  = 0;
oDoPerturbDynamic = 0;
oDoGammaDif       = 0;
oDoGammaBetaDif   = 0;
oDoBetaDif        = 1;
gamma = 0.0001;
beta = 10;

% S0 = ones(2, nIterations) * 450;
S0 = ones(2, nIterations) * 300;
if oDoPerturbStatic
  S0(:,iPerturb:end) = S0(1,1) + perturbAmp;
end
if oDoPerturbDynamic
  t = iPerturb:1:nIterations;
  x = sin(t/2)*25 + 650;
  for iUnit = 1:2
    S0(iUnit,iPerturb:end) = x;
  end
  clear t x
end
if oDoGammaBetaDif
  S0(1, :) = 500;
end

mfcDynamics = zeros(2, 4);
mfcDynamics(1, :) = [20.8395  498.2432    2.0000    0.0412];
mfcDynamics(2, :) = [20.8395  498.2432    2.0000    0.0412];

odeOptions = odeset('RelTol',1e-6,'AbsTol',1e-9);

Pout = zeros(2, nIterations);

kmu = 20000;
delta = 20;

RextMax = 1050;
RextMin = 50;

Rres = 0.05;
% Rres = 0.1;

Rinit = 70;

Rext = zeros(nIterations, 2);

Rext(1, 1) = Rinit - delta/2;
Rext(1, 2) = Rinit + delta/2;
% Rext(1) = rand*(RextMax - RextMin) + RextMin;

cmd = [0 Rinit];
grad = [0 0];
format short

diff = zeros(nIterations,1);

gradMem = zeros(nIterations, 2);
cmdMem  = zeros(nIterations, 2);
ni = 1:nIterations;
ni = ni';

bufferJ = [0 0 0; 0 0 0];
bufferU = [0 0 0; 0 0 0];

Rfig = RextMin:.1:RextMax;

tic
waitBarHandler = waitbar(0);
for i = 1 : nIterations
  
  waitbar(i/nIterations);
  
  % Unit 1
  if oDoBetaDif
    [tt, Y] = ode15s('mfcModel', [0 T], mfcDynamics(1, :), odeOptions, S0(1, i), Rext(i, 1) + beta);
    mfcDynamics(1, :) = Y(end, :);
    [dummy, Pout(1, i)] = mfcModel(T, mfcDynamics(1, :), odeOptions, S0(1, i), Rext(i, 1) + beta);
  else
    [tt, Y] = ode15s('mfcModel', [0 T], mfcDynamics(1, :), odeOptions, S0(1, i), Rext(i, 1));
    mfcDynamics(1, :) = Y(end, :);
    [dummy, Pout(1, i)] = mfcModel(T, mfcDynamics(1, :), odeOptions, S0(1, i), Rext(i, 1));
  end
  
  if oDoGammaDif
    Pout(1, i) = Pout(1, i) + gamma;
  end
  
  % Unit 2
  [tt, Y] = ode15s('mfcModel', [0 T], mfcDynamics(2, :), odeOptions, S0(2, i), Rext(i, 2));
  mfcDynamics(2, :) = Y(end, :);
  [dummy, Pout(2, i)] = mfcModel(T, mfcDynamics(2, :), odeOptions, S0(2, i), Rext(i, 2));
  
  % Buffer samples
  if Pout(1, i) ~= bufferJ(1,1) && Rext(i, 1) ~= bufferU(1, 1) && Pout(2, i) ~= bufferJ(2,1) && Rext(i, 2) ~= bufferU(2, 1)
    bufferJ(:, 2:3) = bufferJ(:, 1:2);
    bufferJ(1, 1) = Pout(1, i);
    bufferJ(2, 1) = Pout(2, i);
    bufferU(:, 2:3) = bufferU(:, 1:2);
    bufferU(1, 1) = Rext(i, 1);
    bufferU(2, 1) = Rext(i, 2);
  end
  
  % Quadratic eval
  if i >= 3
    [a1 uopt1 jopt1] = GetQuadraticValues(bufferU(1,:), bufferJ(1,:));
    [a2 uopt2 jopt2] = GetQuadraticValues(bufferU(2,:), bufferJ(2,:));
    allo = 1;
  end
  
  % Tustin's discrete integrator
  grad(1) = grad(2);
  
  diff(i) = Pout(2, i) - Pout(1, i);
  grad(2) = kmu * diff(i);
  cmd(1) = cmd(2);
  cmd(2) = cmd(1) + T/2*(grad(1) + grad(2));
  
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
  bufferMem(i, :) = [bufferJ(1,:) bufferJ(2,:)];
  iMem(i, 1) = i;
  if i >= 3
    aMem(i, :) = [a1 a2];
    uoptMem(i,:) = [uopt1 uopt2];
    joptMem(i,:) = [jopt1 jopt2];
  else
    aMem(i, :) = [0 0];
    uoptMem(i,:) = [0 0];
    joptMem(i,:) = [0 0];
  end
end
toc

if oDoFigures
  subplot(2,1,1)
  stairs(Pout(1,:))
  hold on
  stairs(Pout(2,:))
  legend({'1' '2'})
  hold off
  
  subplot(2,1,2)
  stairs(Rext(:,1))
  hold on
  stairs(Rext(:,2))
  legend({'1' '2'})
  hold off
end

close(waitBarHandler)

%% Steady-state

ssPrecision = 0.05;

iSteadyState = nIterations + 1;

if oDoPerturbStatic || oDoPerturbDynamic
  iStart = iPerturb;
else
  iStart = 1;
end

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