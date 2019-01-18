% Save file name.
save_file = 'intermediate_results.mat';

% Control parameterisation settings. 
peak_force = 10;
rise_range = [30, 50];
peak_range = [35, 70];
fall_range = [40, 90];

% Bayesian optimisation settings. 
max_iterations = 15;
acquisition_function = 'probability-of-improvement';
objective_function = @evaluateHipROM;
parameter_constraints = @parameterConstraints;

% Subject-specific settings.
model_file = 'chris_scaled.osim';
baseline = 49.7;  % Only relevant for fixed baseline objective functions.

% Optimisation variable construction - to be optimised.
rise = optimizableVariable('rise', rise_range, 'Type', 'integer');
peak = optimizableVariable('peak', peak_range, 'Type', 'integer');
fall = optimizableVariable('fall', fall_range, 'Type', 'integer');

% Optimisation variable construction - fixed.
force = optimizableVariable(...
    'force', [peak_force, peak_force], 'Optimize', false);
model = optimizableVariable(...
    'model', {model_file}, 'Type', 'categorical', 'Optimize', false);
baseline = optimizableVariable(...
    'baseline', [baseline, baseline], 'Optimize', false);

% Optimisation variable construction - grouping.
optimisation_variables = [rise, peak, fall, model];

% Initialise the Bayesian optimisation with a single step. 
iteration = 1;
results = bayesopt(objective_function, ...
    optimisation_variables, ...
    'XConstraintFcn', parameter_constraints, ...
    'AcquisitionFunctionName', acquisition_function, ...
    'MaxObjectiveEvaluations', 1);

% Save the result of the initial BO step. 
save(save_file, 'results', iteration);

% Resume the Bayesian optimisation.
while iteration < max_iterations 
    try
        old_results = results;
        results = old_results.resume('MaxObjectiveEvaluations', 1);
        iteration = iteration + 1;
    catch err
        disp(err.message);
        input('Press enter when ready to retry.\n');
        results = old_results;
    end
    save('intermediate_results.mat', 'results', 'iteration');
end