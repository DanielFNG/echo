function score = calculateEMGScore(emg_data, seg_times)
% Calculate EMG score of some collected EMG data.
%
%   Inputs:
%       - emg_data, a TXTData object populated with EMG voltage signals
%       - seg_times, a cell array of timesteps, each of which corresponds to 
%         one gait cycle
%
%   Output:
%       - score, the averaged integrated EMG signal for each gait cycle

    % Process the EMG data.
    voltage_cols = emg_data.getStateIndices();
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
    
    % Compute the average integrated EMG signal for channel, 
    % averaged over the collected waveforms.
    n_channels = length(voltage_cols);
    value_set = zeros(1, n_channels);
    for i = 1:n_channels
        value = 0;
        for j=1:n_cycles
            time = emg_set{j}.getTimesteps();
            value = value + trapz(times, ...
                emg_set{j}.getColumn(voltage_cols(i)));
        end
        value_set(i) = value/n_cycles;
    end
    
    % Compute the total score. Currently the average of all channels.
    score = mean(value_set);

end