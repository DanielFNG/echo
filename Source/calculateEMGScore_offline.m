function [score, scores, combined, channel_array] = ...
    calculateEMGScore_offline(emg_data, seg_times)
% Calculate EMG score of some collected EMG data.
%
%   Inputs:
%       - emg_data, a TXTData object populated with EMG voltage signals
%       - seg_times, a cell array of timesteps, each of which corresponds to 
%         one gait cycle
%
%   Output:
%       - score, the averaged integrated EMG signal for each gait cycle

    channel_array = calculateIntegratedEMG(emg_data, seg_times);
    
    n_channels = length(channel_array);
    scores = zeros(1, n_channels);
    combined = zeros(1, length(channel_array{1}));
    
    for i = 1:n_channels
        scores(i) = mean(channel_array{i});
        combined = combined + channel_array{i};
    end
    combined = combined/n_channels;
    
    % Compute the total score. Currently the average of all channels.
    score = mean(scores);

end