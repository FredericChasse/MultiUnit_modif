classdef LinkTable_t < handle
  
  properties
    nLinks
    links
  end
  
  methods
    
    % Constructor
    function table = LinkTable_t
      import AlgoPkg.LinkPkg.*;
      table.nLinks = 0;
      table.links  = Link_t.empty;
    end
    
    % Destructor
    function Del(table)
      delete(table);
    end
    
    % Add new link
    function AddLink(l, simUnitId, algoId, algoUnitId, algoDimId)
      import AlgoPkg.LinkPkg.*;
      l.nLinks = l.nLinks + 1;
      l.links(l.nLinks) = Link_t(l.nLinks, simUnitId, algoId, algoUnitId, algoDimId);
    end
    
    % Remove link
    function RemoveLink(l, simUnitId, algoId, algoUnitId, algoDimId)
      if l.nLinks <= 0
        error('No links to remove.');
      end
      
      unitIdx = find(l.mfcId == simUnitId);
      if isempty(unitIdx)
        error('No link for this sim unit ID.');
      end
      
      algoIdx = find(l.swarmId(unitIdx) == algoId);
      if isempty(algoIdx)
        error('No link for this algo ID.');
      end
      
      algoUnitIdx = find(l.particleId(algoIdx) == algoUnitId);
      if isempty(algoUnitIdx)
        error('No link for this algo unit ID.');
      end
      
      dimIdx = find(l.unitId(algoUnitIdx) == algoDimId);
      if isempty(dimIdx)
        error('No link for this dimension ID.');
      end
      
      ShiftIdLeft(dimIdx);
      l.links(dimIdx).Del;
      l.links(dimIdx) = [];
      l.nLinks        = l.nLinks - 1;
    end
    
    % Remove link by ID
    function RemoveLinkById(l, id)
      if id > l.nLinks
        error('This link id does not exist');
      end
      
      ShiftIdLeft(id);
      l.links(id).Del;
      l.links(id) = [];
      l.nLinks    = l.nLinks - 1;
    end
    
  end
  
  methods (Access = private)
    
    % Shift the IDs of the links from a certain index to the left
    % To be called when removing links
    function ShiftIdLeft(table,idx)
      if (idx > table.nLinks) || (idx <= 0)
        error('Wrong index.');
      end
      if idx < table.nLinks
        for iLink = table.nLinks : -1 : idx + 1
          table.links(iLink).id = table.links(iLink - 1).id;
        end
      end
    end
    
  end
  
end

