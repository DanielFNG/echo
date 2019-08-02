% metric = 'Peak Hip';
%  torque = 10;
% 
% x = zeros(3, 1);
% x(1,1) = max(results.ObjectiveTrace);
% x(2,1) = mean(results.ObjectiveTrace);
% x(3,1) = min(results.ObjectiveTrace);
% 
% figure
% c = categorical({'Maximum', 'Mean', 'Minimum'});
% bar(c, x);
% title(metric);
% ylabel(['|Measured ' metric ' - baseline ' metric '|']);
% set(gca, 'FontSize', 20);

%figure
% plot(generateAssistiveProfile(100, torque, results.XAtMinObjective.rise, ...
%     results.XAtMinObjective.peak, results.XAtMinObjective.fall), ...
%     'LineWidth', 4.0);
% title('Optimised Assistive Profile');
% xlabel('% of Gait Cycle');
% ylabel('Torque (Nm)');
% set(gca, 'FontSize', 20);

x = zeros(5, 1);
