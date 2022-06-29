% Changeable parameters
base = 'N:\Shared_Data\HIL\Model Accuracy\Chris-Gait2392';
static_file = 'Chris Cal 01.trc';
mass = 79.3;
model_name = 'chris_gait2392.osim';

% Unchangeable parameters
model_folder = 'Models';
static_folder = 'Processed Static';
marker_system.Forward = '+z';
marker_system.Up = '+y';
marker_system.Right = '-x';

% Paths
static = [base filesep static_file];
results = [base filesep static_folder];
model_dir = [base filesep model_folder];

% Process static data
mkdir(results);
processStaticData(results, static, marker_system);
mkdir(model_dir);

% Scale model
static = [results filesep static_file];
model = [model_dir filesep model_name];
scaleModel(mass, model, static);

% Compute & report leg length in m
static = Data([base filesep  static_folder filesep static_file]);
static.convertUnits('m');
leg_length = round(mean(static.getColumn('RHJC_Y') - ...
    static.getColumn('RAJC_Y')), 2);
speed = 1.2*sqrt(0.1*9.81*leg_length);
fprintf('Leg length computed as %.2fm.\n', leg_length);