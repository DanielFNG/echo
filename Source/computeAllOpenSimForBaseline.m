osim = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\No APO\OpenSim';
root = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\No APO\Processed';
model = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Models\no_APO.osim';
[~, folders] = dirNoDots(root);

n_folders = length(folders);
osts = cell(1, n_folders);
for i=1:n_folders
    [~, name, ~] = fileparts(folders{i});
    grfs = [folders{i} filesep 'right' filesep 'GRF'];
    markers = [folders{i} filesep 'right' filesep 'Markers'];
    results = [osim filesep name filesep 'right'];
    osts{i} = runBatch({'IK', 'ID', 'BK'}, model, markers, results, grfs);
end

osim = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\APO\OpenSim';
root = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Baseline\APO\Processed';
model = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Models\APO.osim';
[~, folders] = dirNoDots(root);

n_folders = length(folders);
osts = cell(1, n_folders);
for i=1:n_folders
    [~, name, ~] = fileparts(folders{i});
    grfs = [folders{i} filesep 'right' filesep 'GRF'];
    markers = [folders{i} filesep 'right' filesep 'Markers'];
    results = [osim filesep name filesep 'right'];
    osts{i} = runBatch({'IK', 'ID', 'BK'}, model, markers, results, grfs);
end

