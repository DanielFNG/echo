% Define suitable ranges for control parameters. 
rise = [45, 50, 55];
peak = [50, 55, 60];
fall = [65, 70, 75];

% Suggest random combinations.
combos = suggestRandomisedParameters(rise, peak, fall);

% Done.
fprintf('Done.\n');

