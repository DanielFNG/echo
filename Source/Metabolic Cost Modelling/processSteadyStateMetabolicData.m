function measurements = processSteadyStateMetabolicData(...
    metabolic_data, times, calc_interval, full_interval)

    % Helper function to average metabolic cost within a given interval.
    function [cost, indices] = computeAverage(...
            data, time, finish_time, calc_interval, full_interval)
        calc_indices = ...
            time >= finish_time - calc_interval & time <= finish_time;
        indices = time >= finish_time - full_interval & time <= finish_time;
        cost = mean(data(calc_indices));
    end

    % Typically the measurement interval is 2mins.
    if nargin < 3
        calc_interval = 120;
    end

    % Get raw data. 
    time = metabolic_data.Timesteps;
    raw = (metabolic_data.getColumn('Metabolic Equivalent'));
    raw = raw * 1.163; % Get metabolic rate in terms of W/kg.
    
    % Plot raw data.
    figure;
    hold on;
    plot(time, raw);
    
    % Compute the average metabolic rates.
    n_measurements = length(times);
    measurements = zeros(1, n_measurements);
    for i=1:n_measurements
        [measurements(i), indices] = ...
            computeAverage(raw, time, times(i), calc_interval, full_interval);
        plot(time(indices), ones(1, length(time(indices)))*measurements(i), ...
            'LineWidth', 2.0, 'color', 'r');
    end
    

end