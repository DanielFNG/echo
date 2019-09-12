% Define suitable ranges for control parameters. 
rise = [40, 50]; %rise = [45, 50, 55];
peak = [65, 80];
fall = [80, 95];

% Suggest random combinations.
combos = suggestRandomisedParameters(t, rise, peak, fall);

% Save the combinations.
attempt = 1;
filename = ['results' sprintf('%03i', attempt) '.mat'];
while isa(filename, 'file')
    attempt = attempt + 1;
    filename = ['results' sprintf('%03i', attempt) '.mat'];
end
save(filename, 'combos');

% Done.
fprintf('Done.\n');

