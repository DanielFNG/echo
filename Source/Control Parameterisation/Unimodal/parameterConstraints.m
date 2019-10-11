function pass = parameterConstraints(X, multiplier, length)
% Constraints on Bayesian Optimisation [rise, peak, fall] parameters.

    pass = assertOrder(X) & assertMinLength(X, multiplier, length);

end