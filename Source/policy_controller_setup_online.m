%% The stuff that probably has to change/be looked over between experiments.

% Data directory.
settings.base_dir = 'D:\Vicon Install Nov 2018\Normal\HIL\S0';

% Save file name - where the bayesopt results will be saved.
settings.save_file = [settings.base_dir filesep 'hil-results.mat'];

% Data inputs - markers only, grfs only, motion (both), emg (emg + grf).
settings.data_inputs = 'Motion';

% Subject specific settings.
settings.mass = 81;
settings.leg_length = 0.93;
settings.toe_length = 0.08;
settings.speed = 1.2;

% Assistance magnitude. 
settings.force = 10;

% Co-ordinate system offsets - calculate these using motion function.
settings.x_offset = 0;
settings.y_offset = 0;
settings.z_offset = 0;  

%% The stuff that probably doesn't have to change/be looked over.

% Operation mode - online or offline.
settings.operation_mode = 'online';

% Motion metric specific settings.
settings.metric = {@calculateMetabolicRate};
settings.args = [];
settings.opensim_analyses = {'IK', 'SO'};
settings.motion_analyses = {'SO'};

% Baseline mode - none, absolute or relative.
settings.baseline_mode = 'none';
settings.baseline_filename = [];

% Experiment specific settings.
settings.inclination = 0;

% Data processing specific settings.
settings.feet = {'right'};
settings.segmentation_mode = 'stance';
settings.segmentation_cutoff = 2;
settings.time_delay = 0;
settings.marker_system.forward = '+z';
settings.marker_system.up = '+y';
settings.marker_system.right = '-x';
settings.grf_system.forward = '+y';
settings.grf_system.up = '-z';
settings.grf_system.right = '+x';

% Valid ranges for the control parameters. NOTE: if
% multiplier*min_rise_range is less than 10, we will have problems with the
% TCP-IP solution. 
settings.rise_range = [30, 75];
settings.peak_range = [40, 90];
settings.fall_range = [50, 99];

% Control parameter variables.
settings.multiplier = 1;
settings.min_length = 20;

% Communication - this should be an active TCPIP server. 
settings.server = t;

% Data filestructure.
settings.name = 'capture';
settings.format = '%03i';  % # of leading 0's in Vicon filenames 

% Bayesian optimisation settings. 
settings.iter_func = @(x) x;
settings.max_iterations = 20;
settings.num_seed_points = 8;  % 8 fully randomised measurements first
settings.acquisition_function = 'expected-improvement-plus';
settings.bayesopt_args = {'ExplorationRatio', 0.7};  % stuff like exploration ratio would be here

%% Run

% Create models directory.
model_dir = [settings.base_dir filesep 'Models'];
mkdir(model_dir);

% OpenSim model created & scaled. 
input('Ensure the ''static.trc'' file has been created, input any key to continue.\n');
static = [settings.base_dir filesep 'static.trc'];
processStaticData(settings.base_dir, static, settings.marker_system);
model = [model_dir filesep 'model.osim'];
scaleModel(settings.mass, model, static);

% OpenSim model adjusted.
input('Ensure the inital walk ''walk.trc'' and ''walk.txt'' files have been created, input any key to continue.\n');
raw_markers = [settings.base_dir filesep 'walk.trc'];
raw_grf = [settings.base_dir filesep 'walk.txt'];
processMotionData(settings.base_dir, settings.base_dir, raw_markers, raw_grf, ...
    settings.marker_system, settings.grf_system, settings.x_offset, ...
    settings.y_offset, settings.z_offset, settings.time_delay, ...
    settings.speed, settings.inclination, [], settings.feet, settings.mode, ...
    settings.cutoff, 'Markers', 'GRF');
markers = [settings.base_dir filesep 'right' filesep 'Markers' filesep 'cycle01.trc'];
grf = [settings.base_dir filesep 'right' filesep 'GRF' filesep 'cycle01.mot'];
human_model = 'C:\OpenSim 3.3\Models\Gait2392_Simbody\gait2392_simbody.osim';
settings.model = [model_dir filesep 'model_adjusted.osim'];
adjustment_folder = [model_dir filesep 'Adjustment'];
adjustModel(model, settings.model, human_model, markers, grf, adjustment_folder);
input('Model adjustment completed. Input any key to confirm visual analysis of model and proceed to cadence computation.\n');

% Optimal cadence computed.
cadence_results = [settings.base_dir filesep 'Cadence'];
trials = createTrials(settings.model, markers, cadence_results, grf);
n_trials = length(trials);
cadence_data = zeros(1, n_trials);
analyses = {'GRF'};
for i=1:n_trials
    motion_data = MotionData(trials{i}, settings.leg_length, ...
        settings.toe_length, analyses, settings.grf_cutoff);
    cycle = GaitCycle(motion_data);
    cadence_data(i) = 60/cycle.calculateTotalTime(); % steps/min e.g. bpm for metronome
end
cadence = round(mean(cadence_data));
fprintf('Cadence calculation completed - set metronome to %i BPM.\n', cadence);

% Reminder about first calorimetry measurement. 
input('Input any key when first calorimetry walk has been completed. Remember vicon name change.\n');

% Run policy controller. 
input('All setup steps completed - input any key when ready to begin HIL policy controller.\n');
runPolicyController(settings);

