pext_range = [5, 25];
rise_range = [25, 45];
pflex_range = [50, 80];
fall_range = [70, 95];

pext = optimizableVariable('pext', pext_range, 'Type', 'integer');
rise = optimizableVariable('rise', rise_range, 'Type', 'integer');
pflex = ...
    optimizableVariable('pflex', pflex_range, 'Type', 'integer');
fall = optimizableVariable('fall', fall_range, 'Type', 'integer');
optimisation_variables = [pext, rise, pflex, fall];

parameter_constraints = @bimodalParameterConstraints;

hill2_size = 40;

hill1 = [15, 30, 60, 80];
hill2 = hill1;%[18, 40, 75, 95];

objective_function = @(X) (bayesoptHills(X, hill2_size, hill1, hill2));

acquisition_function = 'expected-improvement-plus';

n_iterations = 50;
n_seed = 20;

results = bayesopt(objective_function, ...
    optimisation_variables, ...
    'XConstraintFcn', parameter_constraints, ...
    'AcquisitionFunctionName', acquisition_function, ...
    'MaxObjectiveEvaluations', n_iterations, ...
    'NumSeedPoints', n_seed, ...
    'PlotFcn', []);