% Change title to name of metric!
metric = 'MoS Min';

% Change torque value!
torque = 10;

plot_vals = zeros(3, 1);
plot_vals(1,1) = max(results.ObjectiveTrace);
plot_vals(2,1) = mean(results.ObjectiveTrace);
plot_vals(3,1) = min(results.ObjectiveTrace);

figure;
c = categorical({'Maximum', 'Mean', 'Minimum'});
bar(c, plot_vals);

ylabel(['|Measured ' metric ' - baseline ' metric '|']);
title(metric);
set(gca, 'FontSize', 20);

control_vals = results.XAtMinObjective;
figure;
plot(generateAssistiveProfile(100, torque, control_vals.rise, ...
    control_vals.peak, control_vals.fall), 'LineWidth', 4.0);
title('Optimised Assistive Profile');
xlabel('% of Gait Cycle');
ylabel('Torque (Nm)');
set(gca, 'FontSize', 20);
