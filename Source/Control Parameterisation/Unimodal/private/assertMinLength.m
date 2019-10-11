function pass = assertMinLength(X, multiplier, length)

    pass = multiplier*(X.fall - X.rise) > length;

end