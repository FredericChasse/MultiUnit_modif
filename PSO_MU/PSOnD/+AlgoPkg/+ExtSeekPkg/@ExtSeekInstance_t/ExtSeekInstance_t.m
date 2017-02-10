classdef ExtSeekInstance_t < handle
  % ExtSeekInstance_t defines an instance of Extremum Seeking algorithm, to
  % be called by its master ExtSeek_t
  
  properties
    id;
    ap; % Amplitude of perturbation
    wp; % frequency of perturbation
    wl; % frequency of LPF
    wh; % frequency of HPF
    k;  % Gain of gradient
    d;  % Current position of unit
    umin;
    umax;
    uInit;
    hpfOutput;
    lpfInput;
    lpfOutput;
    grad;
    j; % Objective function
  end
  
  methods
    
    % Constructor
    function esi = ExtSeekInstance_t(id)
      esi.id = id;
      esi.ap = 10;
      esi.wp = .5;
      esi.wl = esi.wp / 10;
      esi.wh = esi.wl;
      esi.k  = 5;
      esi.umin = 1;
      esi.umax = 1000;
      esi.uInit = 20;
      esi.hpfOutput = [0 0];
      esi.lpfInput  = [0 0];
      esi.lpfOutput = [0 0];
      esi.grad      = [0 esi.uInit];
      esi.j         = [0 0];
      esi.d         = esi.uInit;
    end
    
    % Destructor
    function Del(esi)
      delete(esi);
    end
    
  end
  
end

