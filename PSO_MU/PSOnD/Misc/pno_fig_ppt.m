clear all
close all

ocv = 0.8;
rint = 100;
pmax = ocv^2*rint/(2*rint)^2;
n = 50;

p = zeros(1,n);
r = zeros(1,n);

popt = ones(1,n) * pmax;
ropt = ones(1,n) * rint;

rInit = 150;
delta = 5;
k = 1;

r(1) = rInit;

for i = 1 : n
  
  p(i) = ocv^2*r(i)/(rint+r(i))^2;
  
  if i ~= 1
    if p(i) < p(i-1)
      k = -k;
    end
  end
  
  if i < n
    r(i+1) = r(i) + k*delta;
  end
end

figure
set(gcf, 'Color', 'w')

subplot(2,1,1)
plot(r)
hold on
plot(ropt, '--')
legend({'R_e_x_t', 'Résistance optimale'})
title('Évolution de la résistance externe')
xlabel('Itération')
ylabel('Résistance externe (\Omega)')

subplot(2,1,2)
plot(p)
hold on
plot(popt, '--')
title('Évolution de la puissance de sortie')
xlabel('Itération')
ylabel('Puissance de sortie (W)')
legend({'P_o_u_t', 'Puissance optimale'})
