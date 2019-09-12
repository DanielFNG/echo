function combinations = suggestRandomisedParameters(t, rise, peak, fall)
% Creates a combination vector and suggests random combinations until all
% have been explored.

    combinations = combvec(rise, peak, fall);
    n_combinations = size(combinations, 2);
    combinations = combinations(:, randperm(n_combinations));
    
    for i=1:n_combinations
        if issorted(combinations(:, i)) % Skip unordered combos
            fprintf('Applying rise %i, peak %i, fall %i.\n', ...
                combinations(1, i), combinations(2, i), combinations(3, i));
            sendControlParameters(t, combinations(1, i), combinations(2, i), combinations(3, i));
            input('Press any key to continue.');
        end
    end

end
