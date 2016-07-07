clear all
close all

beta=4;
gamma=-10;

a=1.5;
u1store=[];
u2store=[];
J1Store=[];

J2Store=[];
% u1=-20:1:20;
% u2=u1;
% for n =1:length(u1);
%     u1n = u1(n);
%     for m =1:length(u2)
%         u2m = u2(m);
% Ja(m,n)=a*u1n^2+b*u2m^2+c*u1n*u2m;
% Jb(m,n)=a*(u1n-betaB1)^2+b*(u2m-betaB2)^2+gammab;
% Jc(m,n)=a*(u1n-betaC1)^2+b*(u2m-betaC2)^2+gammac;
% 
%     end
% end
% 
% contour(u1,u2,Ja,150),grid on 
% figure,contour(u1,u2,Jb,150),grid on,hold on,plot(betaB1,betaB2,'*'),hold off
% figure,contour(u1,u2,Jc,150),grid on,hold on,plot(betaC1,betaC2,'*'),hold off
% return
u = -6;
NbIter = 100;
NbIterCorr = 20;
Delta = 1;
kmu = -0.25/2;
corrbeta(1)=0;
ufig=-10:0.01:10;
J1fig= a*ufig.^2;
J2fig= a*(ufig+beta).^2+gamma;
grad1corr=0;
grad2corr=0;
gradcorr3=0;
w1=0.5;
w2=0.5;
grad1mem=0;
grad2mem=0;
grad3mem=0;
for m = 1: NbIterCorr
    
for n=1:NbIter
    u1(n) = u(n)-Delta/2+10*kmu*grad1corr;
    u2(n) = u(n)+Delta/2+10*kmu*grad2corr;
   
    J1 = a*u1(n)^2;
    J2=a*(u2(n)+beta)^2+gamma;

    u(n+1) = u(n)+kmu*(J2-J1-gradcorr3)/Delta;
%         u(n+1) = u(n)+kmu*(J2-J1)/Delta;

    if m==1 & n==1
        J1best=J1;
        J2best=J2;
        u1best =u1;
        u2best=u2;
    end
    if J1<J1best
            J1best =J1;
            u1best = u1(n);
    end
    if J2<J2best
            J2best =J2;
            u2best = u2(n);
    end
    u1store=[u1store;u1(n)];
    u2store=[u2store;u2(n)];
    J1Store=[J1Store;J1];
    J2Store=[J2Store;J2];

%     u2store(m,n)=u2(n);
%     J1Store(m,n)=J1;
%     J2Store(m,n)=J2;
end
u(1)=u(n);
if J1>J1best
    grad1corr = w1*grad1corr+w2*(J1-J1best)/(u1(end)-u1best)*0;
else
    grad1corr = 0;
end
if J2>J2best
    grad2corr = w1*grad2corr+w2*(J2-J2best)/(u2(end)-u2best)*0;
else
    grad2corr = 0;
end
gradcorr3 = w1*gradcorr3+w2*(J2best-J1best);
% if J1<J1best & J2<J2best
%     Delta = -Delta;
% end
% corrbeta(m+1)=u2(end)-u1(end);
% corrbeta(m+1)=(u1best-u2best)*(1-(J1best-J2best));
% J1best = J1;
% J2best=J2;
% grad1corrStore(m)=grad1corr;
% grad2corrStore(m)=grad2corr;
% u1store(end)
% u2store(end)
grad1mem = [grad1mem grad1corr];
grad2mem = [grad2mem grad2corr];
grad3mem = [grad3mem gradcorr3];
end
(u1store(end)+u2store(end))/2
figure(1),plot(ufig,J1fig,ufig,J2fig,u1store(end),J1Store(end),'*',u2store(end),J2Store(end),'*',u1store(1),J1Store(1),'+',u2store(1),J2Store(1),'+',u1store(n),J1Store(n),'o',u2store(n),J2Store(n),'o')
figure(2),plot(1:length(u1store),u1store,1:length(u2store),u2store),legend('u1','u2')
figure(3),plot(1:length(J1Store),J1Store,1:length(J2Store),J2Store)
figure,plot(grad1mem)
figure,plot(grad2mem)
figure,plot(grad3mem)