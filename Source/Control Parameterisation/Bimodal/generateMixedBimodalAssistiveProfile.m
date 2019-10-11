function y = generateMixedBimodalAssistiveProfile(...
    n_points, force, rise, pflex, fall, pext)
% Generate a parameterised assistive torque profile.
%   Similar to generateAssistiveProfile, however this function mixes 
%   portions of sinusoidal waves which are centred at different levels
%   of the Y axis.
%
% --- Inputs:
% ---------- n_points = # of frames comprising trajectory 
% ---------- force = peak extension torque attained 
% ---------- rise = % crossing point during rising phase
% ---------- pflex = % at which peak flexion assistance occurs
% ---------- fall = % crossing point during falling phase
% ---------- pext = % at which peak extension assistance occurs
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
    
    % Initialise some parameters.
    rise_point = round((rise/101)*n_points);
    fall_point = round((fall/101)*n_points);
    pflex_point = round((pflex/101)*n_points);
    pext_point = round((pext/101)*n_points);

    % Check that we're in a valid ordering.
    if issorted([rise pflex fall pext])
        scenario = 1;
    elseif issorted([pext rise pflex fall])
        scenario = 2;
    elseif issorted([fall pext rise pflex]) 
        scenario = 3;
    else
        error('Shape parameters are invalid.');
    end
    
    % Set the flexion rising region - common to all methods
    lambda = pi/(pflex - rise);
    y(rise_point:pflex_point - 1) = (f_flex/2)* ...
        sin(lambda*x(1:pflex_point - rise_point) - pi/2) + f_flex/2;
    
    switch scenario
        case 1
            % Set the flexion falling region.
            lambda = pi/(fall - pflex);
            y(pflex_point:fall_point - 1) = (f_flex/2)* ...
                sin(lambda*x(1:fall_point - pflex_point) + pi/2) + f_flex/2;
            
            % Set the extension rising region.
            lambda = pi/(pext - fall);
            y(fall_point:pext_point - 1) = (f_ext/2)* ...
                sin(lambda*x(1:pext_point - fall_point) + pi/2) - f_ext/2;
            
            % Set the end and start - both portions of extension falling
            lambda = pi/(rise - pext);
            n = length(y(pext_point:end));
            m = length(y(1:rise_point - 1));
            y(pext_point:end) = (f_ext/2)* ...
                sin(lambda*x(1:n) + pi/2) - f_ext/2;
            y(1:m) = (f_flex/2)* ...
                sin(lambda*x(n + 1:rise_point - pext_point) + pi/2) - f_flex/2;
    end

    % Repeat more or less the same steps twice
    for i = 1:2

        
        
        % Set the flexion falling region.
        lambda = pi/(fall - pflex);
        y(pflex_point:fall_point - 1) = (f_flex/2)* ...
            sin(lambda*x(1:fall_point - pflex_point) + pi/2) + f_flex/2;

        % Set the extension rising region.
        lambda = pi/(pext - fall);
        y(fall_point:pext_point - 1) = (f_ext/2)* ...
            sin(lambda*x(1:pext_point - fall_point) + pi/2) - f_ext/2;
        
        % Scale the parameters.
        rise_point = rise_point + i*n_points;
        fall_point = fall_point + i*n_points;
        
        % Set the extension falling region.
        lambda = pi/(rise + 100 - pext);
        y(pext_point:rise_point - 1) = (f_ext/2)* ...
            sin(lambda*x(1:rise_point - pext_point) - pi/2) - f_ext/2;
        
        % Scale more parameters.
        pflex_point = pflex_point + i*n_points;
        pext_point = pext_point + i*n_points;

    end

end