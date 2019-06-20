function emg = parseEMGDataFaster(filename)
% Read raw EMG data from Vicon and produce a TXTData object.

    tic;

    id = fopen(filename);
    
    % Disregard the header, comprising the first 3 frames.
    for i=1:3
        fgetl(id);
    end
    
    % Get the labels.
    labels = strsplit(fgetl(id), '\t');
    n_cols = length(labels);
    
    % Disregard the next line.
    fgetl(id);
    
    toc
    
    % A different way.
    values = cell2mat(textscan(id, repmat('%f', 1, n_cols)));
    
    toc
    
    % Close the file.
    fclose(id);
    
    % Convert values.
    n_rows = size(values, 1);
    
    % Create new labels.
    labels{1} = 'Time';
    labels{2} = 'Frame';
    
    % Re-assign the time/frame values.
    values(:, 2) = 1:n_rows;
    values(:, 1) = 0.001*values(:, 2) - 0.001;
    
    toc
    
    % Create emg data.
    emg = TXTData(values, {}, labels);
    
    toc

end