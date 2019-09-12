function cadence = computeDesiredCadence(settings, markers, grfs)

    % Parameters
    analyses = {'GRF'};

    % Set up trials & data matrices.
    results = [settings.base_dir filesep settings.cadence_folder];
    trials = createTrials(settings.model, markers, results, grfs);
    n_trials = length(trials);
    cadence_data = zeros(1, n_trials);
    
    % Compute BPM for each trial. 
    for i=1:n_trials
        motion_data = MotionData(trials{i}, settings.leg_length, ...
            settings.toe_length, analyses, settings.grf_cutoff);
        cycle = GaitCycle(motion_data);
        cadence_data(i) = 60/cycle.calculateTotalTime(); % steps/min e.g. bpm
    end
    
    % Result - take mean and round.
    cadence = round(mean(cadence_data));
end