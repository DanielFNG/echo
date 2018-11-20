n_iterations = 20;
acquisition_function = 'probability-of-improvement';

rise = optimizableVariable('rise', [30, 50]);
peak = optimizableVariable('peak', [35, 70]);
fall = optimizableVariable('fall', [40, 90]);

optimisation_variables = [rise, peak, fall];

objective_function = @evaluateCoP_ML_disp;

results = bayesopt(objective_function, ...
    optimisation_variables, ...
    'XConstraintFcn', @xconstraint, ...
    'AcquisitionFunctionName', acquisition_function, ...
    'MaxObjectiveEvaluations', n_iterations);