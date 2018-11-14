function segmentMOT(file, save_dir)
    if ~exist(save_dir, 'dir')
        mkdir(save_dir)
    end
    stance_cutoff = 40;
    big = Data(file);
    indices = find(big.getColumn('ground_force1_vy') > stance_cutoff);
    cycles = {};
    k = 1;
    start = 1;
    for i=1:length(indices)-1
        if indices(i+1) > indices(i) + 5
            cycles{k} = indices(start:i);
            k = k + 1;
            start = i + 1;
        end
    end
    
    for i=1:length(cycles)
        cycle = big.slice(cycles{i});
        cycle.writeToFile([save_dir filesep 'cycle' num2str(i) '.mot']);
    end
end