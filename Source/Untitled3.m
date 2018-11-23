apo_controller_frequency = 100;
gait_cycle_length = 1.0596;
peak_force = 5;
n_points = round(apo_controller_frequency*gait_cycle_length);

figure
hold on
cmap = colormap;

thing = m_irr + 2 * s_irr;
%c = round(1+(size(cmap,1)-1)*(means - min(means))/(max(means)-min(means)));
%c = round(1+(size(cmap,1)-1)*(sdevs - min(sdevs))/(max(sdevs)-min(sdevs)));
c = round(1+(size(cmap,1)-1)*(thing - min(thing))/(max(thing)-min(thing)));
for i=1:20
    plot(generateAssistiveProfile(n_points, peak_force, results.XTrace{i, 1}, results.XTrace{i, 2}, results.XTrace{i, 3}), 'color', cmap(c(i),:), 'linewidth', 1);
end
colorbar