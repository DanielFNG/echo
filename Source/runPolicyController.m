function runPolicyController(settings)

% Create top-level filestructure.
processed_dir = [settings.base_dir filesep 'processed'];
segment_dir = [settings.base_dir filesep 'gait_cycles'];
opensim_dir = [settings.base_dir filesep 'opensim'];
mkdir(processed_dir);
mkdir(segment_dir);
mkdir(opensim_dir);

% Construct optimisation variables. 
rise = optimizableVariable('rise', settings.rise_range, 'Type', 'integer');
peak = optimizableVariable('peak', settings.peak_range, 'Type', 'integer');
fall = optimizableVariable('fall', settings.fall_range, 'Type', 'integer');
optimisation_variables = [rise, peak, fall];

% Initialise Bayesian optimisation with a single step, & save result.
iteration = 1;
results = bayesopt(@generalObjectiveFunction, ...
    optimisation_variables, ...
    'XConstraintFcn', settings.parameter_constraints, ...
    'AcquisitionFunctionName', settings.acquisition_function, ...
    'MaxObjectiveEvaluations', 1, ...
    'PlotFcn', []);
save(save_file, 'results', 'iteration');

% Run Bayesian optimisation for remaining steps. 
while iteration <= max_iterations - 1
    iteration = iteration + 1;
    old_results = results;
    try
        results = old_results.resume('MaxObjectiveEvaluations', 1);
    catch err
        disp(err.message);
        input('Press enter when ready to retry.\n');
        results = old_results;
        iteration = iteration - 1;
    end
    save(settings.save_file, 'results', 'iteration');
end

    

    function result = generalObjectiveFunction(X)
        
        % Communicate with APO to apply correct torque pattern.
        % Actually in the mean-time this will be operator controlled, since one
        % will be needed for putting Vicon live anyway. A beep will tell the
        % operator to update the control parameters on the APO side during the
        % non-assisted phase of the current trial.
        fprintf('Apply rise %i, peak %i, fall %i.\n', X.rise, X.peak, X.fall);
        beep;
        
        % Construct filenames & create directories. 
        paths = constructPaths(settings);
        for i=1:length(paths.directories)
            mkdir(paths.directories(i);
        end
        
        % Every 2s check for the existence of the trial data.            
        pauseUntilWritable(paths.marker_file, 2);
        pauseUntilWritable(paths.grf_file, 2);    
        
        % Processing - I feel like this should probably be it's own function! Also I really would like to remove the implicit writing to file within as much of this as possible. Needless writing to file is just going to slow things down at the end of the day, no point in it if I'm just reading things back in as Data objects in the end anyway.
        int_grf = produceMOT(grf_file, settings.base_dir);
        [markers, grfs] = ...
            synchronise(marker_file, int_grf, settings.time_delay);
        markers.rotate(settings.marker_rotations{:});
        grfs.rotate(settings.grf_rotations{:});
        
        % File creation
        markers.writeToFile(processed_markers);
        grfs.writeToFile(processed_grfs);
        
        %% Segmentation
        
        % Segment.
        %segment('left', 'stance', 40, processed_grfs, processed_markers, int_seg_dir);
        segment('right', 'stance', 40, processed_grfs, processed_markers, int_seg_dir);
        % Only doing this for right foot for now, for quicker testing.
        
        %% OpenSim compuations
        
        % Run appropriate OpenSim analyses.
        n_cycles = length(marker_files);
        hip_rom = zeros(1, n_cycles);
        for i=1:n_cycles
            
            % Directory for results storage.
            results = [osim_save_dir filesep 'cycle' sprintf('%03i', i)];
            
            % Create OpenSimTrial
            ost = OpenSimTrial(...
                settings.model_file, ...
                [int_seg_dir filesep marker_files(i).name], ...
                results, [int_seg_dir filesep grf_files(i).name]);
            
            % Run IK.
            ost.run('IK');
            % ost{i}.run('BK');
            % ost{i}.run('ID');
            % Only doing IK for now for ease of testing.
            
            % Compute metric.
            ost_results = OpenSimResults(ost, {'IK'});
            hip_rom(i) = metric(ost_results, settings.args{:});
        end
        
        % If required, calculate the relative baseline for this trial.
        % Not for now.
        
        % Compute & report metric data.
        result = sum((hip_rom - settings.baseline).^2)/n_cycles;
        
    end

end

