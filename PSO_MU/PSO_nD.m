%% clear variables and close figures
clear all

if ( ~exist('rngState', 'var') )
  rngState = rng;
end
clearvars -except rngState
rng(rngState);

close all
% clc

oFigures = 1;   %% 0 = don't print figures

%% Simulation parameters

nIterations = 100;
nParticles  = 8;

omega = 0.5;

% For test purposes
ni = zeros(nIterations, 1);
for iData = 1 : nIterations
  ni(iData) = iData;
end

% Search space
dmin        = 10;
dmax        = 200;

% RextResolution = (dmax-dmin)/255; % Ohms
RextResolution = 0.1; % Ohms
Rvalues = dmin:RextResolution:dmax;

% Steady-state precision
ssPrecision = 0.05;   % 5% precision for calculating steady-state


% Environment change
detectPrecision = 0.01;   % 5% precision
oChangeHasOccured = 0;    % Flag for detecting change

% Dimension
dim = 3;
for iDim = 1 : dim
  beta (iDim) = rand * 40 - 20;
  gamma(iDim) = rand * 7 - 3.5;
end
% beta  = [0 -10 5  13  0 0 2 -3  5 1 0 0];
% gamma = [0 -1  2 -3  -1 2 4  0 13 0 0 0];
% if length(beta) ~= length(gamma)
%   error('Beta and Gamma don''t have the same length')
% end
% dim = length(beta);

% Simulation data
d           = zeros(nIterations, nParticles, dim);
J           = zeros(nIterations, nParticles);
Jsingle     = zeros(nIterations, nParticles, dim);
MaxVal      = zeros(nIterations, nParticles);
Pbest       = zeros(nIterations, nParticles, dim);
v           = zeros(nIterations, nParticles, dim);

MaxOfUnits  = zeros(nIterations, 1);
Gbest       = zeros(nIterations, dim);
c           = zeros(nIterations, 2);

% Initial position of particles
for iUnit = 1 : nParticles
  for iDim = 1 : dim
    d(1, iUnit,iDim) = rand* (dmax-dmin) + dmin;
  end
%   tmp = abs(Rvalues - d(1, iUnit));
%   [idx idx] = min(tmp);
%   d(1, iUnit) = Rvalues(idx);
end

c(:,1) = 1.1;
c(:,2) = 2;

%% Simulation
tic
waitBarHandler = waitbar(0);
for iData = 1 : nIterations

  waitbar(iData/nIterations);
  
  % Curve (J)
  %========================================================================
  for iUnit = 1 : nParticles
    J(iData, iUnit) = 0;
    for iDim = 1 : dim
      Jsingle(iData, iUnit, iDim) = -0.002 * (d(iData, iUnit, iDim) - 100 + beta(iDim))^2 + 20 + gamma(iDim);
      J(iData, iUnit) = J(iData, iUnit) + Jsingle(iData, iUnit, iDim);
    end
%     J(iData, iUnit) = Jsingle(iData, iUnit, 1) + Jsingle(iData, iUnit, 2) + Jsingle(iData, iUnit, 3);
%     J(iData, iUnit) = -0.002 * (d(iData, iUnit, 1) - 100)^2 + 20   ...
%                     + -0.002 * (d(iData, iUnit, 2) - 110)^2 + 19;
  end
