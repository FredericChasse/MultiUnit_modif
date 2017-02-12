integrationTime = 0.1;

staticFuncArray = StaticFuncArray_t(1, nUnits, integrationTime);
array = Array_t(staticFuncArray);

nDiffUnits = floor(array.nUnits / 2);

for i = 1 : nDiffUnits
  staticFuncArray.units(i).beta = -80;
  staticFuncArray.units(i).gamma = 2;
end