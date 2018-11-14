n_iterations = 20;
acquisition_function = 'probability-of-improvement';

rise = optimizableVariable('rise', [20, 50]);
peak = optimizableVariable('peak', [25, 60]);
fall = optimizableVariable('fall', [50, 70]);

optimisation_variables = [rise, peak, fall];

objective_function = @evaluateCoP_ML_disp;

results = bayesopt(objective_function, ...
    optimisation_variables, ...
    'AcquisitionFunctionName', acquisition_function, ...
    'MaxObjectiveEvaluations', n_iterations);