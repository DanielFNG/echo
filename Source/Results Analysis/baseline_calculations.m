% Get the no-APO baseline.
human_model = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Models\no_APO.osim';
human_markers = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\No APO\Processed\Markers';
human_results = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\No APO\OpenSim';
human_grfs = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\No APO\Processed\GRF';

human_osts = runBatch({'IK'}, human_model, human_markers, human_results, human_grfs);

n_human_osts = length(human_osts);
human_hip_rom = zeros(1, n_human_osts);
for i=1:n_human_osts
    human_hip_rom(i) = human_osts{i}.calculateROM('hip_flexion_r');
end

mean_no_APO_hip_rom = mean(human_hip_rom);

% Get the APO baseline.
APO_model = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Models\APO.osim';
APO_markers = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\APO\Processed_Right\Markers';
APO_results = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\APO\OpenSim';
APO_grfs = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\APO\Processed_Right\GRF';

APO_osts = runBatch({'IK'}, APO_model, APO_markers, APO_results, APO_grfs);

n_APO_osts = length(APO_osts);
APO_hip_rom = zeros(1, n_APO_osts);
for i=1:n_APO_osts
    APO_hip_rom(i) = APO_osts{i}.calculateROM('hip_flexion_r');
end

mean_APO_hip_rom = mean(APO_hip_rom);