clear all
close all
format short g

nUnits = 8;
s0 = zeros(1,nUnits);

s0min = 300;
s0max = 700;
rmin = 10;
rmax = 500;
deltaR = (rmax-rmin)/nUnits;

for iUnit = 1 : nUnits
  s0(iUnit) = rand*(s0max-s0min)+s0min;
end
% s0(1:5) = 300;
% s0(6:10) = 700;

nRotations = 3;
rotSize = round(nUnits/nRotations);

pos = zeros(nRotations, nUnits);
sortPos = zeros(nRotations, nUnits);
pos(1,1) = rmin;
for i = 2:nUnits
  pos(1,i) = pos(1, i-1)+deltaR;
end

for i = 2 : nRotations
  pos(i, :) = circshift(pos(i-1,:), rotSize, 2);
end

Pout = zeros(nRotations, nUnits);
sortPout = zeros(nRotations, nUnits);

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

colors = {'r', 'b', 'k', 'm', 'g', 'y'};
lgdStr = {};
for i = 1 : nRotations
  lgdStr(i) = {num2str(i)};
end

tic

figure
hold on
waitBarHandler = waitbar(0);
for i = 1 : nRotations
  for j = 1 : nUnits
    [tt, Y] = ode15s('mfcModelFast', [0 T], mfcDynamics(j, :), odeOptions, s0(j), pos(i, j));
    mfcDynamics(j,:) = Y(end, :);
    [dummy, Pout(i, j)] = mfcModelFast(T, mfcDynamics(j, :), odeOptions, s0(j), pos(i, j));

    waitbar(j/nUnits);
  end
  
  [sortPos(i, :), idx] = sort(pos(i, :));
  sortPout(i,:) = Pout(i, idx);
  plot(sortPos(i,:), sortPout(i,:), colors{i})
end

legend(lgdStr{:})

% figure(1)
% hold on
% for i = 1 : nUnits
%   plot(pos(i), Pout(1,i), 'o')
% end
% 
% for j = 1 : nUnits
%   [tt, Y] = ode15s('mfcModelFast', [0 T], mfcDynamics(j, :), odeOptions, s0(j), pos2(j));
%   mfcDynamics(j,:) = Y(end, :);
%   [dummy, Pout(2, j)] = mfcModelFast(T, mfcDynamics(j, :), odeOptions, s0(j), pos2(j));
% 
%   waitbar(j/nUnits);
% end
% 
% [pos2, idx] = sort(pos2);
% Pout(2,:) = Pout(2, idx);
% 
% figure(2)
% hold on
% for i = 1 : nUnits
%   plot(pos2(i), Pout(2,i), 'o')
% end

cellStr = ['A' num2str(nRotations+1)];
xlswrite('C:\Users\dr3F\Documents\GitHub\MultiUnit_modif\PSO_MU\PSOnD\Misc\AberrantDataTest\test.xlsx', pos, 'original');
xlswrite('C:\Users\dr3F\Documents\GitHub\MultiUnit_modif\PSO_MU\PSOnD\Misc\AberrantDataTest\test.xlsx', Pout, 'original', cellStr);
xlswrite('C:\Users\dr3F\Documents\GitHub\MultiUnit_modif\PSO_MU\PSOnD\Misc\AberrantDataTest\test.xlsx', sortPos, 'sorted');
xlswrite('C:\Users\dr3F\Documents\GitHub\MultiUnit_modif\PSO_MU\PSOnD\Misc\AberrantDataTest\test.xlsx', sortPout, 'sorted', cellStr);
xlswrite('C:\Users\dr3F\Documents\GitHub\MultiUnit_modif\PSO_MU\PSOnD\Misc\AberrantDataTest\test.xlsx', s0, 's0');

% legendStr{j} = ['S_0 = ', num2str(s0(j)), ' [mg/L]'];
% legend(legendStr)
close(waitBarHandler)
toc

s0
sort(s0)