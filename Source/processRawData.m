function cycles = processRawData(markers, grfs, save_dir, settings)

    function process(markers, grfs, save_dir, settings)
        if isempty(markers)
            processGRFData(save_dir, grfs, settings.grf_rotations, ...
                settings.feet, settings.segmentation_mode, ...
                settings.segmentation_cutoff, 'GRF');
        elseif isempty(grfs)
            processMarkerData(save_dir, markers, ...
                settings.marker_rotations, settings.feet, ...
                settings.segmentation_mode, ...
                settings.segmentation_cutoff, 'Markers');
        else
            processMotionData(save_dir, save_dir, markers, grfs, ...
                settings.marker_rotations, settings.grf_rotations, ...
                settings.time_delay, settings.feet, ...
                settings.segmentation_mode, ...
                settings.segmentation_cutoff, 'Markers', 'GRF');
        end
    end

    if strcmp(settings.operation_mode, 'online') && ~isempty(markers)
        % Wait until raw vicon data is available.
        [path, name, ~] = fileparts(markers);
        trial_name = [path name];
        waitUntilWritable([trial_name filesep '.x2d'], 2);
        processViconData(trial_name);
    end

    % Wait until data has finished being printed.
    if ~isempty(markers)
        waitUntilWritable(markers, 2);
    end
    if ~isempty(grfs)
        waitUntilWritable(grfs, 2);
    end
    
    % Some output.
    fprintf('\nRaw data files available. Beginning processing steps now.\n');

    % Process the data, fixing any gaps at the start/end of trials.
    try
        process(markers, grfs, save_dir, settings);
    catch err
        if strcmp(err.identifier, 'Data:Gaps')

            % Remove problematic frames from data.
            removeMissingFrames(markers, grfs);
            
            % Retry processing the gait data.
            process(markers, grfs, save_dir, settings);
        else
            fprintf('No current fix for detected error.\n');
            rethrow(err);
        end
    end

    % Run appropriate OpenSim analyses.
    markers_folder = [save_dir filesep 'right' filesep 'Markers'];
    grf_folder = [save_dir filesep 'right' filesep 'GRF'];
    switch settings.data_inputs
        case 'Motion'
            trials = runBatch(settings.opensim_analyses, settings.model_file,...
                markers_folder, save_dir, grf_folder);
        case 'GRF'
            trials = runBatch(settings.opensim_analyses, settings.model_file,...
                [], save_dir, grf_folder);
        case 'Markers'
            trials = runBatch(settings.opensim_analyses, settings.model_file,...
                markers_folder, save_dir, []);
    end
            
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