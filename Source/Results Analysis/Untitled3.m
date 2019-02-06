%% This code is wildly out of date.
% When fixed up the way it should work is taking the results of a Bayesian
% Optimisation run and producing the coloured plot of the control signals. 

apo_controller_frequency = 100;
gait_cycle_length = 1.0596;
peak_force = 10.0;
n_points = round(apo_controller_frequency*gait_cycle_length);

figure
%hold on
%cmap = colormap;

% riseTrace = [31.0623, 38.5376, 38.6943, 39.6552, 45.5742];
% peakTrace = [36.2379, 61.581, 43.7305, 67.0379, 52.3673];
% fallTrace = [74.0064, 67.2386, 75.9144, 86.1767, 52.4958];
riseTrace = combos(1,:);
peakTrace = combos(2,:);
fallTrace = combos(3,:);

%thing = m_irr + 2 * s_irr;
%c = round(1+(size(cmap,1)-1)*(means - min(means))/(max(means)-min(means)));
%c = round(1+(size(cmap,1)-1)*(sdevs - min(sdevs))/(max(sdevs)-min(sdevs)));
%c = round(1+(size(cmap,1)-1)*(thing - min(thing))/(max(thing)-min(thing)));
for i=1:size(combos, 2)
    try
        plot(generateAssistiveProfile(n_points, peak_force, riseTrace(i), peakTrace(i), fallTrace(i)), 'linewidth', 1);
    catch 
        display(combos(:, i));
    end
    %plot(generateAssistiveProfile(n_points, peak_force, riseTrace(i), peakTrace(i), fallTrace(i)), 'color', cmap(c(i),:), 'linewidth', 1);
end
colorbar