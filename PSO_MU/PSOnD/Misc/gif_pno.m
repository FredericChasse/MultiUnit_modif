clear all 
close all

%% Generate data

nIterations = 50;

ocv = 0.8;
rInt = 100;
optPower = ones(1,nIterations) * ocv^2*rInt/(2*rInt)^2;
optPos = ones(1, nIterations) * rInt;

delta = 5;
k = 1;

d = zeros(1, nIterations);
J = d;
dInit = 150;

d(1) = dInit;

for i = 1 : nIterations
  J(i) = ocv^2*d(i)/(d(i)+rInt)^2;
  
  if i > 1 && J(i) < J(i-1)
    k = -k;
  end
  
  if i < nIterations
    d(i+1) = d(i) + k*delta;
  end
end

% figure(1)
% subplot(2,1,1)
% plot(d)
% subplot(2,1,2)
% plot(J)



%% Gif

% fig = figure(1);
% figPos = fig.Position;
% % figPos(2) = figPos(2) / 4;
% figPos(3) = figPos(3) * 2.4;
% set(fig, 'Position', figPos);
fig = figure('units','normalized','outerposition',[0 0 1 1]);

textpos = [15 1.58e-3];
axisVar = [0 50 90 160; 0 50 1.52e-3 1.61e-3];

outfile = 'pno.gif';

% colors = [0         0.4470    0.7410; ...
%           0.8500    0.3250    0.0980; ...
%           0.9290    0.6940    0.1250; ...
%           0.4940    0.1840    0.5560; ...
%           0.4660    0.6740    0.1880; ...
%           0.3010    0.7450    0.9330; ...
%           0.6350    0.0780    0.1840; ...
%           0.3000    0.4350    0.3780];
% 
%     
% for iParticle = 1 : nParticles
%   legends{iParticle} = ['Particle ' num2str(iParticle)];
% end
% legends{nParticles+1} = ['Objective function'];

 
for i=1:nIterations
 
    clf
    
    subplot(2,1,1)
    plot(d(1:i), 'Linewidth', 2)
    hold on
    plot(optPos, 'Linewidth', 1.5, 'LineStyle', '--')
    axis(axisVar(1,:))
    title('Évolution de la résistance externe', 'FontSize', 20)
    ylabel('Résistance externe (\Omega)', 'FontSize', 20)
    xlabel('Itération', 'FontSize', 20)
    legend({'R_e_x_t', 'Résistance optimale'}, 'FontSize', 20)
    grid on;
    
    subplot(2,1,2)
    plot(J(1:i), 'Linewidth', 2)
    hold on
    plot(optPower, 'Linewidth', 1.5, 'LineStyle', '--')
    title('Évolution de la puissance de sortie', 'FontSize', 20)
    legend({'P_o_u_t', 'Puissance optimale'}, 'Location', 'southeast', 'FontSize', 20)
    axis(axisVar(2,:))
    xlabel('Itération', 'FontSize', 20)
    ylabel('Puissance de sortie (W)', 'FontSize', 20)
    grid on;
    text(textpos(1), textpos(2), 'P_o_u_t = OCV^2 * R_e_x_t / (R_i_n_t + R_e_x_t)^2', 'FontSize', 20);
    text(textpos(1), textpos(2)-0.015e-3, ['OCV = ', num2str(ocv), ' V'], 'FontSize', 20);
    text(textpos(1), textpos(2)-0.030e-3, ['R_i_n_t = ', num2str(rInt), ' \Omega'], 'FontSize', 20);
    
%     text(textpos(1), textpos(2)+0.00025, ['PSO iteration  = ' num2str(psoIteration)], 'FontSize', 14);
%     text(textpos(1), textpos(2), ['Time elapsed = ' num2str(i*tSample,'%.2f') 'h'], 'FontSize', 14);
    
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
    else
        imwrite(imind,cm,outfile,'gif','DelayTime',0,'writemode','append');
    end
 
end