import SimPkg.*
import SimPkg.UnitPkg.*
import SimPkg.ArrayPkg.*

import AlgoPkg.*
import AlgoPkg.LinkPkg.*
import AlgoPkg.PsoPkg.*
import AlgoPkg.ExtSeekPkg.*
import AlgoPkg.PnoPkg.*
import AlgoPkg.PsoPnoPkg.*

if strcmp(typeOfAlgo, psoType) || strcmp(typeOfAlgo, psoPnoType)
  integrationTime = 0.15;
elseif strcmp(typeOfAlgo, extremumSeekType)
  integrationTime = .1;
elseif strcmp(typeOfAlgo, pnoType)
  integrationTime = .1;
else
  error('Must define a type of algorithm!');
end

% mfcModel = 'mfcModel';
mfcModel = 'mfcModelFast';

mfcArray = MfcArray_t(1, nUnits, integrationTime, mfcModel);

s0Init = 600;
s0min = 300;
s0max = 600;

unitsS0 = zeros(1,nUnits);
% s0mfc = [371.25 443.85 322.68 508.75 434.34 370.27 383.58 662.06];
% s0mfc = [371.25 443.85 508.75 434.34 370.27 383.58];
for iUnit = 1 : nUnits
%   S0 = 300 => (Ropt, Popt) = (156.0, 0.001793880437409)
%   S0 = 290 => (Ropt, Popt) = (162.2, 0.001743879612695)
%   S0 = 600 => (Ropt, Popt) = (81.10, 0.002063069379472)
%   mfcArray.units(iUnit).s0 = s0Init - (iUnit-1) * 20;
%   mfcArray.units(iUnit).s0 = s0mfc(iUnit);
%   mfcArray.units(iUnit).s0 = 600;
  mfcArray.units(iUnit).s0 = rand*(s0max-s0min)+s0min;
  unitsS0(iUnit) = mfcArray.units(iUnit).s0;
end
% for iUnit = nUnits/2+1 : nUnits
% %   S0 = 300 => (Ropt, Popt) = (156.0, 0.001793880437409)
% %   S0 = 290 => (Ropt, Popt) = (162.2, 0.001743879612695)
% %   S0 = 600 => (Ropt, Popt) = (81.10, 0.002063069379472)
% %   mfcArray.units(iUnit).s0 = s0Init - (iUnit-1) * 20;
% %   mfcArray.units(iUnit).s0 = s0mfc(iUnit);
%   mfcArray.units(iUnit).s0 = 300;
% %   mfcArray.units(iUnit).s0 = rand*(s0max-s0min)+s0min;
%   unitsS0(iUnit) = mfcArray.units(iUnit).s0;
% end
unitsS0
% mfcArray.units(1).s0 = 600;
% mfcArray.units(2).s0 = 540;
% mfcArray.units(3).s0 = 480;
% mfcArray.integrationTime = .8;
mfcArray.odeOptions = odeset('RelTol',1e-6,'AbsTol',1e-9);

array = Array_t(mfcArray);


% nDiffUnits = floor(array.nUnits / 2);
% 
% for i = 1 : nDiffUnits
%   mfcArray.units(i).s0 = 250;
% end