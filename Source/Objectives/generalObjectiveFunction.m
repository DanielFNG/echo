function result = generalObjectiveFunction(X)

% Collect global variables
global metric args model_file baseline iteration;
global time_delay marker_rotations grf_rotations;
global base_dir v_name d_name v_format d_format;

%% Create first-level results directories. 
persistent processed_dir segment_dir opensim_dir;

if iteration == 1
    processed_dir = [base_dir filesep 'processed'];
    segment_dir = [base_dir filesep 'gait_cycles'];
    opensim_dir = [base_dir filesep 'opensim'];
    mkdir(processed_dir);
    mkdir(segment_dir);
    mkdir(opensim_dir);
end

% Communicate with APO to apply correct torque pattern.
% Actually in the mean-time this will be operator controlled, since one
% will be needed for putting Vicon live anyway. A beep will tell the
% operator to update the control parameters on the APO side during the
% non-assisted phase of the current trial.
fprintf('Apply rise %i, peak %i, fall %i.\n', X.rise, X.peak, X.fall);
beep;

% Every 2s check for the existence of the trial data.
marker_name = [v_name sprintf(v_format, iteration)];
grf_name = [d_name sprintf(d_format, iteration)];
marker_file = ...
    [base_dir filesep marker_name '.trc'];
grf_file = ...
    [base_dir filesep grf_name '.txt'];
while true 
    if exist(grf_file, 'file') && exist(marker_file, 'file')
        pause(2);  % Give an additional 2s just for finishing file writing.
        break;
    else
        pause(2);
    end
end
% NEED ANOTHER CHECK THAT THESE ARE WRITABLE!

%% Process the files.

% Assign names.
processed_markers = [processed_dir filesep marker_name '.trc'];
processed_grfs = [processed_dir filesep grf_name '.mot'];

% Processing
int_grf = produceMOT(grf_file, base_dir);
[markers, grfs] = synchronise(marker_file, int_grf, time_delay);
markers.rotate(marker_rotations{:});
grfs.rotate(grf_rotations{:});

% File creation
markers.writeToFile(processed_markers);
grfs.writeToFile(processed_grfs);

%% Segmentation

int_seg_dir = [segment_dir filesep 'iteration' sprintf('%03i', iteration)];
mkdir(int_seg_dir);

% Segment.
%segment('left', 'stance', 40, processed_grfs, processed_markers, int_seg_dir);
segment('right', 'stance', 40, processed_grfs, processed_markers, int_seg_dir);
% Only doing this for right foot for now, for quicker testing.

%% OpenSim compuations

% Obtain the markers & grf files. 
marker_files = dir([int_seg_dir filesep '*.trc']);
grf_files = dir([int_seg_dir filesep '*.mot']);

% Create directory for results storage.
osim_save_dir = [opensim_dir filesep 'iteration' sprintf('%03i', iteration)];
mkdir(osim_save_dir);

% Run appropriate OpenSim analyses.
n_cycles = length(marker_files);
hip_rom = zeros(1, n_cycles);
for i=1:n_cycles
    
    % Create directory for results storage. 
    results = [osim_save_dir filesep 'cycle' sprintf('%03i', i)];
    
    % Create OpenSimTrial
    ost = OpenSimTrial(...
        model_file, [int_seg_dir filesep marker_files(i).name], ...
        results, [int_seg_dir filesep grf_files(i).name]);
    
    % Run IK. 
    ost.run('IK');
    % ost{i}.run('BK');
    % ost{i}.run('ID');
    % Only doing IK for now for ease of testing. 
    
    % Compute metric.
    ost_results = OpenSimResults(ost, {'IK'});
    hip_rom(i) = metric(ost_results, args{:});
end

% If required, calculate the relative baseline for this trial. 
% Not for now.

% Compute & report metric data. 
result = sum((hip_rom - baseline).^2)/n_cycles;

end

