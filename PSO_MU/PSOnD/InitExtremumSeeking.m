extSeekId   = 1;
extSeek = ExtSeek_t(extSeekId, array);

if strcmp(typeOfUnits, mfcType)
  ap = 2;
  unitFreq = 1 / array.unitEvalTime;
  wp = unitFreq / 10 * 2 * pi;
  wl = wp / 5;
  wh = wl / 5;
  k  = 2;
  umin = 1;
  umax = 1000;
  uInit = 20;
elseif strcmp(typeOfUnits, staticFunctionType)
  ap = 10;
  wp = 1.5;
  wl = wp / 10;
  wh = wl;
  k  = 5;
  umin = 1;
  umax = 1000;
  uInit = 20;
else
  error('Must define a type of units!');
end

extSeek.SetInstancesParameters(ap, wp, wl, wh, k, umin, umax, uInit);

algo = Algo_t(extSeek);