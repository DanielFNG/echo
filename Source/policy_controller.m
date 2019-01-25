% Save file name.
save_file = 'intermediate_results.mat';

% Control parameterisation settings. 
rise_range = [30, 50];
peak_range = [35, 70];
fall_range = [40, 90];

% Subject specific settings.
metric = @calculateROM;
args = {'hip_flexion_r'};
model_file = 'C:\Users\danie\Documents\GitHub\echo\Source\chris_scaled.osim';
baseline = 49.7;  % Real for fixed, 'measured' for measured

% Experiment settings.
time_delay = 16*(1/600);
marker_rotations = {0,270,0};  
grf_rotations = {0,90,0};

% Filestructure.
base_dir = 'F:\Dropbox\PhD\HIL Control\Automation-test\walking';
v_name = 'markers';
d_name = 'NE';
v_format = '%02i';  % # of leading 0's in Vicon (trc) filenames 
d_format = '%04i';  % # of leading 0's in D-Flow (txt) filenames

% Bayesian optimisation settings. 
max_iterations = 3;
acquisition_function = 'probability-of-improvement';

runPolicyController(settings);

