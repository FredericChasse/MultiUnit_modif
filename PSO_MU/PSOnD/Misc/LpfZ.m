function [ y ] = LpfZ( u, up, yp, T, wl )
 
%  LPF
%
%  Y(s)        wl
% ------ == ---------
%  U(s)       s + wl

y = (u*wl*T + up*wl*T - yp*(wl*T - 2)) / (wl*T + 2);

end

