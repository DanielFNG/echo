methods = {'Probability of Improvement', 'Expected Improvement', 'Expected Improvement Plus (Exploration = 0.3)', 'Expected Improvement Plus (Exploration = 0.8)'};
strings = {'', '-EI', '-EIP0.3', '-EIP0.8'};
known_minimum = ones(1, 24)*1.7207;
iterations = 1:24;

figure
for i=1:4
    subplot(2, 2, i);
    hold on;
    for j=1:5
        if j == 1
            title(methods{i}, 'FontSize', 20);
        end
        S = load(['span-results-right-hip-rom' num2str(j) strings{i} '.mat'], 'results');
        plot(iterations, S.results.EstimatedObjectiveMinimumTrace - known_minimum, 'LineWidth', 2.0);
    end
    ylim([0, 4.5]);
    xlim([1 24]);
    xlabel('Iteration #', 'FontSize', 15);
    ylabel('|Estimated min - actual min|', 'FontSize', 15);
    legend('Trial 1', 'Trial 2', 'Trial 3', 'Trial 4', 'Trial 5');
    ax = gca;
    ax.FontSize = 12;
end
        