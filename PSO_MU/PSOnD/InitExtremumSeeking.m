extSeekId   = 1;
extSeek = ExtSeek_t(extSeekId, array);

if strcmp(typeOfUnits, mfcType)
  ap = 10;
  wp = 0.001;
  wl = wp / 5;
  wh = wl;
  k  = 5;
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