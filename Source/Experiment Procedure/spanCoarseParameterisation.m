% Define suitable ranges for control parameters. 
rise = 50; %rise = [45, 50, 55];
peak = [55, 65, 75];
fall = [75, 85, 95];

% Suggest random combinations.
combos = suggestRandomisedParameters(rise, peak, fall);

% Done.
fprintf('Done.\n');

