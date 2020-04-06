function gaussian(data, mean, sigma)
    return exp(-(sum((data - mean).^2)) / (2 * (sigma^2)))
end