function pass = parameterConstraints(X)
% Constraints on Bayesian Optimisation [rise, peak, fall] parameters. 

% Assert that rise <= peak <= fall.
ordered_parameters = (X.rise <= X.peak) & (X.peak <= X.fall);

% Assert minimum length of applied assistance - 10% of gait cycle.
%minimum_length = (X.fall - X.rise) > 10;

% Combine constraints. 
pass = ordered_parameters;% & minimum_length;

end