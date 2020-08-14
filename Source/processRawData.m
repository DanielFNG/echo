function [cycles, fail] = processRawData(...
    markers, grfs, save_dir, osim_dir, settings, assistance_params)

    function process(markers, grfs, save_dir, settings, assistance_params)
        % Load data & store as motions
        marker_data = MarkerData(markers, ...
            settings.vicon_translation, settings.vicon_rotation);
        grf_data = GRFData(grfs, settings.grf_system, settings.inclination);
        motions = {marker_data, grf_data};
        
        % ******
        % THIS NEEDS GENERALISED!! CURRENTLY SETUP FOR MARKERS + GRF AT
        % 0 DELAY ONLY!!!
        % ******
        % Motion processing - specifically without segmentation
        processed_motions = processMotionData(motions, ...
            1, [0, 0], settings.speed, 0, [], []);
        
        % Apply assistance modelling
        grfs = applyParameterisedAssistance(...
            processed_motions{2}.Motion, assistance_params);
        processed_motions{2} = GRFData(grfs, processed_motions{2}.Name);
        
        % ******
        % THIS NEEDS GENERALISED!! CURRENTLY SETUP FOR STANCE
        % SEGMENTATION ONLY
        % Perform segmentation
        segmented_motions = processMotionData(processed_motions, ...
            [], [], [], [], 2, 'Right');
        
        % Write segmented motions
        writeSegmentedMotions(segmented_motions, {save_dir, save_dir});
    end

    if strcmp(settings.operation_mode, 'online')
        if ~isempty(markers)
            % Wait until raw vicon data is available.
            [path, name, ~] = fileparts(markers);
            trial_name = [path filesep name];
            fail = waitUntilWritable([trial_name '.x2d'], 0.5);
            if fail
                cycles = 0;
                return
            end
            pause(4); % 4 second pause to give extra 4s of assistance - so 
                      % as not to confuse subject with audio feedback while 
                      % still recording
            processViconData(trial_name, settings);
        else
            [path, name, ~] = fileparts(grfs);
            trial_name = [path filesep name];
            waitUntilWritable([trial_name '.x2d'], 0.5);
            processViconEMG(trial_name, settings);
        end
    end

    % Wait until data has finished being printed.
    if ~isempty(markers)
        waitUntilWritable(markers, 2);
    end
    if ~isempty(grfs)
        waitUntilWritable(grfs, 2);
    end
    
    % Some output.
    fprintf(...
        '\nRaw data files available. Beginning processing steps now.\n');

    % Process the data, fixing any gaps at the start/end of trials.
    try
        process(markers, grfs, save_dir, settings, assistance_params);
    catch
        % Try one more time incase it wasn't fully printed.
        try
            process(markers, grfs, save_dir, settings, assistance_params);
        catch err
            rethrow(err);
        end
    end

    % Run appropriate OpenSim analyses.
    markers_folder = [save_dir filesep 'right' filesep 'Markers'];
    grf_folder = [save_dir filesep 'right' filesep 'GRF'];
    switch settings.data_inputs
        case 'Motion'
            trials = createTrials(settings.model, markers_folder, ...
                osim_dir, grf_folder);
        case {'GRF', 'EMG'}
            trials = createTrials(settings.model, [], ...
                osim_dir, grf_folder);
        case 'Markers'
            trials = createTrials(settings.model, markers_folder, ...
                osim_dir, []);
    end
    
    % Temporary measure to restrict ourselves to <= 4 trials.
    if length(trials) > 4
        trials = trials(end - 3:end);
    end
    
    trials = runBatchParallel(...
        settings.opensim_analyses, trials, settings.opensim_args{:});
            
    n_samples = length(trials);

    % Create gait cycles.
    if ~strcmp(settings.data_inputs, 'EMG')
        cycles = cell(n_samples, 1);
        leg = settings.leg_length;  % Reduce parfor communication overhead
        toe = settings.toe_length;
        analyses = settings.motion_analyses;
        parfor i=1:n_samples
            motion = MotionData(trials{i}, leg, toe, analyses);
            cycles{i} = GaitCycle(motion);
        end
    else
        cycles = 0;
    end

end