%   for iUnit = 1 : nParticles
%     
%     if (iUnit > 4) && (oDoBetaDif)
%       [tt, Y] = ode15s('mfcModelFast', [0 T], mfcDynamics(iUnit, :), odeOptions, S0(iUnit, iData), d(iData, iUnit) + beta);
%       mfcDynamics(iUnit,:) = Y(end, :);
%       [dummy, J(iData, iUnit)] = mfcModelFast(T, mfcDynamics(iUnit, :), odeOptions, S0(iUnit, iData), d(iData, iUnit) + beta);
%     else
%       [tt, Y] = ode15s('mfcModelFast', [0 T], mfcDynamics(iUnit, :), odeOptions, S0(iUnit, iData), d(iData, iUnit));
%       mfcDynamics(iUnit,:) = Y(end, :);
%       [dummy, J(iData, iUnit)] = mfcModelFast(T, mfcDynamics(iUnit,:), odeOptions, S0(iUnit, iData), d(iData, iUnit));
%     end
%     
%     if (iUnit > 4) && (oDoGammaDif)
%       J(iData, iUnit) = J(iData, iUnit) + gamma;
%     end
%   end
  %========================================================================

  % Global max values
  %========================================================================
  MaxOfUnits(iData) = max( J(iData, :) );
  %========================================================================

  % Local max values
  %========================================================================
  if (iData == 1)
    for iUnit = 1 : nParticles
      MaxVal(1, iUnit) = J(1, iUnit);
    end
  else
    for iUnit = 1 : nParticles
      MaxVal(iData, iUnit) = max( J(iData - 1 : iData, iUnit) );
%       MaxVal(iData, iUnit) = max( J(iData, iUnit), MaxVal(iData - 1, iUnit) );
    end
  end
  %========================================================================

  % Particle best (Pbest)
  %========================================================================
  if (iData == 1)
    for iUnit = 1 : nParticles
      Pbest(1, iUnit, :) = d(1, iUnit, :);
    end
  else
    for iUnit = 1 : nParticles
      if ( MaxVal(iData, iUnit) == J(iData, iUnit) )
        Pbest(iData, iUnit, :) = d(iData, iUnit, :);
      else
        Pbest(iData, iUnit, :) = Pbest(iData - 1, iUnit, :);
      end
    end
  end
  %========================================================================

  % Global best (Gbest)
  %========================================================================
  for iUnit = 1 : nParticles
%     if ( iData == 1)
      if ( MaxOfUnits(iData) == J(iData, iUnit) )
        Gbest(iData, :) = d(iData, iUnit, :);
      end
%     else
%       if ( MaxOfUnits(iData) == J(iData, iUnit) )
%         Gbest(iData) = d(iData, iUnit);
%         if ( Gbest(iData) < Gbest(iData - 1) )
%           Gbest(iData) = Gbest(iData - 1);
%         end
%       end
%     end
  end
  %========================================================================

  % Acceleration coefficients (c)
  %========================================================================
%   if (iData == 1)
%       c(1,1) = 2;   % Cognitive
%       c(1,2) = 1;     % Social
%   else
%       c(iData,1) = c(iData - 1,1) + 1/nIterations;
%       c(iData,2) = c(iData - 1,2) - 1/nIterations;
%   end
  %========================================================================
  
  % Environment change detection
  %========================================================================
%   if (iData > 3)
%     for iUnit = 1 : nParticles
%       % If no change has occured on the particle's position
%       if ( d(iData, iUnit) == d(iData - 1, iUnit) )
%         % If the particle's objective function is not the same as before
%         if ( abs(J(iData, iUnit) - J(iData - 1, iUnit)) / J(iData - 1, iUnit) >= detectPrecision )
%           oChangeHasOccured = 1;
%         else
%           oChangeHasOccured = 0;
%         end
%       end
%       if (oChangeHasOccured)
%         break;
%       end
%     end
%   end
  %========================================================================
  
  % Particles' velocities (v)
  %========================================================================
  if (iData == 1)
    for iUnit = 1 : nParticles
      for iDim = 1 : dim
        v(iData, iUnit,iDim) = rand                                                                      ...
                            + c(iData, 1) * rand * (Pbest(iData, iUnit, iDim)  - d(iData, iUnit, iDim))   ...
                            + c(iData, 2) * rand * (Gbest(iData, iDim)         - d(iData, iUnit, iDim));
      end
