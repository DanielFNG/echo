root = 'D:\Dropbox\PhD\EMG Test Data (Reference 2)';
raw = [root filesep 'Collected Data'];
processed = [root filesep 'Processed'];

system.forward = ... % Needs filled in
speed = 1.0;
inclination = 0;
direction = 'x';
feet = {'left'};
mode = 'stance';
cutoff = 2;

for i=0:36
    emg_file = [raw filesep 'emg_second_go' sprintf('%03i', i) '.csv'];
    grf_file = [raw filesep 'emg_second_go' sprintf('%03i', i) '.txt'];
    seg_dir = [processed filesep 'seg' sprintf('%03i', i)];
    osim_dir = [];
    
    times = processGRFData(seg_dir, grf_file, system, speed, inclination, ...
        feet, mode, cutoff, 'GRF');
    emg_data = parseEMGDataFaster(emg_file);
    
    % Segment the EMG data.
    mkdir([seg_dir filesep 'EMG']);
    n_cycles = length(times);
    for n=1:n_cycles
        start = times{n}(1);
        finish = times{n}(end);
        emg_sliced = emg_data.slice(start, finish);
        emg_sliced.writeToFile([seg_dir filesep 'EMG' filesep num2str(n)]);
    end
end