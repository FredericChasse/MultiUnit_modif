classdef ExtSeekSimData_t < handle
  % ExtSeekSimData_t details the simulation data for the
  % Extremum Seeking algorithm
  
  properties
    d
    j
    iteration
  end
  
  methods
    
    % Constructor
    function data = ExtSeekSimData_t
      data.d              = {};
      data.j              = {};
      data.iteration      = {};
    end
    
    % Destructor
    function Del(data)
      delete(data);
    end
    
    % Add simulation data
%     function AddData(data, speed, d, j, jSingle, pbest, gbest, timeElapsed, oInSteadyState, iteration)
    function AddData(data, d, j, iteration)
      data.d              {iteration} = d;
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

