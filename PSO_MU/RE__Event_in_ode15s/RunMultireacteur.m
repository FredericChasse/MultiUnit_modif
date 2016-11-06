clc

clear all
close all
warning off
x0 = [0.0853; 0.1947;0.6924;0.0853; 0.1947;0.6924;0.0853; 0.1947;0.6924; 7; 11]';
% x0=[0.0853
%     0.1947
%     0.6924
%     0.0853
%     0.1947
%     0.6924
%     0.0853
%     0.1947
%     0.6924
%     7.0707
%    11.0008];
Cain=2;
Tf =4;
% Pour éviter les fluctuations, remettre les tolérances à -6 et -9 et Tf à
% 4.5 maximum
intoptions = odeset('RelTol',1e-9,'AbsTol',1e-12,'Events',@constreacteur);
% intoptions = odeset('RelTol',1e-6,'AbsTol',1e-9);
t = []; x = []; xini = x0; tini = 0; hybstate = 0;
while isempty(t) | (max(t) < Tf) 
    [ti,xi,te,xe,ie] = ode45(@multireacteur,[tini,Tf],xini,intoptions,hybstate);
    t = [t; ti]; x = [x; xi]; xini = x(end,:); tini = t(end);
%     keyboard
%     hybstate
%     ie
%     te
%     xe

   % Transition of discrete states
    if (hybstate == 0)
%         keyboard
        if ie == 1, hybstate = 1; elseif ie == 2, hybstate = 2; elseif ie == 3, hybstate = 3;
        elseif ie == 4, hybstate = 4;end
    end
    if (hybstate == 1)
        if ie == 6, hybstate = 0; end
        if ie == 4, hybstate = 0; end
    end
    if (hybstate == 2)
        if ie == 5, hybstate = 0; end
         if ie == 3, hybstate = 0; end
    end
    if (hybstate == 3)
        if ie == 6, hybstate = 0; end
        if ie == 2, hybstate = 0; end
    end
    if (hybstate == 4)
        if ie == 5, hybstate = 0; end
        if ie == 1, hybstate = 0; end
    end
    
    J1=(x(:,10)+x(:,11)).^2.*x(:,3).^2./(x(:,10)*Cain);
    J2=(x(:,10)+0.05+x(:,11)).^2.*x(:,6).^2./((x(:,10)+0.05).*Cain);
    J3=(x(:,10)+x(:,11)+0.05).^2.*x(:,9).^2./(x(:,10).*Cain);
%     J2=(x(10)+deltaFa+x(11))^2*x2(3)^2/(x(10)+deltaFa*Cain);
%     J3=(x(10)+x(11)+deltaFb)^2*x3(3)^2/(x(10)*Cain);
k1  = 1.5;       % l/mol/h
k2  = 0.014;       % l/mol/h
Cain = 2;           % mol/l
Cbin = 1.5;           % mol/l
V    = 500;       % l
dh1  = 7e4;         % J/mol
dh2  = 5e4;        % J/mol
q1=k1.*x(:,1).*x(:,2).*V.*(dh1)+2.*k2.*x(:,2).^2.*V.*dh2;
 q2=k1.*x(:,4).*x(:,5).*V.*(dh1)+2.*k2.*x(:,5).^2.*V.*dh2;
q3=k1.*x(:,7).*x(:,8).*V.*(dh1)+2.*k2.*x(:,8).^2.*V.*dh2;
%     keyboard
    
    
end
% 
% Ca = x(:,1); Ca1 = x(:,4); Ca2 = x(:,7);
% Cb = x(:,2); Cb1 = x(:,5); Cb2 = x(:,8);      
% T=x(:,3); T1=x(:,6);T2=x(:,9);
% D = x(:,10); Tset = x(:,11);
Ca = x(:,1); Ca1 = x(:,4); Ca2 = x(:,7);
Cb = x(:,2); Cb1 = x(:,5); Cb2 = x(:,8);
Cc = x(:,3); Cc1 = x(:,6); Cc2 = x(:,9);
Fa = x(:,10); Fb = x(:,11);
[dxdt, Qall, Jall] = multireacteur(0,x',0);

figure(1), plot(t,J1,t,J2,t,J3),title('J');
figure(2), plot(t,q1,t,q2,t,q3),title('q');
figure(3), plot(t,Fa+Fb);
figure(4), plot(t,Fa),title('Fa');
figure(5), plot(t,Fb),title('Fb');
