using FFTW

function gaussian(data, mean, sigma)
    return exp(-(sum((data - mean).^2)) / (2 * (sigma^2)))
end

"""
[h1, h2],[w1, w2]の総和
"""
function getRangeSum(
        accumArray::Array{Float64, 2}, 
        h1::Int, 
        w1::Int, 
        h2::Int, 
        w2::Int)::Float64
    ret = accumArray[h2, w2]
    if (h1 > 1) ret -= accumArray[h1-1, w2] end
    if (w1 > 1) ret -= accumArray[h2, w1-1] end
    if (h1 > 1 && w1 > 1) ret += accumArray[h1-1, w1-1] end
    
    return ret
end

function bayesEstimationWithFFTConvolution(
        observed::Array{Float64, 2}, 
        calculated::Array{Float64, 2}, 
        sigma::Float64)::Float64
    
    imgH, imgW = size(observed)
    N_pix = imgH * imgW
    plausibleSum = Float64(0)

    C_oo = sum(observed .^ 2)
    C_ccAcc = [calculated calculated; calculated calculated] .^ 2
    
    for h in 1:2imgH, w in 1:2imgW
        if w != 2imgW C_ccAcc[h, w+1] += C_ccAcc[h, w] end
    end
    for h in 1:2imgH, w in 1:2imgW
        if h != 2imgH C_ccAcc[h+1, w] += C_ccAcc[h, w] end
    end

    C_coMat = real.(ifft(fft(calculated).*conj.(fft(observed))))
    
    for h in 1:imgH, w in 1:imgW
        C_cc = getRangeSum(C_ccAcc, h, w, h+imgH-1, w+imgW-1)
        C_co = C_coMat[h, w]
        
        plausibleSum += exp(- (C_oo - 2 * C_co + C_cc) / (2 * sigma^2) )
    end
    
    return plausibleSum
end

"""
function bayesEstimationWithFFTConvolution(
        observed::Array{Float64, 2}, 
        calculated::Array{Float64, 2}, 
        imgH::Int,
        imgW::Int,
        extendImgH::Int,
        extendImgW::Int,
        sigma::Float64)::Float64
    
    N_pix = imgH * imgW
    plausibleSum = Float64(0)

    C_o = sum(observed)
    C_oo = sum(observed .^ 2)
    
    C_cAcc = [calculated calculated; calculated calculated]
    C_ccAcc = C_cAcc .^ 2
    
    for h in 1:2extendImgH, w in 1:2extendImgW
        if w != 2extendImgW 
            C_cAcc[h, w+1] += C_cAcc[h, w] 
            C_ccAcc[h, w+1] += C_ccAcc[h, w] 
        end
    end
    for h in 1:2extendImgH, w in 1:2extendImgW
        if h != 2extendImgH 
            C_cAcc[h+1, w] += C_cAcc[h, w] 
            C_ccAcc[h+1, w] += C_ccAcc[h, w] 
        end
    end

    C_coLis = abs.(ifft(fft(calculated).*conj.(fft(observed))))
    
    basePlausible = sigma^(2-N_pix) * (2pi)^(1-N_pix/2)
    
    for h in 1:extendImgH, w in 1:extendImgW
        C_c = getRangeSum(C_cAcc, h, w, h+imgH-1, w+imgW-1)
        C_cc = getRangeSum(C_ccAcc, h, w, h+imgH-1, w+imgW-1)
        C_co = C_coLis[h, w]
        
        if N_pix * C_cc - C_c^2 < 1e-8 continue end
        if C_co < 1e-8 continue end
        
        thisPlausible = basePlausible
        index = N_pix * (C_cc * C_oo - C_co^2) 
        index += 2C_o * C_co * C_c 
        index -= C_cc * C_o^2
        index -= C_oo * C_c^2
        index /= 2 * sigma^2 * (N_pix * C_cc - C_c^2)
        
        if index < 0 continue end
        
        thisPlausible *= exp(-index)
        thisPlausible /= sqrt(N_pix * C_cc - C_c^2)
        
        plausibleSum += thisPlausible
    end
    
    return plausibleSum
end
"""