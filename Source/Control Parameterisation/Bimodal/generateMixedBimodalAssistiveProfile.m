function y = generateMixedBimodalAssistiveProfile(...
    n_points, force, pext, rise, pflex, fall)
% Generate a parameterised assistive torque profile.
%   Similar to generateAssistiveProfile, however this function mixes 
%   portions of sinusoidal waves which are centred at different levels
%   of the Y axis.
%
% --- Inputs:
% ---------- n_points = # of frames comprising trajectory 
% ---------- force = peak extension torque attained 
% ---------- pext = % at which peak extension assistance occurs
% ---------- rise = % crossing point during rising phase
% ---------- pflex = % at which peak flexion assistance occurs
% ---------- fall = % crossing point during falling phase
% ---------- 
% --- Output:
% ---------- y = trajectory as an array of length n_points

    % Some parameters.
    ratio = 2/3;  % ratio of peak extension to peak flexion
    f_ext = force;
    f_flex = ratio*f_ext;

    % Initialise x and y.
    y = zeros(n_points, 1);
    x = linspace(0.0, 100.0, n_points);
    
    % An alternative initialisation. 
    rise_point = floor((rise/100)*n_points) + 1;
    fall_point = floor((fall/100)*n_points) + 1;
    pflex_point = floor((pflex/100)*n_points) + 1;
    pext_point = floor((pext/100)*n_points) + 1;
%   % Sanity check that the initialisation above is working - it is.
%     [~, rise_point] = min(abs(x - rise));
%     [~, fall_point] = min(abs(x - fall));
%     [~, pflex_point] = min(abs(x - pflex));
%     [~, pext_point] = min(abs(x - pext));

    % Check that we're in a valid ordering.
    if ~issorted([pext rise pflex fall])
        error('Shape parameters are invalid.');
    end

    % Set the extension falling region
    lambda = pi/(rise - pext);
    y(pext_point:rise_point - 1) = (f_ext/2)* ...
        sin(lambda*x(1:rise_point - pext_point) - pi/2) - f_ext/2;
    
    % Set the flexion rising region 
    lambda = pi/(pflex - rise);
    y(rise_point:pflex_point - 1) = (f_flex/2)* ...
        sin(lambda*x(1:pflex_point - rise_point) - pi/2) + f_flex/2;
    
    % Set the flexion falling region.
    lambda = pi/(fall - pflex);
    y(pflex_point:fall_point - 1) = (f_flex/2)* ...
        sin(lambda*x(1:fall_point - pflex_point) + pi/2) + f_flex/2;
    
    % Set the extension rising region.
    lambda = pi/(100 + pext - fall);
    end_point = n_points - fall_point + 1;
    start_point = pext_point - 1;
    y(fall_point:end) = (f_ext/2)* ...
        sin(lambda*x(1:end_point) + pi/2) - f_ext/2;
    y(1:pext_point - 1) = (f_ext/2)* ...
        sin(lambda*x(end_point + 1: end_point + start_point) + pi/2) - ...
        f_ext/2;

end