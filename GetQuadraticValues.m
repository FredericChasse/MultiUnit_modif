function [a,uopt,jopt]= GetQuadraticValues(u,J)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
j1 = J(1);
j2 = J(2);
j3 = J(3);
u1 = u(1);
u2 = u(2);
u3 = u(3);

a = (j1*u2 - j2*u1 - j1*u3 + j3*u1 + j2*u3 - j3*u2)/((u1 - u2)*(u1*u2 - u1*u3 - u2*u3 + u3^2));

uopt = (j1*u2^2 - j2*u1^2 - j1*u3^2 + j3*u1^2 + j2*u3^2 - j3*u2^2)/(2*(j1*u2 - j2*u1 - j1*u3 + j3*u1 + j2*u3 - j3*u2));

jopt = -(j1^2*u2^4 - 4*j1^2*u2^3*u3 + 6*j1^2*u2^2*u3^2 - 4*j1^2*u2*u3^3 + j1^2*u3^4 - 2*j1*j2*u1^2*u2^2 + 4*j1*j2*u1^2*u2*u3 - 2*j1*j2*u1^2*u3^2 + 4*j1*j2*u1*u2^2*u3 - 8*j1*j2*u1*u2*u3^2 + 4*j1*j2*u1*u3^3 - 2*j1*j2*u2^2*u3^2 + 4*j1*j2*u2*u3^3 - 2*j1*j2*u3^4 - 2*j1*j3*u1^2*u2^2 + 4*j1*j3*u1^2*u2*u3 - 2*j1*j3*u1^2*u3^2 + 4*j1*j3*u1*u2^3 - 8*j1*j3*u1*u2^2*u3 + 4*j1*j3*u1*u2*u3^2 - 2*j1*j3*u2^4 + 4*j1*j3*u2^3*u3 - 2*j1*j3*u2^2*u3^2 + j2^2*u1^4 - 4*j2^2*u1^3*u3 + 6*j2^2*u1^2*u3^2 - 4*j2^2*u1*u3^3 + j2^2*u3^4 - 2*j2*j3*u1^4 + 4*j2*j3*u1^3*u2 + 4*j2*j3*u1^3*u3 - 2*j2*j3*u1^2*u2^2 - 8*j2*j3*u1^2*u2*u3 - 2*j2*j3*u1^2*u3^2 + 4*j2*j3*u1*u2^2*u3 + 4*j2*j3*u1*u2*u3^2 - 2*j2*j3*u2^2*u3^2 + j3^2*u1^4 - 4*j3^2*u1^3*u2 + 6*j3^2*u1^2*u2^2 - 4*j3^2*u1*u2^3 + j3^2*u2^4)/(4*(u1 - u2)*(u1*u2 - u1*u3 - u2*u3 + u3^2)*(j1*u2 - j2*u1 - j1*u3 + j3*u1 + j2*u3 - j3*u2));

end

