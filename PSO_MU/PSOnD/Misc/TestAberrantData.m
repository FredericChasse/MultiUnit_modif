clear all
close all

nUnits = 10;
s0 = zeros(1,nUnits);

s0min = 300;
s0max = 700;
rmin = 10;
rmax = 500;

for iUnit = 1 : nUnits
  s0(iUnit) = rand*(s0max-s0min)+s0min;
end
% s0(1:5) = 300;
% s0(6:10) = 700;

pos1 = zeros(1, nUnits);
pos2 = zeros(1, nUnits);
pos1(1) = rmin;
deltaR = (rmax-rmin)/nUnits;
for i = 2:nUnits
  pos1(i) = pos1(i-1)+deltaR;
end

pos1(:) = 300;

pos2(1:3) = pos1(4:6);
pos2(4:6) = pos1(1:3);
pos2(7:8) = pos1(9:10);
pos2(9:10) = pos1(7:8);

pos2(:) = 500;

Pout = zeros(2, nUnits);

% fig = figure(1);
% xlabel('External resistance [\Omega]')
% ylabel('MFC power output [W]')
% title('Various power curves of an MFC vs. influent substrate concentration (S0)')
% title('Power curves of an MFC vs. external resistance')
% 

T = .1;

% mfcDynamics = [20.8395  498.2432    2.0000    0.0412];
mfcDynamics = zeros(nUnits, 2);
mfcDynamics(:,1) = 5.726117682433310;
mfcDynamics(:,2) = 0.030299840936202;

% odeOptions = odeset('RelTol',1e-6,'AbsTol',1e-9);
odeOptions = odeset('RelTol',1e-9,'AbsTol',1e-12);

tic
waitBarHandler = waitbar(0);
for j = 1 : nUnits
  [tt, Y] = ode15s('mfcModelFast', [0 T], mfcDynamics(j, :), odeOptions, s0(j), pos1(j));
  mfcDynamics(j,:) = Y(end, :);
  [dummy, Pout(1, j)] = mfcModelFast(T, mfcDynamics(j, :), odeOptions, s0(j), pos1(j));

  waitbar(j/nUnits);
end

figure(1)
hold on
for i = 1 : nUnits
  plot(pos1(i), Pout(1,i), 'o')
end

for j = 1 : nUnits
  [tt, Y] = ode15s('mfcModelFast', [0 T], mfcDynamics(j, :), odeOptions, s0(j), pos2(j));
  mfcDynamics(j,:) = Y(end, :);
  [dummy, Pout(2, j)] = mfcModelFast(T, mfcDynamics(j, :), odeOptions, s0(j), pos2(j));

  waitbar(j/nUnits);
end

[pos2, idx] = sort(pos2);
Pout(2,:) = Pout(2, idx);

figure(2)
hold on
for i = 1 : nUnits
  plot(pos2(i), Pout(2,i), 'o')
end


% legendStr{j} = ['S_0 = ', num2str(s0(j)), ' [mg/L]'];
% legend(legendStr)
close(waitBarHandler)
toc