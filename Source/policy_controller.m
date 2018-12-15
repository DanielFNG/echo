save_directory = 'D:\Dropbox\PhD\HIL Control\Test-13-12-18';
markers_saveloc = '';
grfs_saveloc = '';

total_iterations = 20;

acquisition_function = 'probability-of-improvement';

rise = optimizableVariable('rise', [30, 50], 'Type', 'integer');
peak = optimizableVariable('peak', [35, 70], 'Type', 'integer');
fall = optimizableVariable('fall', [40, 90], 'Type', 'integer');

%objective_function = @evaluateCoP_ML_disp;
objective_function = @evaluateHipROM;

results = bayesopt(objective_function, ...
    optimisation_variables, ...
    'XConstraintFcn', @xconstraint, ...
    'AcquisitionFunctionName', acquisition_function, ...
    'MaxObjectiveEvaluations', total_iterations);