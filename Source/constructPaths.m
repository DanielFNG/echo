function paths = constructPaths(settings, dirs, iteration)
% Construct the mid-level strings & paths for the policy controller.
    
    % Marker & grf file names.
    paths.strings.markers = ...
        [settings.v_name sprintf(settings.v_format, iteration)];
    paths.strings.grfs = ...
        [settings.d_name sprintf(settings.d_format, iteration)];
    
    % Raw marker & grf files.
    paths.files.markers = ...
        [settings.base_dir filesep paths.strings.markers '.trc'];
    paths.files.grfs = ...
        [settings.base_dir filesep paths.strings.grfs '.txt'];
            
    % Processed marker & grf files.
    paths.files.processed_markers = ...
        [dirs.processed filesep paths.strings.markers '.trc'];
    paths.files.processed_grfs = ...
        [dirs.processed filesep paths.strings.grfs '.mot'];
            
    % Inner-level directories for saving segmentation & OpenSim results. 
    paths.directories.segmented_inner = ...
        [dirs.segmented filesep 'iteration' sprintf('%03i', iteration)];
    paths.directories.opensim_inner = ...
        [dirs.opensim filesep 'iteration' sprintf('%03i', iteration)];
end