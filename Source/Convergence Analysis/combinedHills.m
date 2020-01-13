function result = combinedHills(A, x, b1, b2)

    result = max(hill(60, x, b1), hill(A, x, b2));

end