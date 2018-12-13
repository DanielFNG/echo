function segmentTRC(file, save_dir)
    if ~exist(save_dir, 'dir')
        mkdir(save_dir)
    end
    big = Data(file);
    
    % Convert labels to correct format. 
    for i=3:3:87
        big.Labels{i} = strrep(big.Labels{i}, '.', '_');
    end
    big.Header{4} = strrep(big.Header{4}, '.', '_');
    
    [~, indices] = findpeaks(big.Values(1:end, 64));
    n_cycles = length(indices) - 1;
    cycles = cell(1, n_cycles);
    for i=1:n_cycles
        cycles{i} = indices(i):indices(i+1);
    end
    
    for i=1:length(cycles)
        cycle = big.slice(cycles{i});
        cycle.writeToFile([save_dir filesep 'cycle' num2str(i) '.trc']);
    end
end