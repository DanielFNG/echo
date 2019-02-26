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
        gait{i}{j} = GaitCycle(osts{i}{j}, {'Markers', 'GRF', 'BK', 'IK'}, 0.8, 'x');
    end
end
    
