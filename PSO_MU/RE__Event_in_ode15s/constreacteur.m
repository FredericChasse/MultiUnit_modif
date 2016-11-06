function [value, isterminal, direction] = constreacteur(t,x,hybstate);

qmax = 1000000;
Fmax=22;
deltaFa=0.05;
deltaFb=0.05;
alphaFa = 5/deltaFa;
alphaFb = 5/deltaFb;
Cain=2;

x1 = x(1:3,:); J1 = x1(2,:);
x2 = x(4:6,:); J2 = x2(2,:);
x3 = x(7:9,:); J3 = x3(2,:);
Fa = x(10,:);
Fb = x(11,:);
[dx1dt, q1] = reacteur(t,x1,[Fa; Fb]);
[dx2dt, q2] = reacteur(t,x2,[Fa+deltaFa; Fb]);
[dx3dt, q3] = reacteur(t,x3,[Fa; Fb+deltaFb]);
J1=(x(10)+x(11))^2*x1(3)^2/(x(10)*Cain);
J2=(x(10)+deltaFa+x(11))^2*x1(3)^2/(x(10)+deltaFa*Cain);
J3=(x(10)+x(11)+deltaFb)^2*x1(3)^2/(x(10)*Cain);
% value = [q2-(0.99*qmax); q3-qmax; x(10)+x(11)+deltaFa-(0.99*Fmax);x(10)+x(11)+deltaFb-(400*Fmax);J1-J2; J1-J3];
value = [q2-(qmax); q3-qmax; x(10)+x(11)+deltaFa-(Fmax);x(10)+x(11)+deltaFb-(400*Fmax);J1-J2; J1-J3];
if hybstate == 0
    isterminal = [1; 1; 1;1;0; 0];
elseif hybstate == 1
    isterminal = [0; 0; 0;1;0; 1];
elseif hybstate == 2
    isterminal = [0; 0;1;0; 1; 0];
elseif hybstate == 3
    isterminal = [0; 1; 0;0;1; 1];
elseif hybstate == 4
    isterminal = [1; 0;0;0; 1; 0];
end
direction = [0; 0;0;0; 0; 0];


