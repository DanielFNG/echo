function pass = assertOrder(X)

    % If needed redistribute the pext and fall parameters.
    pass = (X.rise <= X.pflex) && (...
        ((X.pflex <= X.fall) && (X.fall <= X.pext)) || ... % all < 100
        ((X.pflex <= X.fall) && (X.pext <= X.rise)) || ... % pext wraps
        ((X.fall <= X.pext) && (X.pext <= X.rise))); % pext & fall wrap

end