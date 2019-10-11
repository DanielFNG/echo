function y = generateBimodalAssistiveProfile(...
    n_points, force, rise, pflex, pext, fall)
% Generate a parameterised assistive torque profile.
%   Similar to generateAssistiveProfile, however this function generates
%   a bimodal assistance pattern for both flexion & extension assistance.
%
%   Note that we assume that this assistance profile corresponds to a gait 
%   cycle which begins at stance. Also, for simplicity, we compute over a 
%   period of n_points * 3, assuming the profile only begins to deviate 
%   from 0 at the rise point, and compute for the remainder of the 
%   trajectory. The output is then the interior of the full trajectory.
%
% --- Inputs:
% ---------- n_points = # of frames comprising trajectory 
% ---------- force = peak extension torque attained 
% ---------- rise = % at which trajectory starts to rise
% ---------- pflex = % at which peak flexion assistance occurs
% ---------- pext = % at which peak extension assistance occurs
% ---------- fall = % at which trajectory drops to 0
% ---------- 
% --- Output:
% ---------- y = trajectory as an array of length n_points

% If needed redistribute the pext and fall parameters.
if pext < pflex
    pext = pext + 100;
    fall = fall + 100;
elseif fall < pext
    fall = fall + 100;
end

if ~issorted([rise pflex pext fall])
    error('Shape parameters are invalid.');
end

% Initialise x and y.
y = zeros(3*n_points, 1);
x = linspace(0.0, 300.0, 3*n_points);

% Scale the parameters.
rise_point = round((rise/300)*3*n_points);
pflex_point = round((pflex/300)*3*n_points);
pext_point = round((pext/300)*3*n_points);
fall_point = round((fall/300)*3*n_points);

% Set the rising region.
lambda = (pi/2)/(pflex - rise);
y(rise_point:pflex_point - 1) = ...
    force*sin(lambda*x(1:pflex_point - rise_point));

% Set the transition region.
lambda = 2*(pi/2)/(pext - pflex);
y(pflex_point:pext_point - 1) = ...
    force*cos(lambda*x(1:pext_point - pflex_point));
    
% Set the fall region.
lambda = (pi/2)/(fall - pext);
y(pext_point:fall_point - 1) = ...
    -force*cos(lambda*x(1:fall_point - pext_point));

% Adjust parameters for next round. 
rise = rise + 100;
pflex = pflex + 100;
pext = pext + 100;
fall = fall + 100;
rise_point = round((rise/300)*3*n_points);
pflex_point = round((pflex/300)*3*n_points);
pext_point = round((pext/300)*3*n_points);
fall_point = round((fall/300)*3*n_points);

% Set the rising region.
lambda = (pi/2)/(pflex - rise);
y(rise_point:pflex_point - 1) = ...
    (2/3*force)*sin(lambda*x(1:pflex_point - rise_point));

% Set the transition region.
lambda = 2*(pi/2)/(pext - pflex);
y(pflex_point:pext_point - 1) = ...
    (5/3/2*force)*cos(lambda*x(1:pext_point - pflex_point)) - (1/3/2*force);

% Set the fall region.
lambda = (pi/2)/(fall - pext);
y(pext_point:fall_point - 1) = ...
    -force*cos(lambda*x(1:fall_point - pext_point));

% Select the good region.
y = y(n_points + 1:2*n_points);

end



