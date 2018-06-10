import SimPkg.*
import SimPkg.UnitPkg.*
import SimPkg.ArrayPkg.*

integrationTime = 0.1;

staticFuncArray = StaticFuncArray_t(1, nUnits, integrationTime);
array = Array_t(staticFuncArray);

nDiffUnits = floor(array.nUnits / 2);

% nDiffUnits = array.nUnits;
beta = 150;
gamma = 0;
for i = 1 : nDiffUnits
%   staticFuncArray.units(i).beta = i*beta;
%   staticFuncArray.units(i).gamma = i*gamma;
  staticFuncArray.units(i).beta = beta;
  staticFuncArray.units(i).gamma = gamma;
end