%       v(iData, iUnit,2) = rand                                                           ...
%                         + c(iData, 1) * rand * (Pbest(iData, iUnit, 2)  - d(iData, iUnit, 2))  ...
%                         + c(iData, 2) * rand * (Gbest(iData, 2)         - d(iData, iUnit, 2));
%       v(iData, iUnit,3) = rand                                                           ...
%                         + c(iData, 1) * rand * (Pbest(iData, iUnit, 3)  - d(iData, iUnit, 3))  ...
%                         + c(iData, 2) * rand * (Gbest(iData, 3)         - d(iData, iUnit, 3));
    end
  else
    for iUnit = 1 : nParticles
      for iDim = 1 : dim
        v(iData, iUnit, iDim) = round                                                         ...
                        ( omega*v(iData-1, iUnit, iDim)                                       ...
                        + c(iData, 1) * rand * (Pbest(iData, iUnit, iDim)  - d(iData, iUnit, iDim)) ...
                        + c(iData, 2) * rand * (Gbest(iData, iDim)         - d(iData, iUnit, iDim)) ...
                        , 4);
      end
%       v(iData, iUnit, 2) = round                                                         ...
%                       ( omega*v(iData-1, iUnit, 2)                                       ...
%                       + c(iData, 1) * rand * (Pbest(iData, iUnit, 2)  - d(iData, iUnit, 2)) ...
%                       + c(iData, 2) * rand * (Gbest(iData, 2)         - d(iData, iUnit, 2)) ...
%                       , 4);
%       v(iData, iUnit, 3) = round                                                         ...
%                       ( omega*v(iData-1, iUnit, 3)                                       ...
%                       + c(iData, 1) * rand * (Pbest(iData, iUnit, 3)  - d(iData, iUnit, 3)) ...
%                       + c(iData, 2) * rand * (Gbest(iData, 3)         - d(iData, iUnit, 3)) ...
%                       , 4);
    end
  end
  %========================================================================

  % Particles' positions (d)
  %========================================================================
  if (iData ~= nIterations)
    if (~oChangeHasOccured)
      for iUnit = 1 : nParticles
        nextPos = d(iData, iUnit, :) + v(iData, iUnit, :);
%         tmp = abs(Rvalues - nextPos);
%         [idx idx] = min(tmp);
%         nextPos = Rvalues(idx);
        for iDim = 1 : dim
          if ( nextPos(iDim) < dmin )
            d(iData + 1, iUnit, iDim) = dmin;
          elseif ( nextPos(iDim) > dmax )
            d(iData + 1, iUnit, iDim) = dmax;
          else
            d(iData + 1, iUnit, iDim) = nextPos(iDim);
          end
        end
%         if ( nextPos(1) < dmin )
%           d(iData + 1, iUnit, 1) = dmin;
%         elseif ( nextPos(1) > dmax )
%           d(iData + 1, iUnit, 1) = dmax;
%         else
%           d(iData + 1, iUnit, 1) = nextPos(1);
%         end
%         if ( nextPos(2) < dmin )
%           d(iData + 1, iUnit, 2) = dmin;
%         elseif ( nextPos(2) > dmax )
%           d(iData + 1, iUnit, 2) = dmax;
%         else
%           d(iData + 1, iUnit, 2) = nextPos(2);
%         end
%         if ( nextPos(3) < dmin )
%           d(iData + 1, iUnit, 3) = dmin;
%         elseif ( nextPos(3) > dmax )
%           d(iData + 1, iUnit, 3) = dmax;
%         else
%           d(iData + 1, iUnit, 3) = nextPos(3);
%         end
      end
    else
%       for iUnit = 1 : nParticles
% %         nextPos = rand* (dmax-dmin) + dmin;
%         nextPos = d(iData, iUnit) + (rand*100 -50);
%         tmp = abs(Rvalues - nextPos);
%         [idx idx] = min(tmp);
%         d(iData + 1, iUnit) = Rvalues(idx);
%         if ( nextPos < dmin )
%           d(iData + 1, iUnit) = dmin;
%         elseif ( nextPos > dmax )
%           d(iData + 1, iUnit) = dmax;
%         else
%           d(iData + 1, iUnit) = nextPos;
%         end
%         
%         MaxVal(iData, iUnit) = 0;
%         Pbest(iData, iUnit) = d(iData + 1, iUnit);
%         v(iData, iUnit) = 0;
%       end
%       MaxOfUnits(iData) = 0;
%       Gbest(iData) = d(iData + 1, 1);
%       c(iData, 1) = c(1, 1);
%       c(iData, 2) = c(1, 2);
%       oChangeHasOccured = 0;
    end
  end
  %========================================================================
  
