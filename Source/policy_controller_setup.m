% Setup script for policy controller implementation. This script should be 
% modified to suit experiment/subject/control settings & used as the base 
% script to run the policy controller. 

% Save file name.
settings.save_file = 'span-results-right-hip-rom4-EIP0.8.mat';

% Control parameterisation settings. 
settings.rise_range = [9, 11];
settings.peak_range = [10, 12];
settings.fall_range = [13, 15];

% Subject specific settings.
settings.metric = @calculateROM;
settings.args = {'hip_flexion_r'};
settings.analyses = {'IK'};
settings.model_file = ['F:\Dropbox\PhD\HIL Control\HIL Span\'...
    'Organised for testing HIL\Models\no_APO.osim'];
settings.baseline = 34.2397;  % With APO.
%settings.baseline = 29.4703;  % No APO.

% Gait segmentation settings.
settings.feet = {'right'};
settings.segmentation_mode = 'stance';
settings.segmentation_cutoff = 40;

% Experiment settings. Currently set to standard for UoE setup.
settings.time_delay = 16*(1/600);  
settings.marker_rotations = {0,270,0};  
settings.grf_rotations = {0,90,0};

% Filestructure.
settings.base_dir = 'F:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Data';
settings.v_name = 'markers';
settings.d_name = 'NE';
settings.v_format = '%02i';  % # of leading 0's in Vicon (trc) filenames 
settings.d_format = '%04i';  % # of leading 0's in D-Flow (txt) filenames

% Bayesian optimisation settings. 
settings.max_iterations = 24;
settings.acquisition_function = 'expected-improvement-plus';
settings.parameter_constraints = @parameterConstraints;

% Run policy controller. 
runPolicyController(settings);

