function result = generalObjectiveFunction(X, settings)

    global G__iteration;

    function paths = constructPaths(settings, G__iteration)
        % Construct the mid-level strings & paths for the policy controller.
        
        % Marker & grf file names.
        paths.strings.markers = ...
            [settings.v_name sprintf(settings.v_format, G__iteration)];
        paths.strings.grfs = ...
            [settings.d_name sprintf(settings.d_format, G__iteration)];
        
        % Raw marker & grf files.
        paths.files.markers = ...
            [settings.base_dir filesep paths.strings.markers '.trc'];
        paths.files.grfs = ...
            [settings.base_dir filesep paths.strings.grfs '.txt'];
        
        % Marker & grf save folders;
        paths.strings.marker_folder = 'Markers';
        paths.strings.grf_folder = 'GRF';
        
        % Inner-level directories for saving segmentation & OpenSim results.
        paths.directories.segmented_inner = [settings.dirs.segmented ...
            filesep 'iteration' sprintf('%03i', G__iteration)];
        paths.directories.opensim_inner = [settings.dirs.opensim ...
            filesep 'iteration' sprintf('%03i', G__iteration)];
    end

    % Convert control parameters.
    rise = settings.multiplier*X.rise;
    peak = settings.multiplier*X.peak;
    fall = settings.multiplier*X.fall;

    switch settings.operation_mode

        case 'online'

            % Apply APO torque pattern.
            fprintf('Apply rise %i, peak %i, fall %i.\n', rise, peak, fall);
            beep;
            input('Press any key to continue.');

            % Construct filenames & create directories.
            paths = constructPaths(settings, G__iteration);

            % Wait until data has finished being printed.
            waitUntilWritable(paths.files.markers, 2);
            waitUntilWritable(paths.files.grfs, 2);

            % Process the data, fixing any gaps at the start/end of trials.
            try
                processMotionData(...
                    paths.directories.segmented_inner, ...
                    paths.directories.segmented_inner, ...
                    paths.files.markers, paths.files.grfs, ...
                    settings.marker_rotations, settings.grf_rotations, ...
                    settings.time_delay, settings.feet, ...
                    settings.segmentation_mode, ...
                    settings.segmentation_cutoff, ...
                    paths.strings.marker_folder, paths.strings.grf_folder);
            catch err
                if strcmp(err.identifier, 'Data:Gaps')

                    % Remove problematic frames from data.
                    removeMissingFrames(marker_file, grf_file);

                    % Retry processing the gait data.
                    processMotionData(...
                        paths.directories.segmented_inner, ...
                        paths.directories.segmented_inner, ...
                        paths.files.markers, paths.files.grfs, ...
                        settings.marker_rotations, settings.grf_rotations, ...
                        settings.time_delay, settings.feet, ...
                        settings.segmentation_mode, ...
                        settings.segmentation_cutoff, ...
                        paths.strings.marker_folder, paths.strings.grf_folder);
                else
                    fprintf('No current fix for detected error.\n');
                    rethrow(err);
                end
            end

            % Run appropriate OpenSim analyses.
            markers_folder = [paths.directories.segmented_inner filesep ...
                'right' filesep paths.strings.marker_folder];
            grf_folder = [paths.directories.segmented_inner filesep ...
                'right' filesep paths.strings.grf_folder];
            trials = runBatch(settings.opensim_analyses, settings.model_file,...
                markers_folder, paths.directories.opensim_inner, grf_folder);
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

        case 'offline'

            % Load motion data.
            sep = settings.sep;
            S = load([settings.save_file_dir filesep num2str(rise) sep ...
                num2str(peak) sep num2str(fall) '.mat'], settings.var);
            cycles = S.(settings.var);

    end
    
    % If required, calculate the relative baseline for this trial - not yet
    % implemented, so...
    comparison = settings.baseline;
    
    % Compute & report difference from baseline.
    result = computeMeanMetricDifference(...
        cycles, comparison, settings.metric, settings.args{:});

end