function [dy, Pout]= mfcModelFast(T, y, dummy, S0, Rext, oStaticFnc)
F = 96485;
R = 8.314472;
T = 298.15;
yield = 22.753;
% Ych4 = .3;
qmax_a = 8.484;
qmax_m = 8.2;
umax_a = 1.9753;
umax_m = .1;
Ks_a = 20;
Ks_m = 80;
m = 2;
gamma = 663400;
Mtotal = .05;
Km = .2*Mtotal;
% Kd_a = .02*umax_a;
% Kd_m = .02*umax_m;
Xmax = 512.5;
Kx = .01*4;
Rmin = 25;
Rmax = 2000 + Rmin;
Emin = .01;
Emax = 0.25 + 0.4144+ Emin;
Kr = .024;

% i0ref=0.4*4;

e = 0.0001*Mtotal;

V = 0.2;
Fin = 0.1527;

D = Fin/V;

Xtot = 500;

% Xeg = 250;
if ~oStaticFnc
  y;
  Xeg = ones(length(y)/2, 1) * 250;
  S   = y(1 : end/2);
  Mox = y(end/2+1 : end);
  xm = Xtot - Xeg;
else
%   sizeY = size(y);
  y = y';
  Xeg = ones(length(y)/2, 1) * 250;
  S   = y(1 : end/2);
  Mox = y(end/2+1 : end);
  xm = Xtot - Xeg;
%   y
%   Xeg = ones(sizeY(1), 1) * 250
%   S   = y(:, 1)
%   Mox = y(:, 2)
%   xm = Xtot - Xeg
%   keyboard
end

% keyboard

%% Équations dynamiques

if oStaticFnc
  
  Mred = Mtotal - Mox;

  Rint = Rmin + (Rmax - Rmin) .* exp(-Kr.*Xeg);                       % (22)
  Eocv = Emin + (Emax - Emin) .* exp(-1./(Kr.*Xeg));                     % (23)

  qa = qmax_a .* S ./ (Ks_a + S) .* Mox ./ (Km + Mox);                   % (15)
  qm = qmax_m .* S ./ (Ks_m + S);                                       % (16)

  temp = Eocv - (R*T/m/F).*abs(log(complex(Mtotal./Mred)));
  Imfc = temp./(Rext+Rint).*Mred./(e+Mred);

  Pout = (temp.*Mred./(e+Mred)-Rint.*Imfc).*Imfc;

  Sp = -qa.*Xeg - qm.*xm + D.*(S0 - S);                                  % (6)

  Moxp = -yield.*qa + gamma.*Imfc ./ (m*F*V.*Xeg) .* 86400;                 % (12)

  % dy = [Sp; Moxp]';
  dy = [Sp; Moxp];
  
else
  
  Mred = Mtotal - Mox;

  Rint = Rmin + (Rmax - Rmin) .* exp(-Kr.*Xeg);                       % (22)
  Eocv = Emin + (Emax - Emin) .* exp(-1./(Kr.*Xeg));                     % (23)

  qa = qmax_a .* S ./ (Ks_a + S) .* Mox ./ (Km + Mox);                    % (15)
  qm = qmax_m .* S ./ (Ks_m + S);                                       % (16)

  temp = Eocv - (R*T/m/F).*abs(log(complex(Mtotal./Mred)));
  Imfc = temp./(Rext+Rint).*Mred./(e+Mred);

  Pout = (temp.*Mred./(e+Mred)-Rint.*Imfc).*Imfc;

  Sp = -qa.*Xeg - qm.*xm + D.*(S0 - S);                                   % (6)

  Moxp = -yield.*qa + gamma.*Imfc ./ (m*F*V.*Xeg) .* 86400;                 % (12)

  % dy = [Sp; Moxp]';
  dy = [Sp; Moxp];
  
%   keyboard
  
end
