function pass = assertOrder(X)

    pass = (X.rise <= X.peak) & (X.peak <= X.fall);

end