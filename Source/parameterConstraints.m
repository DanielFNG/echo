function pass = parameterConstraints(X)

% Assert that rise <= peak <= fall.
ordered_parameters = (X.rise <= X.peak) & (X.peak <= X.fall);

% Assert minimum length of applied assistance.
minimum_length = (X.fall - X.rise) > 10;

% Combine constraints. 
pass = ordered_parameters & minimum_length;

end