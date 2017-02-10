function [ y ] = HpfZ( u, up, yp, T, wh )

%  HPF
%
%  Y(s)         s
% ------ == ---------
%  U(s)       s + wh

y = (2*u - 2*up - yp*(wh*T - 2)) / (wh*T + 2);

end

