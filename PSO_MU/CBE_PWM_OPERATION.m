%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  R-PWM operation of a Combined Bioelectrochemical-Electrical MFC Model  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%   Author:     Dídac Recio Garrido
%%%   Modified:   November 12th, 2016

%%%   This scrip integrates the CBE model of an MFC under R-PWM operation 
%%%   with possible disturbances on the influent concentration, Sin.


function [] = CBE_PWM_OPERATION()
    
    clear all; close all; clc
    
    % Initial conditions
    [time,par,in,x0] = Initialization();
    
    % Integrate CBE under PWM operation
    [sim.t,sim.Mode] = PWM(time,par,in,x0);
    
    % Plot results
    PlotResults(time,sim,par);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [time,par,in,x0] = Initialization()
    
    % Simulation time
    time.tss   = 4;                 % Time allowed for the steady-state to be achieved [d]
    time.tsw   = 0.5/24;            % Time of switch to the Sin step disturbance [d]
    time.tend  = 1/24;              % Time end of simulation > time of switch [d]
    
    % Inputs
    in.Fin     = 0.05/8*24;     	% Volume Flow [L/day] (Fin = V/HRT with HRT [h])
    in.Sin0    = 1500;              % Initial influent concentration [mg/L]
    in.Sinf    = 1500;              % Final influent concentration [mg/L] (after perturbation)
    
    % Estimated parameters
    par.Y      = 24.7;              % Yield for Mox balance [mg-M/mg-S]
    par.qmaxe  = 16.87;             % Max substrate consumption rate [mg-S/mg-X/day]
 	par.Kr     = 0.0198;            % Curve steepness in the internal resistance [L/mg-X]
    par.Kx     = 0.04;              % Curve steepness in alpha [L/mg-X]
    par.umaxe  = 1.97;              % Electricigenic max growth rate [1/day]
    par.Xi     = 14.85;             % Monod half rate for the electrical variables [mg-S/L]
    
    % Assumed parameters
    par.umaxm  = 0.1;               % Methanogens max grow rate [1/day]
    par.qmaxm  = 8.2;               % max substrate consumption rate [mg-S/mg-X/day]
    par.Kde    = 0.02*par.umaxe;    % Decay rate for Xe [1/day]
    par.Kdm    = 0.02*par.umaxm;    % Decay rate for Xm [1/day]
    par.Kse    = 20;                % Half Monod electricigens [mg/L]
    par.Ksm    = 80;                % Half Monod methanogens [mg/L]
    par.Mtotal = 0.05;              % Mediator concentration [mg-M/mg-Xeg]
    par.Km     = 0.2*par.Mtotal;    % Monod term Mox limitation 
    par.Xmaxe  = 512.5;             % Maximum Xe in the Biofilm (Space limitation)
    par.Xmaxm  = 525;               % Maximum Xm in the Biofilm (Space limitation)
    par.Rmax   = 2000;              % Maximum value for Rint [Ohm]
    par.Rmin1  = 1.16940;           % Min value for Rint1 [Ohm] (Javier's Sin tests)
    par.Rmin2  = 5.13109;           % Min value for Rint2 [Ohm] (Javier's Sin tests)    
    par.Emax   = 0.4;               % Max value for Eocp [V] from Javier (Time tests)
    par.Emin   = 0.01;              % Min measured OCV value [V]
    par.Cmin   = 0.01;              % Imposed %%%% 0.03F = Minimum value for C from Javier (Time tests)
    par.Cmax   = 0.61;              % Maximum value for C from Javier (Sin tests)
    par.YCH4   = 0.3;               % Methane yield [mL/mg-S]
    par.gamma  = 663400;            % NADP molar weight [mg/mol]
    par.m      = 2;                 % Electrons tranfered for NADH [mol/mol-M]
    par.F      = 96485;             % Faraday constant [A s/mol]
    par.R      = 8.314472;          % Gas ideal constant [J/K/mol]
    par.V      = 0.05;              % Volume [L]
    par.T      = 298.15;            % Anode Temperature [K]
    par.eps    = 1e-4*par.Mtotal;   % Limitation constant to avoid current generation in Faraday's law (when Mred->0)
    
    
 	% Initial conditions
    S0   = in.Sin0;                 % Substrate concentration [mg/L]
    Xe0  = 500;%150;                % Electricigenic concentration [mg-X/L]
    Xm0  = 10;                      % Methanogenic concentration [mg-X/L]
    Mox0 = 0.1*par.Mtotal;          % Oxidized mediator concentration [mg-M/mg-X]
    Vc0  = 0;                   	% Electrical potential at the capacitor [V]
    
    x0   = [S0,Xe0,Xm0,Mox0,Vc0]';
    
end

function [t,Mode] = PWM(time,par,in,x0)
    
    % Operational parameters
    f    = 0.005;                           % Frequency [Hz]
    D    = 50;                              % Duty cycle [D=(ton/T)*100] [%]
    
    T    = (1/f)/3600/24;                   % Period [d]
    tON  = (D*T)/100;                       % Interval of time where Rext is connected [d]
    tOFF = T-tON;
    
    % Resistance thresholds
    bounds.upperRext  = 1e6;
    bounds.lowerRext  = 10;
    
    % Inputs
    in.Rext(1:2,1) = bounds.lowerRext;      % Initial value for Rext [ohm]   
    in.Fin(1:2,1)  = in.Fin;                % Fixed input flow rate [L/d]
    in.Sin(1:2,1)  = [in.Sin0;in.Sinf];     % Step change in Sin [mg/L]
    
    
    % Initialization (with Rext=lowerRext to make the initialization faster)
    aux  = 1;                               % Initial value of Sin
    tini = 0;                               % Starting the simulation at t=0
    tfin = time.tss*0.01;                   % Time until achieving the steady-state   
    
    options = odeset('NonNegative',1:5);%,'RelTol',1e-5,'AbsTol',1e-5);
    [t,Youtaux1] = ode15s(@(t,x)CBEodes(t,x,par,in,aux),[tini,tfin],x0',options);
    t = [0;0];
    
    % Calculate the initial outputs
    Mode = zeros(length(t),18);             % Preallocation of the matrix Mode1
    for j = 1:length(t);
        [~,Mode(j,:)] = CBEodes(t(j),Youtaux1(j,:)',par,in,aux);
    end
    
    % Add the average power to the outputs
    Mode(:,19) = Mode(:,10);
    
    % Start waitbar
    h = waitbar(0,'PWM operation of the CBE model...');    
    
    % Integrate the CBE equations 
    tsim = time.tss+time.tend;              % Total simulation time
    N    = length(t);                       % First time position for averaging the power 
    
    while t(end,1) <= tsim
        
        % Sin input depending on time
        tswitch = time.tss+time.tsw;
        if t(end,1) >= tswitch; aux = 2; end
        
        %%% ON time =======================================================
        in.Rext(1:2,1)   = bounds.lowerRext;
        tini             = t(end-1,1);
        tfin             = t(end-1,1)+tON;
        [taux2,Youtaux2] = ode15s(@(t,x)CBEodes(t,x,par,in,aux),[tini,tfin],Youtaux1(end,1:5)',options);
        
        % Calculate all the outputs for the ON period
        for j = 1:length(taux2)
            [~,Modeaux2(j,:)] = CBEodes(taux2(j),Youtaux2(j,:)',par,in,aux);
        end
        
        % Preallocate with zeros the last column of Mode for the average power
        Modeaux2(:,19) = zeros(length(taux2),1);
        
        % Save the values
        nON  = length(taux2(1:end-1,1));       % Number of samples in the ON        
        t    = [t(1:end-1,1);taux2];           % Actualize the time with the ON values
        Mode = [Mode(1:end-1,:);Modeaux2];     % Actualize the outputs with the ON values
        %%% ===============================================================
        
        clearvars taux2 Modeaux2 Youtaux1            
        
        %%% OFF time ======================================================
        in.Rext(1:2,1)   = bounds.upperRext;
        tini             = t(end-1,1);
        tfin             = t(end-1,1)+tOFF;
        [taux3,Youtaux3] = ode15s(@(t,x)CBEodes(t,x,par,in,aux),[tini,tfin],Youtaux2(end,1:5)',options);
        
        % Calculate all the outputs for the OFF period
        for j = 1:length(taux3)
            [~,Modeaux3(j,:)] = CBEodes(taux3(j),Youtaux3(j,:)',par,in,aux);
        end
        
        % Preallocate with zeros the last column of Mode for the average power
        Modeaux3(:,19) = zeros(length(taux3),1);
        
        % Save the values
        nOFF = length(taux3(1:end-1,1));        % Number of samples in the OFF        
        t    = [t(1:end-1,1);taux3];            % Actualize the time with the OFF values
        Mode = [Mode(1:end-1,:);Modeaux3];      % Actualize the outputs with the OFF values
        Youtaux1 = Youtaux3;
        %%% ===============================================================
        
        clearvars taux3 Modeaux3 Youtaux2 Youtaux3       
        
        %%% Total period ==================================================
        ntot       = nON + nOFF;                % Total number of samples in the period
        N(end+1,1) = N(end)+ntot;              	% Vector of time positions
        
        % Calculate the average power
        Mode(N(end-1,1):N(end),19) = mean(Mode(N(end-1,1):N(end),10));
        %%% ===============================================================
        
        % Divide the waitbar in portions
        waitbar(t(N(end),1)/tsim,h)
        
    end
    
    % Close waitbar
    close(h)
    
end

function [dxdt,Mode] = CBEodes(t,x,par,in,aux)
    
    % This function returns the derivatives for the CBE model. 
    % Additionally, a matrix with all the output data is also provided.
    
    % State variables
    S   = x(1);
    Xe  = x(2);
    Xm  = x(3);
    Mox = x(4);
    Vc  = x(5);
    
    % Internal resistance, OCV and C
    Rint1 = par.Rmin1 + (par.Rmax - par.Rmin1)*exp(-Xe*par.Kr);
    Rint2 = par.Rmin2 + (par.Rmax - par.Rmin2)*exp(-Xe*par.Kr*(S/(par.Xi+S)));
    Rint  = Rint1+Rint2;
    
    OCV   = par.Emin + (par.Emax - par.Emin)*exp(-1./(par.Kr.*Xe*(S/(par.Xi+S))));
    C     = par.Cmin + (par.Cmax - par.Cmin)*exp(-1./(par.Kr.*Xe*(S/(par.Xi+S))));
    
    % Biomass retention parameter
    alphae = 1/2 + 1/2*tanh(par.Kx*(Xe+Xm-par.Xmaxe));
    alpham = 1/2 + 1/2*tanh(par.Kx*(Xe+Xm-par.Xmaxm));
    
    % Dilution rate
    D = in.Fin(aux,1)/par.V;
    
    % Reduced form of the mediator
    Mred = par.Mtotal-Mox;
    
    % Electrochemical equations
    nconc = (par.R*par.T/par.m/par.F)*log(par.Mtotal/Mred);
    Icell = (OCV-nconc-Vc)/(in.Rext(aux,1)+Rint1)*Mred/(par.eps+Mred);
    
    % Kinetic equations
    ue = par.umaxe*(S/(par.Kse+S))*(Mox/(par.Km+Mox));
    um = par.umaxm*(S/(par.Ksm+S));
    qe = par.qmaxe*(S/(par.Kse+S))*(Mox/(par.Km+Mox));
    qm = par.qmaxm*(S/(par.Ksm+S));
    
    % Derivatives
    dSdt   = -qe*Xe - qm*Xm + D*(in.Sin(aux,1)-S);  
    dXedt  = (ue - par.Kde)*Xe - alphae*D*Xe;
    dXmdt  = (um - par.Kdm)*Xm - alpham*D*Xm; 
    dMoxdt = -par.Y*qe + 86400*(par.gamma*Icell/par.m/par.F/Xe/par.V);
    dVcdt  = ((Icell-Vc/Rint2)/C)*86400;
    
    % Outputs
    Sout   = S;
    Vcell  = Icell*in.Rext(aux,1);
    Pcell  = Vcell^2/in.Rext(aux,1);
    Q      = par.YCH4*qm*Xm*par.V;
    
    Mode   = [S,Xe,Xm,Mox,Vc,Sout,Vcell,Q,Icell,Pcell,Rint1,Rint2,Rint,C,OCV,in.Fin(aux,1),in.Sin(aux,1),in.Rext(aux,1)];
    
    % Derivatives
    dxdt = [dSdt ; dXedt ; dXmdt ; dMoxdt ; dVcdt];
    
end

function [] = PlotResults(time,sim,par) 
    
    % Simulation time removing the time allowed to get to the steady-state
    tsim = (sim.t-time.tss)*24;             % in [h]
    
    %%%  Retrieve the results
    %%%  Mode = [  S,        (1)
    %%%            Xe,       (2) 
    %%%            Xm,       (3) 
    %%%            Mox,      (4) 
    %%%            Vc,       (5) 
    %%%            Sout,     (6) 
    %%%            Vcell,    (7) 
    %%%            Q,        (8)   
    %%%            Icell,    (9) 
    %%%            Pcell,    (10) 
    %%%            Rint1,    (11) 
    %%%            Rint2,    (12) 
    %%%            Rint,     (13) 
    %%%            C,        (14) 
    %%%            OCV,      (15)
    %%%            Fin,      (16)
    %%%            Sin,      (17)
    %%%            Rext      (18)
    %%%            Pcell av. (19)
    %%%         ];      

    
    % Simulation data
    S     = sim.Mode(:,1);                 	% in [mg-S/L]
    Xe    = sim.Mode(:,2);                 	% in [mg-Xe/L]
    Xm    = sim.Mode(:,3);                 	% in [mg-Xm/L]
    Mox   = sim.Mode(:,4);                 	% in [mg-Mox/L]
    Vc    = sim.Mode(:,5)*1e3;              % in [mV]
    Sout  = sim.Mode(:,6);                  % in [mg-S/L]  
    Vcell = sim.Mode(:,7)*1e3;              % in [mV]
    Q     = sim.Mode(:,8);                 	% in [mL/d]
    Icell = sim.Mode(:,9)*1e3;              % in [mA]
    Pcell = sim.Mode(:,10)*1e3;             % in [mW]
    Rint1 = sim.Mode(:,11);                 % in [ohm]
    Rint2 = sim.Mode(:,12);                 % in [ohm]
    Rint  = sim.Mode(:,13);                 % in [ohm]
    C     = sim.Mode(:,14);                 % in [F]
    OCV   = sim.Mode(:,15);                 % in [V]
    Fin   = sim.Mode(:,16);                 % in [L/d]
    Sin   = sim.Mode(:,17);                 % in [mg-S/d]
    Rext  = sim.Mode(:,18);                 % in [ohm]
    Pav   = sim.Mode(:,19)*1e3;             % in [mW]
    
    
    % Inputs
    figure(1)
    subplot(3,1,1)
        plot(tsim,Fin,'LineWidth',2);
        ylabel('F_{in} [L/d]');
        set(gca,'box','on','XTickLabel',[])
        title('Flow Rate')
        xlim([0 tsim(end,1)]);
	subplot(3,1,2)
        plot(tsim,Sin,'LineWidth',2);
        ylabel('S_{in} [mg-S/L]');
        set(gca,'box','on','XTickLabel',[])
        title('Influent Concentration')
        xlim([0 tsim(end,1)]);
    subplot(3,1,3); 
        plot(tsim,Rext,'LineWidth',2);
        ylabel('R_{ext} [\Omega]');
        xlabel('t [h]');
        set(gca,'box','on')
        title('External Resistance')
        xlim([0 tsim(end,1)]);
    set(figure(1), 'color', 'white')
     
    % Outputs
    figure(2)
    subplot(2,2,1)
        plot(tsim,OCV,'LineWidth',2);
        ylabel('E_{OC} [V]');
        set(gca,'box','on','XTickLabel',[])
        title('Open Circuit Voltage')
        xlim([0 tsim(end,1)]);
    subplot(2,2,2); 
        plot(tsim,C,'LineWidth',2);
        ylabel('C [F]');
        set(gca,'box','on','XTickLabel',[])
        title('Capacitance')
        xlim([0 tsim(end,1)]);
    subplot(2,2,3); 
        plot(tsim,Rint1,'LineWidth',2);
        ylabel('R_{int1} [\Omega]');
        xlabel('t [d]');
        set(gca,'box','on')
        title('Internal Resistance 1')
        xlim([0 tsim(end,1)]);
    subplot(2,2,4); 
        plot(tsim,Rint2,'LineWidth',2);
        ylabel('R_{int2} [\Omega]');
        xlabel('t [h]');
        set(gca,'box','on')
        title('Internal Resistance 2')
        xlim([0 tsim(end,1)]);
    set(figure(2), 'color', 'white')
    
    figure(3)
    subplot(2,1,1);
        plot(tsim,Sout,'LineWidth',2)
        ylabel('S [mg/L]');
        set(gca,'box','on','XTickLabel',[]);
        xlim([0 tsim(end,1)]);
    subplot(2,1,2); 
        plot(tsim,Vcell,'LineWidth',2);
        ylabel('V [V]');
        xlabel('t [h]');
        set(gca,'box','on')
        xlim([0 tsim(end,1)]);
    set(figure(3), 'color', 'white')
    
    figure(4)
    subplot(2,2,1); 
        plot(tsim,Icell,'LineWidth',2);
        ylabel('I [A]');
        title('Current')
        set(gca,'XTickLabel',[]);
        xlim([0 tsim(end,1)]);
    subplot(2,2,2); 
        plot(tsim,Pcell,'LineWidth',2);
        ylabel('P [mW]');
        title('Power')
        set(gca,'XTickLabel',[]);
        xlim([0 tsim(end,1)]);
    subplot(2,2,3); 
        plot(tsim,Xe,tsim,Xm,'-.','LineWidth',2);
        legend('El.','Met.','Location','Best');
        ylabel('X [mg/L]');
        xlabel('t [h]');
        title('Bacteria');
        xlim([0 tsim(end,1)]);
    subplot(2,2,4); 
        plot(tsim,Mox,tsim,par.Mtotal-Mox,'-.','LineWidth',2);
        legend('Oxi.','Red.','Location','Best');
        ylabel('M [mg-M/mg-X_e]');
        xlabel('t [h]');
        title('Mediator concentration')
        xlim([0 tsim(end,1)]);
    set(figure(4), 'color', 'white')
    
    figure(5)
    subplot(2,1,1); 
        plot(tsim,Vc,'LineWidth',2);
        ylabel('Vc [mV]');
        title('Voltage capacitor')
        set(gca,'XTickLabel',[]);
        xlim([0 tsim(end,1)]);
    subplot(2,1,2); 
        plot(tsim,Vcell,'LineWidth',2);
        ylabel('Vcell [mW]');
        title('Voltage cell')
        xlabel('t [h]');
        xlim([0 tsim(end,1)]);
    set(figure(5), 'color', 'white')
    
end


