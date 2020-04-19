# Quate Displace
function BioAFMize_QD_FFT(observedAfm, pdbList, quateList, sigma, config)::BioAFMResult
    imgH, imgW = size(observedAfm)
    pdbNum = size(pdbList, 1)
    quateNum = size(quateList, 1)
    posteriors = Float64[]
    mostPropability = Float64(0)
    mostPropabilityPDB = Int(0)
    mostPropabilityQuate = Int(0)

    for pdbId in 1:pdbNum
        sumPropability = Float64(0)
        for quateId in 1:quateNum
            pdbRotated = MDToolbox.rotate(pdbList[pdbId], quateList[quateId, :])
            calculatedAfm = afmize_beta(pdbRotated, config)
            
            nowPropability = bayesEstimationWithFFTConvolution(observedAfm, calculatedAfm, sigma)

            sumPropability += nowPropability
            if mostPropability < nowPropability
                mostPropability = nowPropability
                mostPropabilityPDB = pdbId
                mostPropabilityQuate = quateId
            end
        end
        push!(posteriors, sumPropability)
    end
    println(posteriors)
    posteriors ./= sum(posteriors)
    return BioAFMResult(posteriors, mostPropabilityPDB, mostPropabilityQuate)
end
