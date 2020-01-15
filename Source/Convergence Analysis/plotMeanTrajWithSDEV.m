function plotMeanTrajWithSDEV(data)
% Data is a matrix, rows are samples, each column a separate measurement
% (e.g. increase in time or something). 

    mean_traj = mean(data, 1);
    std_traj = std(data, 0, 1);
    
    upper = mean_traj + std_traj;
    lower = mean_traj - std_traj;
    
    x1 = 1:length(mean_traj);
    x2 = [x1, fliplr(x1)];
    shade = [upper, fliplr(lower)];
    
    figure;
    fill(x2, shade, 'g');
    hold on;
    plot(x1, mean_traj, 'r', 'LineWidth', 2);
    
end