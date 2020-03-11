function cost = computeInstantaneousMetabolicCost(...
    time, energy, prev_time, prev_cost) 

    % Time constant
    tau = 42;
    
%     % Outlier removal. 
%     while true
%         indices = isoutlier(energy, 'movmean', 2);
%         energy(indices) = [];
%         time(indices) = [];
%         if ~any(isoutlier(energy, 'movmean', 2))
%             break;
%         end
%     end
    
    % Compute instantaneous cost
    %dt = zeros(length(energy));
    n = length(energy);
    dt = zeros(n, 1);
    %dt(1) = time(1) - prev_time;
    dt(2:end) = time(2:end) - time(1:end-1);
    dt(1) = mean(dt(2:end)); % Temporary measure since our time data has gaps in it. 
    prev_m = zeros(n, 1);
    prev_m(1) = prev_cost;
    prev_m(2:end) = energy(1:end-1);
    f_inst = computeInstantaneousMeasuredCost(tau, dt, energy, prev_m);
    cost = mean(f_inst);
    
end