classdef PsoToMfcLink_t < handle
  
  properties
    mfcId
    swarmId
    particleId
    dimId
    nLinks
  end
  
  methods
    
    % Constructor
    function l = PsoToMfcLink_t
      l.mfcId = [];
      l.swarmId = [];
      l.particleId = [];
      l.dimId = [];
      l.nLinks = 0;
    end
    
    % Destructor
    function Del(l)
      delete(l);
    end
    
    % Add new link
    function AddLink(l, mfcId, swarmId, particleId, dimId)
      mfcIdx = find(l.mfcId == mfcId);
      if ~isempty(mfcIdx)
        swarmIdx = find(l.swarmId(mfcIdx) == swarmId);
        if ~isempty(swarmIdx)
          particleIdx = find(l.particleId(swarmIdx) == particleId);
          if ~isempty(particleIdx)
            dimIdx = find(l.dimId(particleIdx) == dimId)
            if ~isempty(dimIdx)
              error('Link already exists.');
            end
          end
        end
      end
      
      l.nLinks = l.nLinks + 1;
      l.mfcId(l.nLinks) = mfcId;
      l.swarmId(l.nLinks) = swarmId;
      l.particleId(l.nLinks) = particleId;
      l.dimId(l.nLinks) = dimId;
    end
    
    % Remove link
    function RemoveLink(l, mfcId, swarmId, particleId, dimId)
      if l.nLinks <= 0
        error('No links to remove.');
      end
      
      mfcIdx = find(l.mfcId == mfcId);
      if isempty(mfcIdx)
        error('No link for this mfc ID.');
      end
      
      swarmIdx = find(l.swarmId(mfcIdx) == swarmId);
      if isempty(swarmIdx)
        error('No link for this swarm ID.');
      end
      
      particleIdx = find(l.particleId(swarmIdx) == particleId);
      if isempty(particleIdx)
        error('No link for this particle ID.');
      end
      
      dimIdx = find(l.unitId(particleIdx) == dimId);
      if isempty(dimIdx)
        error('No link for this dimension ID.');
      end
      
      l.mfcId(dimIdx)       = [];
      l.swarmId(dimIdx)     = [];
      l.particleId(dimIdx)  = [];
      l.dimId(dimIdx)       = [];
      l.nLinks              = l.nLinks - 1;
    end
    
    % Remove link by ID
    function RemoveLinkById(l, id)
      if id > l.nLinks
        error('This link id does not exist');
      end
      
      l.mfcId(id)       = [];
      l.swarmId(id)     = [];
      l.particleId(id)  = [];
      l.dimId(id)       = [];
      l.nLinks          = l.nLinks - 1;
    end
    
  end
  
end

