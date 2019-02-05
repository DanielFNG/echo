function suggestRandomisedParameters(rise, peak, fall)

    combinations = combvec(rise, peak, fall);
    n_combinations = size(combinations, 2);
    combinations = combinations(randperm(1:n_combinations));
    
    for i=1:n_combinations
        fprintf('Apply rise %i, peak %i, fall %i.\n', ...
            combinations(1, i), combinations(2, i), combinations(3, i));
        input('Press any key to continue.');
    end

end
