classdef SteadyState_t < handle
  
  properties
    samples
    sampleDimension
    oscAmp % Ex: 0.05 = ±5% oscillation
    oInSteadyState
    nSamples
    nSamplesForSteadyState
  end
  
  methods
    
    % Constructor
    function ss = SteadyState_t(sizeOfSample, oscAmp, nSamplesForSteadyState)
      ss.samples                = zeros([nSamplesForSteadyState sizeOfSample]);
      ss.sampleDimension        = sizeOfSample(end);
      ss.oscAmp                 = oscAmp;
      ss.oInSteadyState         = 0;
      ss.nSamples               = 0;
      ss.nSamplesForSteadyState = nSamplesForSteadyState;
    end
    
    % Destructor
    function Del(ss)
      delete(ss);
    end
    
    function SetSteadyStateOscAmp(ss,amp)
      ss.oscAmp = amp;
    end
    
    function SetSamplesForSteadyState(ss,n)
      ss.nSamplesForSteadyState = n;
    end
    
    function AddSample(ss, newSample)
      ss.samples = circshift(ss.samples, 1, 1);
      ss.samples(1,:,:) = newSample;
      if ss.nSamples < ss.nSamplesForSteadyState
        ss.nSamples = ss.nSamples + 1;
      end
    end
    
    function oInSs = EvaluateSteadyState(ss)
      if ss.nSamples < ss.nSamplesForSteadyState
        oInSs = 0;
        ss.oInSteadyState = 0;
      else
        for iDim = 1 : ss.sampleDimension
          oInSs = 1;
          ss.oInSteadyState = 1;
          meanDim = mean(ss.samples(:,:,iDim));
          maxDim  = max(ss.samples(:,:,iDim));
          minDim  = min(ss.samples(:,:,iDim));
          
          if ~isempty(find((abs(maxDim-meanDim)./meanDim) >= ss.oscAmp)) ...
          || ~isempty(find((abs(minDim-meanDim)./meanDim) >= ss.oscAmp))
            oInSs = 0;
            ss.oInSteadyState = 0;
            break;
          end
        end
      end
    end
    
  end
  
end

