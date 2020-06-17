function grfs = applyParameterisedAssistance(grfs, params)

    % Parameters. 
    sides = {'left', 'right'};
    left_index = 1;
    right_index = 2;
    init = 1000;
    avg_window = 3;  % How many gait cycles we use for averaging gait freq
    
    % Setup some arrays. 
    n_sides = length(sides);
    frames = cell(1, n_sides);
    apo_torques = ones(grfs.NFrames, n_sides)*init;
    
    for side = 1:n_sides
        % Get the indices corresponding to each gait cycle.
        [~, frames{side}] = segmentGRF(sides{side}, grfs);
        
        % Get the number of cycles and create an array to store the number
        % of frames in each cycle.
        n_cycles = length(frames{side});
        n_frames = zeros(1, n_cycles + 1);   
        
        % Loop over the cycles, starting from the avg_window + 1 cycle.
        for cycle = avg_window + 1:n_cycles + 1
            
            % Compute the number of frames predicted to be in that cycle -
            % from the mean of the previous avg_window cycles.
            for inner_cycle = cycle - avg_window:cycle - 1
                n_frames(cycle) = n_frames(cycle) + ...
                    length(frames{side}{inner_cycle});
            end
            n_frames(cycle) = round(n_frames(cycle)/avg_window);
            
            % Next, generate the torque pattern that would be applied by
            % the given number of parameters.
            profile = generateMixedBimodalAssistiveProfile(...
                n_frames(cycle), params.force, params.pext, ...
                params.rise, params.pflex, params.fall);
            
            % Compare the predicted and true number of frames in the cycle.
            if cycle == n_cycles + 1
                current_frames = frames{side}{cycle - 1}(end) + 1:grfs.NFrames;
            else
                current_frames = frames{side}{cycle};
            end
            disparity = length(current_frames) - n_frames(cycle);
            
            if disparity > 0
                % If the gait was longer than expected, loop the profile.
                apo_torques(...
                    current_frames(1:end - disparity), side) = profile;
                apo_torques(current_frames...
                    (end - disparity + 1:end), side) = profile(1:disparity);
            % If the gait was as expected, it's a perfect match.
            elseif disparity == 0
                apo_torques(current_frames, side) = profile;
            % If the gait was shorter than expected, simply complete as
            % much of the profile as you can.
            else
                apo_torques(current_frames, side) = ...
                    profile(1:end + disparity);  % + since it's negative
            end
        end
    end
    
    % Identify the frames for which the left & right APO torques are well
    % defined.
    good_frames = find(apo_torques(:, left_index) ~= init & ...
        apo_torques(:, right_index) ~= init);
    
    % Add an initial frame - to allow for later segmentation to work if
    % necessary.
    one_frame = good_frames(1) - 1;
    good_frames = [one_frame; good_frames];
    
    % Sort out the APO torques at this extra frame. 
    for side = 1:n_sides
        if apo_torques(one_frame, side) == init
            apo_torques(one_frame, side) = 0;
        end
    end
    
    % Create a new GRF object which has the correct APO forces appended to
    % it.
    grfs = createAPOGRFs(grfs, ...
        apo_torques(:, left_index), apo_torques(:, right_index));
    
    % Slice the GRF data to the point after which both the left & right APO
    % torques are well defined.
    grfs = grfs.slice(good_frames); %#ok<*FNDSB>
    
end