end
toc
close(waitBarHandler)
    
%% Steady-state

iSteadyState = nIterations + 1;

% if oDoPerturbStatic || oDoPerturbDynamic
%   iStart = iPerturb;
% else
  iStart = 1;
% end

for iData = iStart : nIterations

  meanD = mean(d(iData:end,:,:));
    
  for jData = iData : nIterations
    if ( mean( (d(jData,:, :) <= (1 + ssPrecision).*meanD) & (d(jData,:, :) >= (1 - ssPrecision).*meanD) ) ~= 1 )
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
  iSteadyState = iSteadyState - iStart
else
  iSteadyState
end

%% Figures

if (oFigures)
  for iUnit = 1 : nParticles
    n = num2str(iUnit);
    Jstr(iUnit) = {strcat('J',n)};
    dstr(iUnit) = {strcat('d',n)};
    istr(iUnit) = {['Particule ' num2str(n)]};
  end

%   fig1 = figure(1);
%   subplot(2,1,1)
%   for iUnit = 1 : nParticles
%     plot(J(:,iUnit))
%     hold on
%   end
%   legend(Jstr)
%   hold off
%   
%   subplot(2,1,2)
%   for iUnit = 1 : nParticles
%     plot(d(:,iUnit))
%     hold on
%   end

%   fig = figure;
% %   hold on
%   Rfig = dmin:10:dmax;
%   for i = 1:length(Rfig)
%     for j = 1:length(Rfig)
%       jfig(j,i) = -0.002 * (Rfig(i) - 100)^2 + 20 + -0.002*(Rfig(j)-110)^2+19;
%     end
%   end
%   surf(Rfig,Rfig,jfig)
%   hold on
%   for iUnit = 1 : nParticles
% %     surf(d(:,iUnit,1), d(:,iUnit,2), J(:,iUnit));
%     plot3(d(:,iUnit,1), d(:,iUnit,2), J(:,iUnit), 'LineWidth', 2);
%   end
%   legend(dstr)
%   hold off
end


%% Old figures

% if (oFigures)
%   for iUnit = 1 : nParticles
%     n = num2str(iUnit);
%     Jstr(iUnit) = {strcat('J',n)};
%     dstr(iUnit) = {strcat('d',n)};
%     istr(iUnit) = {['Particule ' num2str(n)]};
%   end
% 
%   fig1 = figure(1);
%   hold on
%   for iUnit = 1 : nParticles
%     plot(J(:,iUnit))
%   end
%   legend(Jstr)
% 
%   fig2 = figure(2);
%   hold on
%   for iUnit = 1 : nParticles
%     plot(d(:,iUnit))
%   end
%   legend(dstr)
%   pos2 = fig2.Position;
%   fig2.Position = [pos2(1) 100 pos2(3) pos2(4)];
% 
%   fig3 = figure(3);
%   hold on
%   for iUnit = 1 : nParticles
%     plot(d(:,iUnit), J(:,iUnit), '.')
%   end
%   legend(istr)
%   pos3 = fig3.Position;
%   fig3.Position = [1860 pos3(2) pos3(3) pos3(4)];;
% 
%   fig4 = figure(4);
%   hold on
%   for iUnit = 1 : nParticles
%     plot(d(:,iUnit), J(:,iUnit))
%   end
%   legend(istr)
%   pos4 = fig4.Position;
%   fig4.Position = [1860 100 pos4(3) pos4(4)];
% end

%% Tests after run
% format short g
% d(1,:)
% d(end,:)
% [ni d]
% [ni Gbest Pbest]
% d;
% J;
% vJ = [v J]
% Jopt