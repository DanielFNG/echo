function y = generateAssistiveProfile(n_points, peak_ext, peak_flex, ... neg_rise, neg_peak, neg_fall, pos_rise, pos_peak, pos_fall)
% Generate a parameterised assistive torque profile.
%   Similar to generateAssistiveProfile, however this function generates
%   a bimodal assistance pattern for both flexion & extension assistance. In 
%   particular the assistance profile consists of a period of negative torque
%   (assisting hip extension) followed by a period of positive torque (assisting
%   hip flexion).  
%
%   Note that we assume that this assistance profile corresponds to a gait cycle
%   which begins at stance. 
%
% --- Inputs:
% ---------- n_points = # of frames comprising trajectory 
% ---------- peak_ext = peak extension torque attained 
% ---------- peak_flex = peak flexion torque attained
% ---------- neg_rise = % at which trajectory begins to rise negatively
% ---------- neg_peak = % at which trajectory peaks negatively
% ---------- neg_fall = % at which trajectory reaches 0 again
% ---------- pos_rise = % at which trajectory begins to rise positively 
% ---------- pos_peak = % at which trajectory peaks positively 
% ---------- pos_fall = % at which trajectory reaches 0 again 
% ---------- 
% --- Output:
% ---------- y = trajectory as an array of length n_points

if ~issorted([neg_rise neg_peak neg_fall pos_rise pos_peak pos_fall])
    error('Shape parameters are invalid.');
end

% Initialise x and y.
y = zeros(n_points, 1);
x = linspace(0.0, 100.0, n_points);

% Scale the parameters.
neg_rise_point = round((neg_rise/100)*n_points);
neg_peak_point = round((neg_peak/100)*n_points);
neg_fall_point = round((neg_fall/100)*n_points);
pos_rise_point = round((pos_rise/100)*n_points);
pos_peak_point = round((pos_peak/100)*n_points);
pos_fall_point = round((pos_fall/100)*n_points);

% Set the negative falling region of y.
lambda = (pi/2)/(neg_peak - neg_rise);
y(neg_rise_point:neg_peak_point - 1) = ...
    -peak_ext*sin(lambda*x(1:neg_peak_point - neg_rise_point));
    
% Set the negative rising region of y.
lambda = (pi/2)/(neg_fall - neg_peak);
y(neg_peak_point:neg_fall_point - 1) = ...
    -peak_ext*cos(lambda*x(1:neg_fall_point - neg_peak_point));
    
% Set the first zero-region.
y(neg_fall_point:pos_rise_point - 1) = 0;

% Set the rising region of y.
lambda = (pi/2)/(pos_peak - pos_rise);
y(pos_rise_point:pos_peak_point-1) = ...
    peak_flex*sin(lambda*x(1:pos_peak_point-pos_rise_point));

% Set the falling region of y. 
lambda = (pi/2)/(pos_fall - pos_peak);
y(pos_peak_point:pos_fall_point-1) = ...
    peak_flex*cos(lambda*x(1:pos_fall_point-pos_peak_point));

% Set the region of y which is identically zero. 
y(pos_fall_point:end) = 0;

end



