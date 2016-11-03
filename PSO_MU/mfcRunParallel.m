% clear all
close all

nUnits = 4;

S0 = zeros(nUnits,1);

for i = 1 : nUnits
  S0(i,1) = 450;
end

% S0 = [450];
% gamma = [0 0.0002 0.0004];
gamma = [0];
% beta = [0 10];
beta = [0];

% oSaveFigure = 0;
oDoBetaDif = 0;
oDoGammaDif = 0;

resistances = 50:1:200;
Rext = zeros(nUnits, length(resistances));
for i = 1 : nUnits
  Rext(i,:) = resistances;
end


Pout = zeros(nUnits, length(Rext));

fig = figure(1);
% xlabel('External resistance [\Omega]')
% ylabel('MFC power output [W]')
% title('Various power curves of an MFC vs. influent substrate concentration (S0)')
% title('Power curves of an MFC vs. external resistance')
% 
legendString = {};
hold on

T = 0.2;

% mfcDynamics = [20.8395  498.2432    2.0000    0.0412];
% mfcDynamics = [5.726117682433310 0.030299840936202];
mfcDynamics = zeros(nUnits, 2);
for i = 1 : nUnits
  mfcDynamics(i, :) = [5.726117682433310 0.030299840936202];
end
% mfcDynamics = [5.726117682433310 0.030299840936202; 5.726117682433310 0.030299840936202];

% odeOptions = odeset('RelTol',1e-6,'AbsTol',1e-9);
odeOptions = odeset('RelTol',1e-9,'AbsTol',1e-12);

tic
waitBarHandler = waitbar(0);

lengthS0 = size(S0);
for j = 1 : lengthS0(2)
% for j = 1 : length(S0)
  for i = 1 : length(Rext)
    if oDoBetaDif
      [tt, Y] = ode15s('mfcModelFastParallel', [0 T], mfcDynamics, odeOptions, S0(:,j), Rext(:, i) + beta(j), 0);
      mfcDynamics = Y(end, :);

      [dummy, Pout(:,i)] = mfcModelFastParallel(T, mfcDynamics, odeOptions, S0(:,j), Rext(:, i) + beta(j), 1);
    else
      [tt, Y] = ode15s('mfcModelFastParallel', [0 T], mfcDynamics, odeOptions, S0(:,j), Rext(:, i), 0);
      mfcDynamics = Y(end, :);

      [dummy, Pout(:,i)] = mfcModelFastParallel(T, mfcDynamics, odeOptions, S0(:,j), Rext(:, i), 1);
    end
    
    if oDoGammaDif
      Pout(:,i) = Pout(:,i) + gamma(j);
    end

    waitbar(i/length(Rext));
  end
  
%   mfcDynamics = [5.726117682433310 0.030299840936202];
%   mfcDynamics = [5.726117682433310 0.030299840936202; 5.726117682433310 0.030299840936202];
  mfcDynamics = zeros(nUnits, 2);
  for k = 1 : nUnits
    mfcDynamics(k, :) = [5.726117682433310 0.030299840936202];
  end

  figure(fig);
  for k = 1 : nUnits
    plot(Rext(k, :), Pout(k, :))
  end
%   max(Pout);
%   Ropt = Rext(find(Pout >= max(Pout)))
  
  legendStr{j} = ['S_0 = ', num2str(S0(1,j)), ' [mg/L]'];
  legend(legendStr)
end
close(waitBarHandler)
toc

%   fig;
%   for k = 1 : nUnits
%     plot(Rext(k, :), Pout(k, :))
%   end

% if oSaveFigure
%   saveas(fig, 'mfcPowerCurve', 'jpg')
%   saveas(fig, 'mfcPowerCurve', 'fig')
% end