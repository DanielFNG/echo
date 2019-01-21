% Save file name.
save_file = 'intermediate_results.mat';

% Control parameterisation settings. 
rise_range = [30, 50];
peak_range = [35, 70];
fall_range = [40, 90];

% Global variables - required to be seen within the objective function.
global metric peak_force model_file baseline iteration;
metric = 'hip_rom';
peak_force = 10;
model_file = 'chris_scaled.osim';
baseline = 49.7;  % Real for fixed, 'measured' for measured.

% Bayesian optimisation settings. 
max_iterations = 15;
acquisition_function = 'probability-of-improvement';
objective_function = @evaluateHipROM;
parameter_constraints = @parameterConstraints;

% Optimisation variable construction.
rise = optimizableVariable('rise', rise_range, 'Type', 'integer');
peak = optimizableVariable('peak', peak_range, 'Type', 'integer');
fall = optimizableVariable('fall', fall_range, 'Type', 'integer');
optimisation_variables = [rise, peak, fall];

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