function runPolicyController(settings)
% Runs policy controller given adequete settings. 
%
% This function is designed to be called from the policy_controller_setup 
% script.

% Create top-level filestructure.
dirs.processed = [settings.base_dir filesep 'processed'];
dirs.segemented = [settings.base_dir filesep 'gait_cycles'];
dirs.opensim = [settings.base_dir filesep 'opensim'];
createDirectories(dirs);

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
    % General objective function for Bayesian optimisation.
    %
    % This is defined within this file to allow access to the settings 
    % structure, containing necessary information such as model filename
    % for example.
    %
    % This function by necessity carries out a few different steps:
    %   1) Applies the APO torque pattern suggested by bayesopt
    %   2) Waits for the corresponding motion data to be collected
    %   3) Processes & segments the motion data
    %   4) Runs the necessary OpenSim analyses on the data
    %   5) Computes & averages the metric data for each collected gait cycle.
        
        % Communicate with APO to apply correct torque pattern.
        % Actually in the mean-time this will be operator controlled, since one
        % will be needed for putting Vicon live anyway. A beep will tell the
        % operator to update the control parameters on the APO side during the
        % non-assisted phase of the current trial.
        fprintf('Apply rise %i, peak %i, fall %i.\n', X.rise, X.peak, X.fall);
        beep;
        
        % Construct filenames & create directories. 
        paths = constructPaths(settings, dirs, iteration);
        createDirectories(paths.directories);
        
        % Every 2s check for writability of the trial data.            
        pauseUntilWritable(paths.files.markers, 2);
        pauseUntilWritable(paths.files.grfs, 2);    
        
        % Processing.
        int_grf = produceMOT(paths.files.grfs, settings.base_dir);
        [markers, grfs] = ...
            synchronise(paths.files.markers, int_grf, settings.time_delay);
        markers.rotate(settings.marker_rotations{:});
        grfs.rotate(settings.grf_rotations{:});
        markers.writeToFile(paths.files.processed_markers);
        grfs.writeToFile(paths.files.processed_grfs);
        segment('right', 'stance', 40, paths.files.processed_grfs, ...
            paths.files.processed_markers, paths.directories.segmented_inner);
        % Only doing segmentation for right foot for now, for quicker testing.
        
        % Run appropriate OpenSim analyses.
        [n_cycles, gait_cycle_markers] = ...
            getFilePaths(paths.directories.segmented_inner, '.trc');
        [~, gait_cycle_grfs] = ...
            getFilePaths(paths.directories.segmented_inner, '.mot');
        
        metric_data = zeros(1, n_cycles);
        for i=1:n_cycles
            
            % Directory for results storage.
            results = [paths.directories.opensim_inner ...
                filesep 'cycle' sprintf('%03i', i)];
            
            % Create OpenSimTrial
            ost = OpenSimTrial(settings.model_file, gait_cycle_markers{i}, ...
                results, gait_cycle_grfs{i});
            
            % Run analyses.
            for j=1:length(settings.analyses)
                ost.run(analyses{j});
            end
            
            % Compute metric.
            ost_results = OpenSimResults(ost, {'IK'});
            metric_data(i) = metric(ost_results, settings.args{:});
        end
        
        % If required, calculate the relative baseline for this trial.
        % Not for now.
        
        % Compute & report metric data.
        result = sum((metric_data - settings.baseline).^2)/n_cycles;
        
    end

end

