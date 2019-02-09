osim = 'F:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Data\OpenSim';
root = 'F:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Data\Processed';
model = 'F:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Models\APO.osim';
[~, folders] = dirNoDots(root);

n_folders = length(folders);
osts = cell(1, n_folders);
for i=1:n_folders
    [~, name, ~] = fileparts(folders{i});
    grfs = [folders{i} filesep 'GRF' filesep 'right'];
    markers = [folders{i} filesep 'Markers' filesep 'right'];
    results = [osim filesep name filesep 'right'];
    osts{i} = runBatch({'IK', 'ID', 'BK'}, model, markers, results, grfs);
end
    