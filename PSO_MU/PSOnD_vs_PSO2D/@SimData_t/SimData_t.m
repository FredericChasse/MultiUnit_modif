classdef SimData_t < handle
  
  properties
    speed
    d
    j
    jSingle
    pbest
    gbest
    iteration
  end
  
  methods
    
    % Constructor
    function data = SimData_t
      data.speed     = {};
      data.d         = {};
      data.j         = {};
      data.jSingle   = {};
      data.pbest     = {};
      data.gbest     = {};
      data.iteration = {};
    end
    
    % Destructor
    function Del(data)
      delete(data);
    end
    
    % Add simulation data
    function AddData(data, speed, d, j, jSingle, pbest, gbest, iteration)
      data.speed    {iteration} = speed;
      data.d        {iteration} = d;
      data.j        {iteration} = j;
      data.jSingle  {iteration} = jSingle;
      data.pbest    {iteration} = pbest;
      data.gbest    {iteration} = gbest;
      data.iteration{iteration} = iteration;
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

