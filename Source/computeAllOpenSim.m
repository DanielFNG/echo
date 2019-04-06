final_save_dir = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Results';

osim = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\No APO\OpenSim';
root = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\No APO\Processed';
model = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Models\no_APO.osim';
[~, folders] = dirNoDots(root);

n_folders = length(folders);
osts = cell(1, n_folders);
gait = cell(1, n_folders);
for i=1:n_folders
    [~, name, ~] = fileparts(folders{i});
    grfs = [folders{i} filesep 'right' filesep 'GRF'];
    markers = [folders{i} filesep 'right' filesep 'Markers'];
    results = [osim filesep name filesep 'right'];
    osts{i} = runBatch({'IK', 'ID', 'BK'}, model, markers, results, grfs);
    
    n_osts = length(osts{i});
    gait{i} = cell(1, n_osts);
    for j=1:n_osts
        motion_data = MotionData(osts{i}{j}, 0.93, 0.08, {'Markers', 'GRF', 'BK', 'IK'}, 2);
        gait{i}{j} = GaitCycle(motion_data);
    end
end

save([final_save_dir filesep 'gait-baseline-no_APO.mat'], 'gait');
clear('gait');

osim = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\APO\OpenSim';
root = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\APO\Processed';
model = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Models\APO.osim';
[~, folders] = dirNoDots(root);

n_folders = length(folders);
osts = cell(1, n_folders);
gait = cell(1, n_folders);
for i=1:n_folders
    [~, name, ~] = fileparts(folders{i});
    grfs = [folders{i} filesep 'right' filesep 'GRF'];
    markers = [folders{i} filesep 'right' filesep 'Markers'];
    results = [osim filesep name filesep 'right'];
    osts{i} = runBatch({'IK', 'ID', 'BK'}, model, markers, results, grfs);
    
    n_osts = length(osts{i});
    gait{i} = cell(1, n_osts);
    for j=1:n_osts
        motion_data = MotionData(osts{i}{j}, 0.93, 0.08, {'Markers', 'GRF', 'BK', 'IK'}, 2);
        gait{i}{j} = GaitCycle(motion_data);
    end
end

save([final_save_dir filesep 'gait-baseline-APO.mat'], 'gait');
clear('gait');

osim = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Data\OpenSim';
root = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Data\Processed';
model = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Models\APO.osim';
[~, folders] = dirNoDots(root);

n_folders = length(folders);
osts = cell(1, n_folders);
gait = cell(1, n_folders);
for i=1:n_folders
    [~, name, ~] = fileparts(folders{i});
    grfs = [folders{i} filesep 'right' filesep 'GRF'];
    markers = [folders{i} filesep 'right' filesep 'Markers'];
    results = [osim filesep name filesep 'right'];
    osts{i} = runBatch({'IK', 'ID', 'BK'}, model, markers, results, grfs);
    
    n_osts = length(osts{i});
    gait{i} = cell(1, n_osts);
    for j=1:n_osts
        motion_data = MotionData(osts{i}{j}, 0.93, 0.08, {'Markers', 'GRF', 'BK', 'IK'}, 2);
        gait{i}{j} = GaitCycle(motion_data);
    end
end

save([final_save_dir filesep 'gait-APO.mat'], 'gait');
clear('gait');