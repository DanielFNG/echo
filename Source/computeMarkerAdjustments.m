function adjustment_means = computeMarkerAdjustments(settings)

    marker_folder = [settings.base_dir filesep 'right' filesep 'Markers'];
    [n_files, marker_paths] = getFilePaths(marker_folder, '.trc');
    marker_names = settings.adjustment_markers;
    n_markers = length(marker_names);
    adjustment = zeros(n_files, n_markers);

    for i = 1:n_files
        marker_data = Data(marker_paths{i});
        for j = 1:n_markers
            adjustment(i, j) = mean(marker_data.getColumn(marker_names{j}));
        end
    end
    
    adjustment_means = mean(adjustment);
    
end
    