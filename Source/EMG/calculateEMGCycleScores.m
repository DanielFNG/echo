function [total, scores] = calculateEMGCycleScores(emg_data)
% Calculate EMG score of EMG data for a single gait cycle.
%
%   Inputs:
%       - emg_data, a TXTData object populated with EMG voltage signals for
%           a single gait cycle
%       - seg_times, a cell array of timesteps, each of which corresponds to 
%         one gait cycle
%
%   Output:
%       - score, the averaged integrated EMG signal for each gait cycle

    % Obtain the time array, array of channels and the number of channels. 
    time = emg_data.getTimesteps();
    channels = 3:emg_data.NCols;
    n_channels = length(channels);
    
    % Integrate each channels EMG curve.
    scores = zeros(1, n_channels);
    for i=1:n_channels
        signal = processEMGSignal(emg_data.getColumn(channels(i)));
        scores(i) = trapz(time, signal);
    end
    
    % Compute a total score as well.
    total = mean(scores);

end