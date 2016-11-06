function [dxdt,q] = reacteur(t,x,u)

% This file contains the dynamics of the VanderVusse reaction 
% A -> B -> C, 2A -> D
% The reaction takes place in a continuous stirred tank reactor
% The reactions are endothermic and heated using a coil with power Q
% Dynamics of the temperature in the reactor are considered 

% The reactor temperature set point is as a manipulated variable
% A feedback linearization-based controller is used for temperature control

% Inputs
Fa = u(1);           % Flow of A
Fb = u(2);        % Flow of B

% States
Ca = x(1);          % Concentration of A
Cb = x(2);          % Concentration of B
Cc = x(3);           % Temperature of the reactor

% Parameters
k1  = 1.5;       % l/mol/h
k2  = 0.014;       % l/mol/h
Cain = 2;           % mol/l
Cbin = 1.5;           % mol/l
V    = 500;       % l
dh1  = 7e4;         % J/mol
dh2  = 5e4;        % J/mol


% Dynamic equations
dCadt = Fa*Cain- (Fa+Fb)*Ca - k1*Ca*Cb*V;
dCbdt = Fb*Cbin- (Fa+Fb)*Cb - k1*Ca*Cb*V -2*k2*Cb^2*V;
dCcdt = -(Fa+Fb)*Cc + k1*Ca*Cb*V;

dxdt = [dCadt; dCbdt; dCcdt];    % Derivatives
q=k1*Ca*Cb*V*(dh1)+2*k2*Cb^2*V*dh2;
% % Computing the gradients for optimization 
% % with respect to all the five variables
% % 
% % First compute the derivative of k1-k3 with respect to T
% dk1dT = k1*(E1R/(T+T0)^2); dk2dT = k2*(E2R/(T+T0)^2); dk3dT = k3*(E3R/(T+T0)^2);
% % 
% % Gradients of the system equations 
% ddxdt = [(Cain-Ca)        0         (-D-k1-4*k3*Ca)     0    (-dk1dT*Ca - 2*dk3dT*Ca^2)
%           -Cb             0               k1         (-k2-D)    (dk1dT*Ca - dk2dT*Cb) 
%            0        Kp/(rho*cp*V)         0             0        -Kp/(rho*cp*V)  ];
% 
% % Gradients of Q
% dQdD = -(Tin-T)*(rho*cp*V); dQdTset = Kp;
% dQdCa = (-k1*dh1-k3*Ca*dh3)*V;  dQdCb = -k2*dh2*V;
% dQdT = - (dk1dT*Ca*dh1 + dk2dT*Cb*dh2 + dk3dT*Ca^2*dh3)*V + D*(rho*cp*V) - Kp;
% dQ = [dQdD dQdTset dQdCa dQdCb dQdT];
