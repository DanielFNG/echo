function cycles = processRawData(markers, grfs, save_dir, settings)

    % Wait until data has finished being printed.
    waitUntilWritable(markers, 2);
    waitUntilWritable(grfs, 2);
    
    % Some output.
    fprintf('\nRaw data files available. Beginning processing steps now.\n');

    % Process the data, fixing any gaps at the start/end of trials.
    try
        processMotionData(save_dir, save_dir, markers, grfs, ...
            settings.marker_rotations, settings.grf_rotations, ...
            settings.time_delay, settings.feet, ...
            settings.segmentation_mode, ...
            settings.segmentation_cutoff, 'Markers', 'GRF');
    catch err
        if strcmp(err.identifier, 'Data:Gaps')

            % Remove problematic frames from data.
            removeMissingFrames(marker_file, grf_file);

            % Retry processing the gait data.
            processMotionData(save_dir, save_dir, markers, grfs, ...
            settings.marker_rotations, settings.grf_rotations, ...
            settings.time_delay, settings.feet, ...
            settings.segmentation_mode, ...
            settings.segmentation_cutoff, 'Markers', 'GRF');
        else
            fprintf('No current fix for detected error.\n');
            rethrow(err);
        end
    end

    % Run appropriate OpenSim analyses.
    markers_folder = [save_dir filesep 'right' filesep 'Markers'];
    grf_folder = [save_dir filesep 'right' filesep 'GRF'];
    trials = runBatch(settings.opensim_analyses, settings.model_file,...
        markers_folder, save_dir, grf_folder);
    n_samples = length(trials);

    % Create gait cycles.
    cycles = cell(n_samples, 1);
    for i=1:n_samples
        motion = MotionData(trials{i}, settings.leg_length, ...
            settings.toe_length, settings.segmentation_cutoff, ...
            settings.motion_analyses, settings.speed, ...
            settings.direction);
        cycles{i} = GaitCycle(motion);
    end

end