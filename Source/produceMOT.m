function produceMOT(input_file, output_file)

fp_frame_rate = 600;
fp_cutoff_1 = 6;
fp_cutoff_2 = 25;
filter_order = 4;
filter_type = 'lp';
fp_threshold_1 = 40;
fp_threshold_2 = 2;

% Rotations from treadmill to OpenSim.
rot.RotX = 0;
rot.RotY = 1;
rot.RotZ = 0;
rot.Rot1deg = -90;
rot.Rot2deg = 0;

grfs = importdata(input_file);

% Isolate forces. 1-3 correspond to right x, right y, right z. Similarly
% for 4-6 and left. 
forces{1} = grfs.data(1:end,6); 
forces{2} = grfs.data(1:end,7);
forces{3} = grfs.data(1:end,8);
forces{4} = grfs.data(1:end,15);
forces{5} = grfs.data(1:end,16);
forces{6} = grfs.data(1:end,17);

% Isolate moments. Similar numbering to above.
moments{1} = grfs.data(1:end,9);
moments{2} = grfs.data(1:end,10);
moments{3} = grfs.data(1:end,11);
moments{4} = grfs.data(1:end,18);
moments{5} = grfs.data(1:end,19);
moments{6} = grfs.data(1:end,20);

% Filter the forces and moments.
dt = 1/fp_frame_rate;
for i=1:6
    forces{i} = ZeroLagButtFiltfilt(...
        dt, fp_cutoff_1, filter_order, filter_type, forces{i});
    moments{i} = ZeroLagButtFiltfilt(...
        dt, fp_cutoff_1, filter_order, filter_type, moments{i});
end

% Apply a threshold to the data for each plate. 
for i=1:3:4
    indices = forces{i+1} < fp_threshold_1;
    forces{i}(indices) = 0;
    forces{i+1}(indices) = 0;
    forces{i+2}(indices) = 0;
    moments{i}(indices) = 0;
    moments{i+1}(indices) = 0;
    moments{i+2}(indices) = 0;
end

% Re-calculate the CoP's.
for i=1:3:4
    cop{i} = -1*moments{i+2}./forces{i+1};
    cop{i+1} = zeros(length(cop{i}), 1);
    cop{i+2} = moments{i}./forces{i+1};
    
    % Set NaN's to 0.
    cop{i}(isnan(cop{i})) = 0;
    cop{i+2}(isnan(cop{i+2})) = 0;
end


% Refilter to remove the threshold effect.
for i=1:6
    forces{i} = ZeroLagButtFiltfilt(...
        dt, fp_cutoff_2, filter_order, filter_type, forces{i});
    moments{i} = ZeroLagButtFiltfilt(...
        dt, fp_cutoff_2, filter_order, filter_type, moments{i});
end

% Rethreshold.
for i=1:3:4
    indices = forces{i+1} < fp_threshold_2;
    forces{i}(indices) = 0;
    forces{i+1}(indices) = 0;
    forces{i+2}(indices) = 0;
    moments{i}(indices) = 0;
    moments{i+1}(indices) = 0;
    moments{i+2}(indices) = 0;
end

% Compute torques.
for i=1:3:4
    torques{i+1} = moments{i+1} - (cop{i+2}.*forces{i}) + (cop{i}.*forces{i+2});
    torques{i} = zeros(length(torques{i+1}), 1);
    torques{i+2} = torques{i};
end

% Create the data array.
data = [forces{1} forces{2} forces{3} cop{1} cop{2} cop{3} ...
    forces{4} forces{5} forces{6} cop{4} cop{5} cop{6} ...
    torques{1} torques{2} torques{3} torques{4} torques{5} torques{6}];

% Rotate the data to get it in the OpenSim axes system. 
data = RotateCS(data, rot);

% Print the .mot file. 
initial_time = grfs.data(1,1);
fid = fopen(output_file, 'w');
fprintf(fid, 'name %s\n', output_file);
fprintf(fid, 'datacolumns %i\n', size(data, 2) + 1);
fprintf(fid, 'datarows %i\n', size(data, 1));
fprintf(fid, 'range %.2f %.2f\n', 0.0, grfs.data(end,1) - initial_time);
fprintf(fid, 'endheader\n');
labels = {'time', ...
    'ground_force1_vx', 'ground_force1_vy', 'ground_force1_vz', ...
    'ground_force1_px', 'ground_force1_py', 'ground_force1_pz', ...
    'ground_force2_vx', 'ground_force2_vy', 'ground_force2_vz', ...
    'ground_force2_px', 'ground_force2_py', 'ground_force2_pz', ...
    'ground_torque1_x', 'ground_torque1_y', 'ground_torque1_z', ...
    'ground_torque2_x', 'ground_torque2_y', 'ground_torque2_z'};
for i=1:size(data, 2) + 1
    fprintf(fid, '%s\t', labels{i});
end
fprintf(fid, '\n');
for i=1:size(data, 1)
    fprintf(fid, '%.6f\t', grfs.data(i,1) - initial_time);
    for j=1:size(data, 2)
        fprintf(fid, '%.6f\t', data(i,j));
    end
    fprintf(fid, '\n');
end
fclose(fid);

end








