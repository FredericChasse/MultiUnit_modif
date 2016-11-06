classdef MfcArray_t < handle
  
  properties
    array
    nMfcs
  end
  
  methods
    
    % Constructor
    function array = MfcArray_t(nMfcs)
      for iMfc = 1 : nMfcs
        array.array(iMfc) = Mfc_t(iMfc);
      end
      array.nMfcs = nMfcs;
    end
    
    % Destructor
    function Del(mfcArray)
      delete(mfcArray);
    end
    
  end
  
end

