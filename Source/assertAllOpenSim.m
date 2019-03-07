osim = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\No APO\OpenSim';
root = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\No APO\Processed';
model = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Models\no_APO.osim';
[~, folders] = dirNoDots(root);

n_folders = length(folders);
gait = cell(1, n_folders);
for i=1:n_folders
    [~, name, ~] = fileparts(folders{i});
    [n_grfs, grfs] = getFilePaths([folders{i} filesep 'right' filesep 'GRF'], '.mot');
    [~, markers] = getFilePaths([folders{i} filesep 'right' filesep 'Markers'], '.trc');
    results = [osim filesep name filesep 'right'];
    
    gait{i} = cell(1, n_grfs);
    for j=1:length(grfs)
        osts = OpenSimTrial(model, markers{j}, [results filesep num2str(j)], grfs{j});
        osts.assertComputed({'IK', 'ID', 'BK'});
        motion_data = MotionData(osts, {'Markers', 'GRF', 'BK', 'IK'}, 0.8, 'x');
        gait{i}{j} = GaitCycle(motion_data);
    end
end

save('gait-baseline-no_APO.mat', 'gait');
clear('gait');

osim = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\APO\OpenSim';
root = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\APO\Processed';
model = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Models\APO.osim';
[~, folders] = dirNoDots(root);

n_folders = length(folders);
gait = cell(1, n_folders);
for i=1:n_folders
    [~, name, ~] = fileparts(folders{i});
    [n_grfs, grfs] = getFilePaths([folders{i} filesep 'right' filesep 'GRF'], '.mot');
    [~, markers] = getFilePaths([folders{i} filesep 'right' filesep 'Markers'], '.trc');
    results = [osim filesep name filesep 'right'];
    
    gait{i} = cell(1, n_grfs);
    for j=1:length(grfs)
        osts = OpenSimTrial(model, markers{j}, [results filesep num2str(j)], grfs{j});
        osts.assertComputed({'IK', 'ID', 'BK'});
        motion_data = MotionData(osts, {'Markers', 'GRF', 'BK', 'IK'}, 0.8, 'x');
        gait{i}{j} = GaitCycle(motion_data);
    end
end

save('gait-baseline-APO.mat', 'gait');
clear('gait');

osim = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Data\OpenSim';
root = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Data\Processed';
model = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Models\APO.osim';
[~, folders] = dirNoDots(root);

n_folders = length(folders);
gait = cell(1, n_folders);
for i=1:n_folders
    [~, name, ~] = fileparts(folders{i});
    [n_grfs, grfs] = getFilePaths([folders{i} filesep 'right' filesep 'GRF'], '.mot');
    [~, markers] = getFilePaths([folders{i} filesep 'right' filesep 'Markers'], '.trc');
    results = [osim filesep name filesep 'right'];
    
    gait{i} = cell(1, n_grfs);
    for j=1:length(grfs)
        osts = OpenSimTrial(model, markers{j}, [results filesep num2str(j)], grfs{j});
        osts.assertComputed({'IK', 'ID', 'BK'});
        motion_data = MotionData(osts, {'Markers', 'GRF', 'BK', 'IK'}, 0.8, 'x');
        gait{i}{j} = GaitCycle(motion_data);
    end
end

save('gait-APO.mat', 'gait');
clear('gait');