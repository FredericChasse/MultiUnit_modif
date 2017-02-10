clear
close all

% jopt = 20;
% a = -0.002;
% ropt = 100;
a = -0.000055;
ropt = 325;
jopt = 31;

rmin = 1;
rmax = 1000;

wp = .5;
wl = wp / 10;
wh = wl;
T = .1;

ap = 10;

k = 5;

rinit = 20;

nCycles = 500;

nIterations = nCycles / T;

h = waitbar(1/nIterations);

r = rinit;

j = [0 0];

hpfOutput = [0 0];
lpfInput = [0 0];
lpfOutput = [0 0];

grad = [0 rinit];

j(2) = a * (r - ropt)^2 + jopt;

tsim = 0;

for i = 1 : nIterations
  tsim = tsim + T;
  
  j(1) = j(2);
  j(2) = a * (r - ropt)^2 + jopt;
  
  hpfOutput(1) = hpfOutput(2);
  hpfOutput(2) = HpfZ(j(2), j(1), hpfOutput(1), T, wh);
  
  perturb = ap * sin(wp*tsim);
  
  lfpInput(1) = lpfInput(2);
  lpfInput(2) = perturb * hpfOutput(2);
  
  lpfOutput(1) = lpfOutput(2);
  lpfOutput(2) = LpfZ(lpfInput(2), lpfInput(1), lpfOutput(1), T, wl);
  
  grad(1) = grad(2);
  grad(2) = TustinZ(lpfOutput(2), lpfOutput(1), grad(1), T);
  
  rmem(i) = r;
  jmem(i) = j(2);
  
  r = grad(2)*k + perturb;
  
end

plot(rmem)

close(h);