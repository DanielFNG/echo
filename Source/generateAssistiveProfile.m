function y = generateAssistiveProfile(...
    n_points, peak_force, rise_pc, peak_pc, fall_pc)
% Generate a parameterised assistive torque profile.
%
% Generates a trajectory which goes from x = 0.0 to x = 100.0. Peaks at the
% value given by peak_force. 
%
% --- Inputs:
% ---------- n_points = # of frames comprising trajectory 
% ---------- peak_force = peak force attained 
% ---------- rise_pc = % at which trajectory begins to rise
% ---------- peak_pc = % at which trajectory peaks
% ---------- fall_pc = % at which trajectory reaches 0 again
% --- Output:
% ---------- y = trajectory as an array of length n_points

if ~(rise_pc <= peak_pc && peak_pc <= fall_pc)
    error('Must have rise <= peak <= fall.');
end

% Initialise x and y.
y = zeros(n_points, 1);
x = linspace(0.0, 100.0, n_points);

% Set the rising region of y.
lambda = (pi/2)/peak_pc;
peak_point = round((peak_pc/100)*n_points);
rise_trajectory = peak_force*sin(lambda*x(1:peak_point));
y(rise_pc:peak_point) = ...
    stretchVector(rise_trajectory, peak_point - rise_pc + 1);

% Set the falling region of y. 
lambda = (pi/2)/(fall_pc - peak_pc);
offset_point = round((fall_pc/100)*n_points);
y(peak_point+1:offset_point-1) = ...
    peak_force*cos(lambda*x(2:offset_point-peak_point));

% Set the region of y which is identically zero. 
y(offset_point+1:end) = 0;

end



