clear all
close all

beta2  =  0;
beta3  =  0;
gamma2 = -2;
gamma3 =  2;

Dopt(1) = 100;
Jopt(1) = 20;
Dopt(2) = 100 - beta2;
Jopt(2) = 20  + gamma2;
Dopt(3) = 100 - beta3;
Jopt(3) = 20  + gamma3;

a = -0.002;

RextMax = 200;
RextMin = 10;

Rfig = RextMin:.1:RextMax;

Rfig = RextMin:.1:RextMax;
Jfig1 = a .* (Rfig - Dopt(1)).^2 + Jopt(1);
Jfig2 = a .* (Rfig - Dopt(2)).^2 + Jopt(2);
Jfig3 = a .* (Rfig - Dopt(3)).^2 + Jopt(3);


% subplot(3,1,3)
figure
r1 = find(Rfig <= 20 & Rfig >= 20);
r2 = find(Rfig <= 30 & Rfig >= 30);
r3 = find(Rfig <= 40 & Rfig >= 40);
r4 = find(Rfig <= 25 & Rfig >= 25);
r5 = find(Rfig <= 35 & Rfig >= 35);
r6 = find(Rfig <= 45 & Rfig >= 45);
r7 = find(Rfig <= 70 & Rfig >= 70);
r8 = find(Rfig <= 80 & Rfig >= 80);
r9 = find(Rfig <= 90 & Rfig >= 90);
plot(Rfig, Jfig1, Rfig, Jfig2, Rfig, Jfig3)
hold on
% plot(Rfig(r1), Jfig1(r1), 'o')
% plot(Rfig(r2), Jfig2(r2), 'o')
% plot(Rfig(r3), Jfig3(r3), 'o')
% plot(Rfig(r4), Jfig1(r4), '*')
% plot(Rfig(r5), Jfig2(r5), '*')
% plot(Rfig(r6), Jfig3(r6), '*')
% plot(Rfig(r7), Jfig1(r7), 's')
% plot(Rfig(r8), Jfig2(r8), 's')
% plot(Rfig(r9), Jfig3(r9), 's')

%%

syms aa uu jj
% sys = solve(Jfig1(r1)==aa*(Rfig(r1)-uu)^2+jj, ...
%             Jfig2(r2)==aa*(Rfig(r2)-uu)^2+jj, ...
%             Jfig3(r3)==aa*(Rfig(r3)-uu)^2+jj, ...
%             aa, uu, jj);
% aa1 = double(sys.aa)
% uu1 = double(sys.uu)
% jj1 = double(sys.jj)
% 
% Jfig4 = aa1 .* (Rfig - uu1).^2 + jj1;
% % plot(Rfig, Jfig4)
% 
% sys = solve(Jfig1(r4)==aa*(Rfig(r4)-uu)^2+jj, ...
%             Jfig2(r5)==aa*(Rfig(r5)-uu)^2+jj, ...
%             Jfig3(r6)==aa*(Rfig(r6)-uu)^2+jj, ...
%             aa, uu, jj);
% aa2 = double(sys.aa)
% uu2 = double(sys.uu)
% jj2 = double(sys.jj)
% 
% Jfig5 = aa2 .* (Rfig - uu2).^2 + jj2;
% % plot(Rfig, Jfig5)
% 
% sys = solve(Jfig1(r7)==aa*(Rfig(r7)-uu)^2+jj, ...
%             Jfig2(r8)==aa*(Rfig(r8)-uu)^2+jj, ...
%             Jfig3(r9)==aa*(Rfig(r9)-uu)^2+jj, ...
%             aa, uu, jj);
% aa3 = double(sys.aa)
% uu3 = double(sys.uu)
% jj3 = double(sys.jj)
% 
% Jfig6 = aa3 .* (Rfig - uu3).^2 + jj3;
% % plot(Rfig, Jfig6)

%%

r11 = find(Rfig == 20);
r12 = find(Rfig == 20.1);
% r13 = find(Rfig == 20.2);
r13 = 103;

r21 = find(Rfig == 40);
r22 = find(Rfig == 40.1);
r23 = find(Rfig == 40.2);

sys = solve(Jfig1(r11)==aa*(Rfig(r11)-uu)^2+jj, ...
            Jfig1(r12)==aa*(Rfig(r12)-uu)^2+jj, ...
            Jfig1(r13)==aa*(Rfig(r13)-uu)^2+jj, ...
            aa, uu, jj);
aa1 = double(sys.aa)
uu1 = double(sys.uu)
jj1 = double(sys.jj)

sys = solve(Jfig2(r21)==aa*(Rfig(r21)-uu)^2+jj, ...
            Jfig2(r22)==aa*(Rfig(r22)-uu)^2+jj, ...
            Jfig2(r23)==aa*(Rfig(r23)-uu)^2+jj, ...
            aa, uu, jj);
aa2 = double(sys.aa)
uu2 = double(sys.uu)
jj2 = double(sys.jj)