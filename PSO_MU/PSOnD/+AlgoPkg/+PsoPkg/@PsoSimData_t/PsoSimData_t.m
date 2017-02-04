classdef PsoSimData_t < handle
  
  properties
    speed
    d
    j
    jSingle
    pbest
    gbest
    iteration
    oInSteadyState
%     timeElapsed
  end
  
  methods
    
    % Constructor
    function data = PsoSimData_t
      data.speed          = {};
      data.d              = {};
      data.j              = {};
      data.jSingle        = {};
      data.pbest          = {};
      data.gbest          = {};
      data.iteration      = {};
      data.oInSteadyState = {};
%       data.timeElapsed    = {};
    end
    
    % Destructor
    function Del(data)
      delete(data);
    end
    
    % Add simulation data
%     function AddData(data, speed, d, j, jSingle, pbest, gbest, timeElapsed, oInSteadyState, iteration)
    function AddData(data, speed, d, j, jSingle, pbest, gbest, oInSteadyState, iteration)
      data.speed          {iteration} = speed;
      data.d              {iteration} = d;
      data.j              {iteration} = j;
      data.jSingle        {iteration} = jSingle;
      data.pbest          {iteration} = pbest;
      data.gbest          {iteration} = gbest;
%       data.timeElapsed    {iteration} = timeElapsed;
      data.oInSteadyState {iteration} = oInSteadyState;
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

