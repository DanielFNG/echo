function channel_array = calculateIntegratedEMG(emg_data, seg_times)

    % Process the EMG data.
    voltage_cols = 3:emg_data.NCols;
    for col = voltage_cols
        signal = emg_data.getColumn(col);
        signal = processEMGSignal(signal);
        emg_data.setColumn(col, signal);    
    end
    
    % Segment the EMG data.
    n_cycles = length(seg_times);
    emg_set = cell(1, n_cycles);
    for i=1:n_cycles
        start = seg_times{i}(1);
        finish = seg_times{i}(end);
        emg_set{i} = emg_data.slice(start, finish);
    end
    
    % Compute channel array. 
    n_channels = length(voltage_cols);
    channel_array = cell(1, n_channels);
    for i=1:n_channels
        value_array = zeros(1, n_cycles);
        for j=1:n_cycles
            time = emg_set{j}.Timesteps;
            value_array(j) = trapz(time, emg_set{j}.getColumn(voltage_cols(i)));
        end
        channel_array{i} = value_array;
    end

end