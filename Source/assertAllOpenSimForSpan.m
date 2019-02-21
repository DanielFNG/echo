osim = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Data\OpenSim';
root = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Data\Processed';
model = 'D:\Dropbox\PhD\HIL Control\HIL Span\Organised for testing HIL\Models\APO.osim';
[~, folders] = dirNoDots(root);

n_folders = length(folders);
osts = cell(1, n_folders);
for i=1:n_folders
    [~, name, ~] = fileparts(folders{i});
    [n_grfs, grfs] = getFilePaths([folders{i} filesep 'GRF' filesep 'right'], '.mot');
    [~, markers] = getFilePaths([folders{i} filesep 'Markers' filesep 'right'], 'trc');
    results = [osim filesep name filesep 'right'];
    for j=1:length(grfs)
        osts{i}{j} = OpenSimTrial(model, markers{j}, [results filesep num2str(j)], grfs{j});
        osts{i}{j}.assertComputed({'IK', 'ID', 'BK'});
    end
end
    