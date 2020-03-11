function emg = parseEMGData(filename)
% Read raw EMG data from Vicon and produce a TXTData object.

    id = fopen(filename);
    
    % Disregard the header, comprising the first 3 frames.
    for i=1:3
        fgetl(id);
    end
    
    % Get the labels.
    labels = strsplit(fgetl(id), '\t');
    
    % Disregard the next line.
    fgetl(id);
    
    % Now get the values.
    count = 1;
    while true
        line = fgetl(id);
        if ~ischar(line)
            break;
        end
        contents = strsplit(line);
        if length(contents) > 2 % Sometimes blank line reads as 2 chars
            str_values{count} = strsplit(line); %#ok<*AGROW>
            % Sometimes the last column can be just a new line, which we
            % don't want.
            if isempty(str_values{count}{end})
                str_values{count} = str_values{count}(1:end - 1);
            end
            count = count + 1;
        end
    end
    
    % Close the file.
    fclose(id);
    
    % Convert values.
    n_rows = length(str_values);
    n_cols = length(labels);
    values = zeros(n_rows, n_cols);
    for i=1:n_rows
        if size(str_values{i}, 2) == n_cols
            values(i, :) = str2double(str_values{i});
        else
            error('something is afoot');
        end
    end
    
    % Create new labels.
    labels{1} = 'Time';
    labels{2} = 'Frame';
    
    % Re-assign the time/frame values.
    values(:, 2) = 1:n_rows;
    values(:, 1) = 0.001*values(:, 2) - 0.001;
    
    % Create emg data.
    emg = TXTData(values, {}, labels);

end