classdef PnoSimData_t < handle
  %PNOSIMDATA_T Summary of this class goes here
  %   Detailed explanation goes here
  properties
    u
    j
    iteration
  end
  
  methods
    
    % Constructor
    function data = PnoSimData_t
      data.u              = {};
      data.j              = {};
      data.iteration      = {};
    end
    
    % Destructor
    function Del(data)
      delete(data);
    end
    
    % Add simulation data
%     function AddData(data, speed, d, j, jSingle, pbest, gbest, timeElapsed, oInSteadyState, iteration)
    function AddData(data, u, j, iteration)
      data.u              {iteration} = u;
      data.j              {iteration} = j;
      data.iteration      {iteration} = iteration;
    end
    
  end
  
  methods (Static)
    
    function [table] = FormatToArray(data)
      nData = length(data);
      [nLines, nColumns] = size(data{1});
      table = zeros(nData, nLines, nColumns);
      for i = 1 : nData
        table(i,:,:) = data{i};
      end
    end
    
  end
  
end

