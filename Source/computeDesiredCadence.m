function cadence = computeDesiredCadence(settings, markers, grfs)

    % Parameters
    analyses = {'GRF'};

    % Set up trials & data matrices.
    results = [settings.base_dir filesep settings.cadence_folder];
    trials = createTrials(settings.model, markers, results, grfs);
    n_trials = length(trials);
    cycles = cell(1, n_trials);
    
    % Compute BPM for each trial. 
    for i=1:n_trials
        motion_data = SimData(trials{i}, settings.leg_length, ...
            settings.toe_length, analyses);
        cycles{i} = GaitCycle(motion_data);
    end
    
    % Result - take mean and round.
    [time, ~] = computeMeanMetric(cycles, @calculateTotalTime);
    cadence = round(60/time);
end