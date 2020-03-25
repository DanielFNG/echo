function processed_mean = processMetabolicData(metabolic_data)

    % Get raw data. 
    time = metabolic_data.Timesteps;
    raw = (metabolic_data.getColumn('Metabolic Equivalent'));
    raw = raw * 1.163; % Get metabolic rate in terms of W/kg. 
    processed = zeros(length(time));
    processed_mean = zeros(length(time));

    % Compute the rest period.
    indices = time >= 300 & time <= 600;
    calc_indices = time >= 480 & time <= 600;
    cost = mean(raw(calc_indices));
    processed(indices) = cost;
    processed_mean(indices) = cost;

    % Compute the non-assisted period.
    indices = time >= 600 & time <= 900;
    calc_indices = time >= 900 - 120 &  time <= 900;
    cost = mean(raw(calc_indices));
    processed(indices) = cost;
    processed_mean(indices) = cost;
    
    function cost = processLongPeriod(start, finish, prev_cost)
        
        indices = time >= start & time <= finish;
        prev_time_index = find(indices == 1, 1, 'first') - 1;
        cost = computeInstantaneousMetabolicCost(...
            time(indices), raw(indices), time(prev_time_index), prev_cost);
        processed(indices) = cost;
        reduced_indices = time >= finish - 120 & time <= finish;
        test = raw(reduced_indices);
%         while true
%             x = isoutlier(raw(reduced_indices));
%             test(x) = [];
%             if ~any(isoutlier(test))
%                 break;
%             end
%         end
        processed_mean(indices) = mean(test);
        
    end

    % Helper function to compute process assisted data.
    function cost = processShortPeriod(start, finish, prev_cost)

        indices = time >= start & time <= finish;
        prev_time_index = find(indices == 1, 1, 'first') - 1;
        cost = computeInstantaneousMetabolicCost(...
            time(indices), raw(indices), time(prev_time_index), prev_cost);
        processed(indices) = cost;
        processed_mean(indices) = mean(raw(indices));

    end

    % Compute the first assisted period (needed warm up here).
    indices = time >= 1200 & time <= 1500;
    calc_indices = time >= 1500 - 120 &  time <= 1500;
    cost = mean(raw(calc_indices));
    processed(indices) = cost;
    processed_mean(indices) = cost;

    % Compute the assisted periods - hard coded times for now.
    cost = processLongPeriod(1500, 1800, cost);
    cost = processLongPeriod(1800, 2100, cost);
    cost = processLongPeriod(2100, 2400, cost);
    
    % Compute the rest measurement.
    indices = time >= 2400 & time <= 2700;
    calc_indices = time >= 2700 - 120 & time <= 2700;
    cost = mean(raw(calc_indices));
    processed(indices) = cost;
    processed_mean(indices) = cost;
    
    % Compute the non-assisted period (needed warm up here).
    indices = time >= 3030 & time <= 3330;
    calc_indices = time >= 3330 - 120 &  time <= 3330;
    cost = mean(raw(calc_indices));
    processed(indices) = cost;
    processed_mean(indices) = cost;
    
    % Compute the assisted periods - hard coded times for now.
    cost = processLongPeriod(3330, 3630, cost);
    cost = processLongPeriod(3630, 3930, cost);
    cost = processLongPeriod(3930, 4230, cost);
    cost = processLongPeriod(4230, 4530, cost);
    
    % Compute the final non-assisted period.
    indices = time >= 4860 & time <= 5160;
    calc_indices = time >= 5160 - 120 &  time <= 5160;
    cost = mean(raw(calc_indices));
    processed(indices) = cost;
    processed_mean(indices) = cost;
    
    % NaN-ing data for visualisation purposes.

    % Plot the processed data.
    figure;
    plot(time, raw);
    hold on;
    %plot(time, processed);  This clearly isn't working at the moment, not
    %very well anyway. 
    plot(time, processed_mean);

end