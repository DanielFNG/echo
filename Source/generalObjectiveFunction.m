function result = generalObjectiveFunction(X, settings)

    function paths = constructPaths(settings, dirs, iteration)
        % Construct the mid-level strings & paths for the policy controller.
        
        % Marker & grf file names.
        paths.strings.markers = ...
            [settings.v_name sprintf(settings.v_format, iteration)];
        paths.strings.grfs = ...
            [settings.d_name sprintf(settings.d_format, iteration)];
        
        % Raw marker & grf files.
        paths.files.markers = ...
            [settings.base_dir filesep paths.strings.markers '.trc'];
        paths.files.grfs = ...
            [settings.base_dir filesep paths.strings.grfs '.txt'];
        
        % Inner-level directories for saving segmentation & OpenSim results.
        paths.directories.segmented_inner_grf = ...
            [dirs.segmented filesep 'grf_iteration' sprintf('%03i', iteration)];
        paths.directories.segmented_inner_markers = ...
            [dirs.segmented filesep 'markers_iteration' sprintf('%03i', iteration)];
        paths.directories.opensim_inner = ...
            [dirs.opensim filesep 'iteration' sprintf('%03i', iteration)];
    end

    switch settings.operation_mode

        case 'online'

            % Apply APO torque pattern.
            [markers, grfs] = applyTorquePattern(X, iteration);

            % Construct filenames & create directories.
            paths = constructPaths(settings, dirs, iteration);
            createDirectories(paths.directories);

            % Wait until data has finished being printed.
            waitUntilWritable(markers, 2);
            waitUntilWritable(grfs, 2);

            % Process the data, fixing any gaps at the start/end of trials.
            try
                processMotionData(paths.directories.segmented_inner_markers, ...
                    paths.directories.segmented_inner_grf, ...
                    marker_file, grf_file, ...
                    settings.marker_rotations, settings.grf_rotations, ...
                    settings.time_delay, ...
                    settings.feet, settings.segmentation_mode, ...
                    settings.segmentation_cutoff);
            catch err
                if strcmp(err.identifier, 'Data:Gaps')

                    % Remove problematic frames from data.
                    removeMissingFrames(marker_file, grf_file);

                    % Retry processing the gait data.
                    processMotionData(...
                        paths.directories.segmented_inner_markers, ...
                        paths.directories.segmented_inner_grf, ...
                        marker_file, grf_file, ...
                        settings.marker_rotations, settings.grf_rotations, ...
                        settings.time_delay, ...
                        settings.feet, settings.segmentation_mode, ...
                        settings.segmentation_cutoff);
                else
                    fprintf('No current fix for detected error.\n');
                    rethrow(err);
                end
            end

            % Run appropriate OpenSim analyses.
            markers_folder = ...
                [paths.directories.segmented_inner_markers filesep 'right'];
            grf_folder = ...
                [paths.directories.segmented_inner_grf filesep 'right'];
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
            S = load([settings.save_file_dir filesep ...
                num2str(settings.multiplier*X.rise) sep ...
                num2str(settings.multiplier*X.peak) sep ...
                num2str(settings.multiplier*X.fall) '.mat'], settings.var);
            cycles = S.(settings.var);

    end
    
    % If required, calculate the relative baseline for this trial - not yet
    % implemented, so...
    comparison = settings.baseline;
    
    % Compute & report difference from baseline.
    result = computeMeanMetricDifference(...
        cycles, comparison, settings.metric, settings.args{:});

end