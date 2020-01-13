function result = hill(A, x, b)

    result = A*exp((-1/50)*(sum((x - b).^2))) + 420;

end
