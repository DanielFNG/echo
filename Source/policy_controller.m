% Save file name.
save_file = 'intermediate_results.mat';

% Control parameterisation settings. 
rise_range = [30, 50];
peak_range = [35, 70];
fall_range = [40, 90];

% Global variables - subject specific.
global metric args model_file baseline iteration;
metric = @calculateROM;
args = {'hip_flexion_r'};
model_file = 'C:\Users\danie\Documents\GitHub\echo\Source\chris_scaled.osim';
baseline = 49.7;  % Real for fixed, 'measured' for measured

% Global variables - experiment settings.
global time_delay marker_rotations grf_rotations;
time_delay = 16*(1/600);
marker_rotations = {0,270,0};  
grf_rotations = {0,90,0};

% Global variables - filestructure.
global base_dir v_name d_name v_format d_format;
base_dir = 'F:\Dropbox\PhD\HIL Control\Automation-test\walking';
v_name = 'markers';
d_name = 'NE';
v_format = '%02i';  % # of leading 0's in Vicon (trc) filenames 
d_format = '%04i';  % # of leading 0's in D-Flow (txt) filenames

% Bayesian optimisation settings. 
max_iterations = 3;
acquisition_function = 'probability-of-improvement';
objective_function = @generalObjectiveFunction;
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
    'MaxObjectiveEvaluations', 1, ...
    'PlotFcn', []);

% Save the result of the initial BO step. 
save(save_file, 'results', 'iteration');

% Resume the Bayesian optimisation.
while iteration <= max_iterations - 1
    try
        iteration = iteration + 1;
        old_results = results;
        results = old_results.resume('MaxObjectiveEvaluations', 1);
    catch err
        disp(err.message);
        input('Press enter when ready to retry.\n');
        results = old_results;
    end
    save('intermediate_results.mat', 'results', 'iteration');
end