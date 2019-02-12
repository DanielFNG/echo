function plotGroundTruth(matrix, name, baseline)

    
    matrix(matrix == 100) = baseline;
    matrix = matrix/baseline*100;
    max_val = max(matrix(matrix ~= 100));
    clims = [0, max_val + 1];
    
    titles = {'Rise', 'Peak', 'Fall'};
    
    nums = [65, 70, 75];
    
    figure;
    sgtitle(upper(name), 'FontSize', 20, 'Color', 'r');
    hold on;
    for i=1:6
        subplot(3, 3, i);
        if i < 4
            h = imagesc(flip(matrix(:, :, i)'), clims);
            title(['Fall = ' num2str(nums(i)) '%'], 'FontSize', 15);
            yticks([1,2,3]);
            yticklabels([60, 55, 50]);
            ax = ancestor(h, 'axes');
            yrule = ax.YAxis;
            yrule.FontSize = 12;
            ylabel('Peak %', 'FontSize', 15);
            xlabel('Rise %', 'FontSize', 15);
            xticks([1,2,3]);
            xticklabels([45, 50, 55]);
            ax = ancestor(h, 'axes');
            xrule = ax.XAxis;
            xrule.FontSize = 12;
        else
            newmat = zeros(3,3);
            for j=1:3
                for k=1:3
                    if i == 4
                        submat = matrix(:, j, k);
                    elseif i == 5
                        submat = matrix(j, :, k);
                    elseif i == 6
                        submat = matrix(j, k, :);
                    end
                    submat = reshape(submat, [3,1]);
                    vals = submat(submat ~= 100);
                    newmat(j, k) = mean(vals);
                end
            end
            newmat(isnan(newmat)) = 100;
            h = imagesc(flip(newmat'), clims);
            title(['Avg by ' titles{i-3}], 'FontSize', 15);
            if i == 4
                yticks([1,2,3]);
                xticklabels([50, 55, 60]);
                yticklabels([75, 70, 65]);
                ylabel('Fall %', 'FontSize', 15);
                xlabel('Peak %', 'FontSize', 15);
            elseif i == 5
                yticks([1,2,3]);
                xticklabels([45, 50, 55]);
                yticklabels([75, 70, 65]);
                ylabel('Fall %', 'FontSize', 15);
                xlabel('Rise %', 'FontSize', 15);
            elseif i == 6
                yticks([1,2,3]);
                xticklabels([45, 50, 55]);
                yticklabels([60, 55, 50]);
                ylabel('Peak %', 'FontSize', 15);
                xlabel('Rise %', 'FontSize', 15);
            end
            ax = ancestor(h, 'axes');
            yrule = ax.YAxis;
            yrule.FontSize = 12;
            ax = ancestor(h, 'axes');
            xrule = ax.XAxis;
            xrule.FontSize = 12;
        end
    end

    up = get(subplot(3, 3, 3), 'Position');
    left = get(subplot(3, 3, 5), 'Position');
    pos = get(subplot(3, 3, 6), 'Position');
    h_gap = pos(1) - left(1) - pos(3);
    v_gap = up(2) - pos(2) - pos(4);
    height = pos(4)*2 + v_gap;
    c = colorbar('Position', [pos(1) + pos(3) + h_gap/4, pos(2), pos(3)/10, height]);
    c.Label.String = '% Diff vs Baseline';
    c.Label.FontSize = 20;
   
    subplot(3, 3, [7, 8, 9]);
    risem = [];
    peakm = [];
    fallm = [];
    for i=1:3
        rise_vals = matrix(i, :, :);
        rise_vals = rise_vals(rise_vals ~= 100);
        risem = [risem mean(rise_vals)];
        
        peak_vals = matrix(:, i, :);
        peak_vals = peak_vals(peak_vals ~= 100);
        peakm = [peakm mean(peak_vals)];
        
        fall_vals = matrix(:, :, i);
        fall_vals = fall_vals(fall_vals ~= 100);
        fallm = [fallm mean(fall_vals)];
    end
    h = plot(risem, 'LineWidth', 2.0);
    title('Overall Average Trend', 'FontSize', 15);
    xticks([1, 2, 3]);
    xticklabels({'Low', 'Mid', 'High'});
    hold on;
    plot(peakm, 'LineWidth', 2.0);
    plot(fallm, 'LineWidth', 2.0);
    lg = legend('rise', 'peak', 'fall', 'Location', 'north');
    lg.FontSize = 14;
    ax = ancestor(h, 'axes');
    yrule = ax.YAxis;
    yrule.FontSize = 12;
    ax = ancestor(h, 'axes');
    xrule = ax.XAxis;
    xrule.FontSize = 12;
    ax = subplot(3, 3, [7 8 9]);
    ylabel('Avg % Diff vs Baseline', 'FontSize', 15);
    xlabel('Parameter Value', 'FontSize', 15);
    ax.Position(2) = ax.Position(2)*0.6;
    
end