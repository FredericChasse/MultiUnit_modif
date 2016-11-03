% clear all
close all

Rext = 50:1:200;
% Rext = 50:1:200;
% Rext = 50:1000/255:400;

% S0 = [250 300 350 400 450 500 550 600 650 700];
S0 = [450];
% gamma = [0 0.0002 0.0004];
gamma = [0];
% beta = [0 10];
beta = [0];

% oSaveFigure = 0;
oDoBetaDif = 0;
oDoGammaDif = 0;

Pout = zeros(1, length(Rext));

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
mfcDynamics = [5.726117682433310 0.030299840936202];

% odeOptions = odeset('RelTol',1e-6,'AbsTol',1e-9);
odeOptions = odeset('RelTol',1e-9,'AbsTol',1e-12);

tic
waitBarHandler = waitbar(0);
for j = 1 : length(S0)
  for i = 1 : length(Rext)
    if oDoBetaDif
      [tt, Y] = ode15s('mfcModelFast', [0 T], mfcDynamics, odeOptions, S0(j), Rext(i) + beta(j));
      mfcDynamics = Y(end, :);

      [dummy, Pout(i)] = mfcModelFast(T, mfcDynamics, odeOptions, S0(j), Rext(i) + beta(j));
    else
      [tt, Y] = ode15s('mfcModelFast', [0 T], mfcDynamics, odeOptions, S0(j), Rext(i));
      mfcDynamics = Y(end, :);

      [dummy, Pout(i)] = mfcModelFast(T, mfcDynamics, odeOptions, S0(j), Rext(i));
    end
    
    if oDoGammaDif
      Pout(i) = Pout(i) + gamma(j);
    end

    waitbar(i/length(Rext));
  end
  
  mfcDynamics = [5.726117682433310 0.030299840936202];

  plot(Rext, Pout)
  max(Pout);
  Ropt = Rext(find(Pout >= max(Pout)))
  
  legendStr{j} = ['S_0 = ', num2str(S0(j)), ' [mg/L]'];
  legend(legendStr)
end
close(waitBarHandler)
toc

% if oSaveFigure
%   saveas(fig, 'mfcPowerCurve', 'jpg')
%   saveas(fig, 'mfcPowerCurve', 'fig')
% end