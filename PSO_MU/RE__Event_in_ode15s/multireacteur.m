function [dxdt, Qall, Jall] = multireacteur(t,x,hybstate);
qmax = 1000000;
Fmax=22;
Cain=2;
% gainFb = 0.001;
% gainFa = 0.001;
gainq2=0.004;
gainq3=0.004;
gainFa=0.1;
gainFb=0.1;
deltaFa=0.1;
deltaFb=0.1;
alphaFa = 10/deltaFa;
alphaFb = 10/deltaFb;
x1 = x(1:3,:); 
x2 = x(4:6,:); 
x3 = x(7:9,:);
Fa = x(10,:);
Fb = x(11,:);

[dx1dt, q1] = reacteur(t,x1,[Fa; Fb]);
[dx2dt, q2] = reacteur(t,x2,[Fa+deltaFa; Fb]);
[dx3dt, q3] = reacteur(t,x3,[Fa; Fb+deltaFb]);
J1=(x(10)+x(11))^2*x1(3)^2/(x(10)*Cain);
J2=(x(10)+deltaFa+x(11))^2*x2(3)^2/((x(10)+deltaFa)*Cain);
J3=(x(10)+x(11)+deltaFb)^2*x3(3)^2/(x(10)*Cain);

switch(hybstate)
    case 0
        dFadt = alphaFa*(J2-J1);
        dFbdt = alphaFb*(J3-J1);
%         keyboard
    case 1
        M = [(q2-q1)/deltaFa (q3-q1)/deltaFb];
        pinvM = M'/(M(1)^2+M(2)^2);
        P = eye(2) - pinvM*M;
        g = [(J2-J1)/deltaFa  (J3-J1)/deltaFb];
        alpha=alphaFb/10;
        kx = gainq2*1e3*10;
       
        corr =  alpha*P'*g' + kx*pinvM*(qmax-q2);

        dFadt =corr(1);
        dFbdt =corr(2);
%         
%         dFadt = gainq2*(qmax-q2);
%         dFbdt = alphaFb*((J3-J1) - (q3-q1).*(J2-J1)./(q2-q1));
%         keyboard
    case 2
        M = [(q2-q1)/deltaFa (q3-q1)/deltaFb];
        pinvM = M'/(M(1)^2+M(2)^2);
        P = eye(2) - pinvM*M;
        g = [(J2-J1)/deltaFa  (J3-J1)/deltaFb];
        alpha=alphaFb/10;
        kx = gainq3*8*10;
        
        corr =  alpha*P'*g' - kx*pinvM*(qmax-q3);

        dFadt =corr(1);
        dFbdt =corr(2);
%         
%         dFadt = alphaFa*((J2-J1) - (q2-q1).*(J3-J1)./(q3-q1));
%         dFbdt = gainq3*(qmax-q3);
        keyboard
    case 3
%         if t>2

%         keyboard
%         end
        M = [(deltaFa)/deltaFa (deltaFb)/deltaFb];
        pinvM = M'/(M(1)^2+M(2)^2);
        P = eye(2) - pinvM*M;
        g = [(J2-J1)/deltaFa  (J3-J1)/deltaFb];
        alpha=alphaFb/10;
        kx = gainq3*8;
          alpha=alphaFb/10;
        kx = gainq2*1e3;
        corr =  alpha*P'*g' + kx*pinvM*(Fmax-(Fa+Fb+deltaFa));

        dFadt =corr(1);
        dFbdt =corr(2);
        
%         dFadt = gainFa*(Fmax-(x(10)+deltaFa+x(11)));
%         dFbdt = alphaFb*((J3-J1) - (deltaFb).*(J2-J1)./(deltaFa));
    case 4
        keyboard
        M = [(deltaFa)/deltaFa (deltaFb)/deltaFb];
        pinvM = M'/(M(1)^2+M(2)^2);
        P = eye(2) - pinvM*M;
        g = [(J2-J1)/deltaFa  (J3-J1)/deltaFb];
          alpha=alphaFb/40;
        kx = gainq2/10;
        
        corr =  alpha*P'*g' - kx*pinvM*(Fmax-(Fa+Fb+deltaFa));

        dFadt =corr(1);
        dFbdt =corr(2);
         
%         dFadt = alphaFa*((J2-J1) - (deltaFa).*(J3-J1)./(deltaFb));
%         dFbdt = gainFb*(Fmax-(x(10)+x(11)+deltaFb));
end

dxdt = [dx1dt; dx2dt; dx3dt; dFadt; dFbdt];
Qall = [q1; q2; q3];
Jall = [J1; J2; J3];
 
