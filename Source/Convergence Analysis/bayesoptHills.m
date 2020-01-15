function result = bayesoptHills(bayesX, A, b1, b2)

    x = [bayesX.pext, bayesX.rise, bayesX.pflex, bayesX.fall];
    result = -combinedHills(A, x, b1, b2); % Switch to - due to minima. 

end