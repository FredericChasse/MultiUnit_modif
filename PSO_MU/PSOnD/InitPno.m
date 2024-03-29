import AlgoPkg.PnoPkg.*
import AlgoPkg.*

pnoId   = 1;
pno = Pno_t(pnoId, array);

if strcmp(typeOfUnits, mfcType)
%   delta = 15;
  delta = 5;
  umin = 10;
  umax = 350;
%   uInit = 200;
  uInit = 100;
elseif strcmp(typeOfUnits, staticFunctionType)
%   delta = 10;
  delta = 30;
  umin = 1;
  umax = 1000;
  uInit = 500;
else
  error('Must define a type of units!');
end

pno.SetInstancesParameters(delta, umin, umax, uInit);

algo = Algo_t(pno);