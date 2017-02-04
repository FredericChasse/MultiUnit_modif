mfcArray = MfcArray_t(1, nUnits);
for iUnit = 1 : nUnits
  % S0 = 300 => (Ropt, Popt) = (156.0, 0.001793880437409)
  % S0 = 290 => (Ropt, Popt) = (162.2, 0.001743879612695)
  mfcArray.units(iUnit).s0 = 300;
end
mfcArray.integrationTime = .8;
mfcArray.odeOptions = odeset('RelTol',1e-6,'AbsTol',1e-9);

array = Array_t(mfcArray);