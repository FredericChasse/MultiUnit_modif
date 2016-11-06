function [dxdt, Q] = VanderVusse(t,x,u);

% k01  = 5.4e9;       % /h
% k02  = 3.6e5;       % /h
% E1R  = 15840/1.987; % K
% E2R  = 7920/1.987;  % K
% dh1  = -50;         % KJ/mol
% dh2  = -66;        % KJ/mol
% V = 1;
% Cai = 1;       % mol/l
% Parameters
k01  = 5.4e9;       % /h
k02  = 3.6e5;       % /h
k03  = 8e11;        % l/mol h
E1R  = 15840/1.987; % K
E2R  = 7920/1.987;  % K
E3R  = 23760/1.987; % K
dh1  = -84;         % KJ/mol
dh2  = -108;        % KJ/mol
dh3  = -60;         % KJ/mol
rho  = 0.9342;      % kg/l
cp   = 3.01;        % KJ/Kg K
V    = 10.01;       % l
Cain = 1;           % mol/l
Tin  = 150;         % C

Ca = x(1,:);
Cb = x(2,:);
% T=x(3,:);
D = u(1,:);
T = u(2,:);

% dCadt = - k01*exp(-E1R./T).*Ca + (Cai - Ca).*D; 
% dCbdt = k01*exp(-E1R./T).*Ca - k02*exp(-E2R./T).*Cb - D.*Cb;
% 
% dxdt = [dCadt; dCbdt];
% Q = - (k01*exp(-E1R./T).*Ca*dh1 + k02*exp(-E2R./T).*Cb*dh2)*V;


T0 = 273.15;       % K
k1=k01*exp(-E1R./(T+T0));
k2=k02*exp(-E2R./(T+T0));
k3=k03*exp(-E3R./(T+T0));

% Controller - feedback linearization 
% Kp = 10; 
% Q = - (k1.*Ca*dh1 + k2.*Cb*dh2 + k3.*Ca.^2*dh3)*V - D.*(Tin-T).*(rho*cp*V) + Kp.*(Tset-T);
Q = - (k1.*Ca*dh1 + k2.*Cb*dh2 + k3.*Ca.^2*dh3)*V- D.*(Tin-T).*(rho*cp*V);


% keyboard
% Dynamic equations
dCadt = D.*(Cain-Ca) - k1.*Ca - 2*k3.*Ca.^2;
dCbdt = k1.*Ca - k2.*Cb - D.*Cb;
% dTdt  = D.*(Tin-T) + (k1.*Ca.*dh1 + 2.*Cb.*dh2 + k3.*Ca.^2.*dh3)/(rho*cp) + Q./(rho*cp*V);
% dxdt = [dCadt; dCbdt;dTdt];
dxdt = [dCadt; dCbdt];