function runPolicyController(settings)
% Runs policy controller given adequete settings. 
%
% This function is designed to be called from the policy_controller_setup 
% script.

if strcmp(settings.operation_mode, 'online')
    % Create top-level filestructure.
    dirs.processed = [settings.base_dir filesep 'processed'];
    dirs.segmented = [settings.base_dir filesep 'gait_cycles'];
    dirs.opensim = [settings.base_dir filesep 'opensim'];
    createDirectories(dirs);
end

% Construct optimisation variables. 
rise = optimizableVariable('rise', settings.rise_range, 'Type', 'integer');
peak = optimizableVariable('peak', settings.peak_range, 'Type', 'integer');
fall = optimizableVariable('fall', settings.fall_range, 'Type', 'integer');
optimisation_variables = [rise, peak, fall];

% Initialise Bayesian optimisation with a single step, & save result.
iteration = 1;
results = bayesopt(settings.objective_function, ...
    optimisation_variables, ...
    'XConstraintFcn', settings.parameter_constraints, ... 
    'AcquisitionFunctionName', settings.acquisition_function, ...
    'MaxObjectiveEvaluations', 1, ...
    'PlotFcn', [], ...
    settings.bayesopt_args{:});
save(settings.save_file, 'results', 'iteration');

% Run Bayesian optimisation for remaining steps. 
while iteration <= settings.max_iterations - 1
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

end

