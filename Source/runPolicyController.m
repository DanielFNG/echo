function runPolicyController(settings)
% Runs policy controller given adequete settings. 
%
% This function is designed to be called from the policy_controller_setup 
% script.

if strcmp(settings.operation_mode, 'online')
    % Create top-level filestructure.
    settings.dirs.baseline = [settings.base_dir filesep 'baseline'];
    settings.dirs.segmented = [settings.base_dir filesep 'gait_cycles'];
    settings.dirs.opensim = [settings.base_dir filesep 'opensim'];
    createDirectories(settings.dirs);
end

if strcmp(settings.baseline_mode, 'absolute')
    
    % Some handy output.
    fprintf('\nBeginning baseline computation step.\n');
    input(['Press return confirm you have changed filenames in '...
        'D-Flow and Nexus.'], 's');
    fprintf('\nPlease collect baseline data.\n');
    
    % Construct paths to marker & grf files of baseline data.
    markers = [settings.base_dir filesep settings.baseline_filename '.trc'];
    grfs = [settings.base_dir filesep settings.baseline_filename '.txt'];
    
    % Obtain gait cycles from raw data processing.
    cycles = processRawData(markers, grfs, settings.dirs.baseline, settings);
    
    % Compute the mean value of the metric from the baseline data, & use
    % this as the baseline going forward.
    settings.baseline = computeMeanMetric(...
        cycles, settings.metric, settings.args{:});
    
    % More handy output.
    input(['\nBaseline computation complete.\nPress return once you have' ...
        ' finished changing filenames in Nexus and D-Flow in preparation ' ...
        'for HIL data collection.'], 's');
end

% Create required function handles.
parameter_constraints = ...
    @(X) (parameterConstraints(X, settings.multiplier, settings.min_length));
objective_function = @(X) (generalObjectiveFunction(X, settings));

% Construct optimisation variables. 
rise = optimizableVariable('rise', settings.rise_range, 'Type', 'integer');
peak = optimizableVariable('peak', settings.peak_range, 'Type', 'integer');
fall = optimizableVariable('fall', settings.fall_range, 'Type', 'integer');
optimisation_variables = [rise, peak, fall];

% Initialise Bayesian optimisation with a single step, & save result.
global G__iteration;
G__iteration = 1;
results = bayesopt(objective_function, ...
    optimisation_variables, ...
    'XConstraintFcn', parameter_constraints, ... 
    'AcquisitionFunctionName', settings.acquisition_function, ...
    'MaxObjectiveEvaluations', 1, ...
    'PlotFcn', [], ...
    settings.bayesopt_args{:});
save(settings.save_file, 'results', 'G__iteration');

% Run Bayesian optimisation for remaining steps. 
while G__iteration <= settings.max_iterations - 1
    G__iteration = G__iteration + 1;
    old_results = results;
    try
        results = old_results.resume('MaxObjectiveEvaluations', 1);
    catch err
        disp(err.message);
        input('Press enter when ready to retry.\n');
        results = old_results;
        G__iteration = G__iteration - 1;
    end
    save(settings.save_file, 'results', 'G__iteration');
end

end

