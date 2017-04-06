clear all 
close all

oDoSequential = 1;
oPlotTheLines = 0;

% %% Objective functions (nParticles == 4)
% 
% [rFigSeq , TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\Été 2016\Article\Présentation\gif\ramp_4_cells_series.xlsx','R');
% [pFigSeq , TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\Été 2016\Article\Présentation\gif\ramp_4_cells_series.xlsx','P');
% 
% [rFigPara, TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\Été 2016\Article\Présentation\gif\ramp_1_cells_series.xlsx','R');
% [pFigPara, TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\Été 2016\Article\Présentation\gif\ramp_1_cells_series.xlsx','P');

%% Sequential PSO

dstr = ['d'];
jstr = ['J'];

[Rseq, TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\HybridMuPso\MultiUnit_modif\PSO_MU\PSOnD\Misc\seq.xlsx', dstr);
[Pseq, TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\HybridMuPso\MultiUnit_modif\PSO_MU\PSOnD\Misc\seq.xlsx', jstr);
[staticSeqSteadyState, TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\HybridMuPso\MultiUnit_modif\PSO_MU\PSOnD\Misc\seq.xlsx', 'ss');
% dstr = ['3d'];
% jstr = ['3J'];
% 
% [Rseq, TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\Été 2016\Article\Data\simulation\sequential cell/Sim_data.xlsx', dstr);
% [Pseq, TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\Été 2016\Article\Data\simulation\sequential cell/Sim_data.xlsx', jstr);

% dstr = ['R3'];
% jstr = ['P3'];

% [Rseq, TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\Été 2016\Article\Data\experimentations\sequential/simdata.xlsx', dstr);
% [Pseq, TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\Été 2016\Article\Data\experimentations\sequential/simdata.xlsx', jstr);

% [dummy nParticles] = size(Pseq);
nParticles = 3;

staticSeqSteadyState = staticSeqSteadyState*nParticles;

nIterations = length(Pseq)*nParticles;

dseq = zeros(nIterations, 1);
Jseq = zeros(nIterations, 1);

% dseq = Rseq;
% Jseq = Pseq;

for j = 1:nIterations/nParticles
  dseq(1 + nParticles*(j-1):nParticles + nParticles*(j-1)) = Rseq(j,:);
  Jseq(1 + nParticles*(j-1):nParticles + nParticles*(j-1)) = Pseq(j,:);
end

[dseq_sort isort] = sort(dseq);
% dseq_sort = sort(dseq);
Jseq_sort = Jseq(isort);



%% Parallel PSO

dstr = ['d'];
jstr = ['J'];

[dpar, TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\HybridMuPso\MultiUnit_modif\PSO_MU\PSOnD\Misc/para.xlsx', dstr);
[Jpar, TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\HybridMuPso\MultiUnit_modif\PSO_MU\PSOnD\Misc/para.xlsx', jstr);
[staticParaSteadyState, TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\HybridMuPso\MultiUnit_modif\PSO_MU\PSOnD\Misc\seq.xlsx', 'ss');


for j = 1:nIterations/nParticles
  dpar_all(1 + nParticles*(j-1):nParticles + nParticles*(j-1)) = dpar(j,:);
  Jpar_all(1 + nParticles*(j-1):nParticles + nParticles*(j-1)) = Jpar(j,:);
end

[dpara_sort, isort] = sort(dpar_all);
Jpara_sort = Jpar_all(isort);

%   dstr = ['R10'];
%   jstr = ['P10'];
% 
% [dpar, TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\Été 2016\Article\Data\experimentations\parallel/simdata.xlsx', dstr);
% [Jpar, TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\Été 2016\Article\Data\experimentations\parallel/simdata.xlsx', jstr);

% dstr = ['6d'];
% jstr = ['6J'];
% 
% [dpar, TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\Été 2016\Article\Data\simulation\multi_cell/Sim_data.xlsx', dstr);
% [Jpar, TXT, RAW] = xlsread('C:\Users\ironi\Documents\ETS\Maîtrise\Été 2016\Article\Data\simulation\multi_cell/Sim_data.xlsx', jstr);

nIterationsPar = length(dpar);

%% Gif

iSeq = 1;
iPar = 2;

fig = figure(1);
figPos = fig.Position;
% figPos(2) = figPos(2) / 4;
figPos(3) = figPos(3) * 2.4;
set(fig, 'Position', figPos);

% nParticles = 8;

% for iParticle = 1 : nParticles
%   legends{iParticle} = ['Particle ' num2str(iParticle)];
% end
% 
% legends{iParticle+1} = ['Obj function'];

if oDoSequential
  d = dseq;
  J = Jseq;
  textpos = [200 0.014];
  axisVar = [100 1600 0.013 0.018];
  kSteadyState = 182;
else
  d = dpar;
  J = Jpar;
  kSteadyState = 21;
end

% if oPlotTheLines
%   outfile = 'pso_sequential_vs_parallel_with_lines.gif';
% else
%   outfile = 'pso_sequential_vs_parallel_without_lines_different_delays.gif';
% end

outfile = 'pso_sequential_vs_parallel_pso.gif';

colors = [0         0.4470    0.7410; ...
          0.8500    0.3250    0.0980; ...
          0.9290    0.6940    0.1250; ...
          0.4940    0.1840    0.5560; ...
          0.4660    0.6740    0.1880; ...
          0.3010    0.7450    0.9330; ...
          0.6350    0.0780    0.1840; ...
          0.3000    0.4350    0.3780];

iSeqParticle = 1;
psoIteration = 1;
    
for iParticle = 1 : nParticles
  legends{iParticle} = ['Particle ' num2str(iParticle)];
end
legends{nParticles+1} = ['Objective function'];

tSample = 0.25;
 
for i=1:nIterations
 
    clf
    
    % Sequential PSO
    
    d = dseq;
    J = Jseq;
%     textpos = [200 0.014];
%     axisVar = [100 1600 0.013 0.018];
%     textpos = [150 3e-3];
%     textpos = [150 1.75e-3];
    textpos = [75 0.8e-3];
%     axisVar = [0 800 2e-3 9e-3];
    axisVar = [0 600 0e-3 2.5e-3];
%     kSteadyState = 50;
    kSteadyState = staticSeqSteadyState;
    
    subplot(1,2,iSeq)
%     axis(axisVar)
    title('Sequential PSO on a single MFC')
    hold on
    
    for iParticle = 1:nParticles
      plot(0,0, 'Marker', 'o', 'visible', 'off', 'Color', colors(iParticle,:), 'LineStyle', 'none')
    end
    plot(0,0, 'Marker', 'none', 'LineStyle', '--', 'visible', 'off', 'Color', colors(nParticles+1,:))
    
    legend(legends)
    
    if oPlotTheLines
      plot(d(1:i,1),J(1:i,1), 'linewidth', 1, 'Color', colors(1,:))
    end
    
    xlabel('External load (\Omega)', 'FontSize', 14)
    ylabel('Output power (W)', 'FontSize', 14)
    
%     text(textpos(1), textpos(2)+0.0005, ['i  = ' num2str(psoIteration)], 'FontSize', 14);
%     text(textpos(1), textpos(2), ['k = ' num2str(i)], 'FontSize', 14);
    text(textpos(1), textpos(2)+0.00025, ['PSO iteration  = ' num2str(psoIteration)], 'FontSize', 14);
    text(textpos(1), textpos(2), ['Time elapsed = ' num2str(i*tSample,'%.2f') 'h'], 'FontSize', 14);
    
    if i >= kSteadyState
      if i== kSteadyState
        iSteadyStateSeq = psoIteration;
      end
      text(textpos(1), textpos(2)-0.00025, ['Steady state at 5% @ ' num2str(kSteadyState*tSample,'%.2f') 'h'], 'FontSize', 14);
    end
    
    for j = 1:iSeqParticle
      plot(d(i - (iSeqParticle - j),1),J(i - (iSeqParticle - j),1), 'linewidth', 1, 'Color', colors(j,:),'Marker', 'o', 'MarkerSize', 10)
    end
    iSeqParticle = iSeqParticle + 1;
    if iSeqParticle == nParticles + 1
      iSeqParticle = 1;
      psoIteration = psoIteration + 1;
    end
    
    plot(dseq_sort,Jseq_sort,'--', 'Color', colors(nParticles+1,:), 'LineWidth', 2)
    
    grid on;
    hold off
    
    % Parallel PSO
    
    d = dpar;
    J = Jpar;
%     textpos = [200 2e-3];
%     axisVar = [0 1000 0 2.5e-3];
%     textpos = [150 1.75e-3];
    textpos = [75 0.8e-3];
    axisVar = [0 600 0e-3 2.5e-3];
%     kSteadyState = 16;
    kSteadyState = staticParaSteadyState;
    
    subplot(1,2,iPar)
%     axis(axisVar)
    title('Parallel PSO on 3 identical MFCs')
    hold on
    
    for iParticle = 1:nParticles
      if oPlotTheLines
        plot(0,0, 'Marker', 'none', 'visible', 'off', 'Color', colors(iParticle,:), 'LineStyle', '-')
      else
        plot(0,0, 'Marker', 'o', 'visible', 'off', 'Color', colors(iParticle,:), 'LineStyle', 'none')
      end
    end
    plot(0,0, 'Marker', 'none', 'LineStyle', '--', 'visible', 'off', 'Color', colors(nParticles+1,:))
    
    legend(legends)
    
    if i <= nIterationsPar
      for iParticle = 1 : nParticles
        if oPlotTheLines
          plot(d(1:i,iParticle),J(1:i,iParticle), 'linewidth', 1, 'Color', colors(iParticle,:))
        end
        plot(d(i,iParticle),J(i,iParticle), 'linewidth', 1, 'Color', colors(iParticle,:),'Marker', 'o', 'MarkerSize', 10)
      end
    else
      for iParticle = 1 : nParticles
        if oPlotTheLines
          plot(d(:,iParticle),J(:,iParticle), 'linewidth', 1, 'Color', colors(iParticle,:))
        end
        plot(d(nIterationsPar,iParticle),J(nIterationsPar,iParticle), 'linewidth', 1, 'Color', colors(iParticle,:),'Marker', 'o', 'MarkerSize', 10)
      end
      lol = 1;
    end
    
    xlabel('External load (\Omega)', 'FontSize', 14)
    ylabel('Output power (W)', 'FontSize', 14)
    
    if i <= nIterationsPar
      text(textpos(1), textpos(2)+0.00025, ['PSO iteration  = ' num2str(i)], 'FontSize', 14);
      text(textpos(1), textpos(2), ['Time elapsed = ' num2str(i*tSample,'%.2f') 'h'], 'FontSize', 14);
    else
      text(textpos(1), textpos(2)+0.00025, ['PSO iteration = ' num2str(nIterationsPar)], 'FontSize', 14);
      text(textpos(1), textpos(2), ['Time elapsed = ' num2str(nIterationsPar*tSample,'%.2f')], 'FontSize', 14);
    end
    
    if i >= kSteadyState
      if i== kSteadyState
        iSteadyStatePar = i;
      end
      text(textpos(1), textpos(2)-0.00025, ['Steady state at 5% @ ' num2str(kSteadyState*tSample,'%.2f') 'h'], 'FontSize', 14);
    end
    
    plot(dpara_sort,Jpara_sort,'--', 'Color', colors(nParticles+1,:), 'LineWidth', 2)
    
    grid on;
    hold off
 
    % gif utilities
    set(fig,'color','w'); % set figure background to white
    drawnow;
    frame = getframe(fig);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
 
    % On the first loop, create the file. In subsequent loops, append.
    if i==1
        imwrite(imind,cm,outfile,'gif','DelayTime',0.8,'loopcount',inf);
    elseif i <= staticParaSteadyState
        imwrite(imind,cm,outfile,'gif','DelayTime',0.4,'writemode','append');
    elseif i == staticSeqSteadyState
        imwrite(imind,cm,outfile,'gif','DelayTime',0.4,'writemode','append');
    elseif i == nIterations
        imwrite(imind,cm,outfile,'gif','DelayTime',1.0,'writemode','append');
    else
        imwrite(imind,cm,outfile,'gif','DelayTime',0.0,'writemode','append');
    end
 
end