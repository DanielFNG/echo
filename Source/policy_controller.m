save_directory = 'D:\Dropbox\PhD\HIL Control\Test-13-12-18';
markers_saveloc = '';
grfs_saveloc = '';

iteration_size = 1;
max_iterations = 15;

acquisition_function = 'probability-of-improvement';

rise = optimizableVariable('rise', [30, 50], 'Type', 'integer');
peak = optimizableVariable('peak', [35, 70], 'Type', 'integer');
fall = optimizableVariable('fall', [40, 90], 'Type', 'integer');

optimisation_variables = [rise, peak, fall];

%objective_function = @evaluateCoP_ML_disp;
objective_function = @evaluateHipROM;

results = bayesopt(objective_function, ...
    optimisation_variables, ...
    'XConstraintFcn', @parameterConstraints, ...
    'AcquisitionFunctionName', acquisition_function, ...
    'MaxObjectiveEvaluations', iteration_size);

save('intermediate_results.mat', 'results', 'count');

count = 1;
while count < max_iterations 
    try
        old_results = results;
        results = old_results.resume('MaxObjectiveEvaluations', 1);
        count = count + 1;
    catch err
        disp(err.message);
        input('Press enter when ready to retry.\n');
        results = old_results;
    end
    save('intermediate_results.mat', 'results', 'count');
end