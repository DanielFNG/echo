function pass = assertOrder(X)

    % If needed redistribute the pext and fall parameters.
    pass = (X.pext < X.rise) & (X.rise < X.pflex) & (X.pflex < X.fall);

end