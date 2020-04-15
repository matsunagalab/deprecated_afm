# Quate Displace
function BioAFM_QD(observedAfm, pdbList, quateList, sigma)::BioAFMResult
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
            nowPropability = Float64(0)
            calAfmWide = zeros(Float64, 3imgH, 3imgW)
            pdbRotated = MDToolbox.rotate(pdbList[pdbId], quateList[quateId, :])
            calAfmWide[imgH+1:2imgH, imgW+1:2imgW] = MDToolbox.afmize(pdbRotated, (150.0, 150.0), (imgH, imgW))
            
            for H in round(Int, imgH/2):round(Int, 3imgH/2), W in round(Int, imgW/2):round(Int, 3imgW/2)
                calculatedAfm = view(calAfmWide, H:(H+imgH-1), W:(W+imgW-1))
                nowPropability += gaussian(calculatedAfm, observedAfm, sigma)
            end
            
            sumPropability += nowPropability
            if mostPropability < nowPropability
                mostPropability = nowPropability
                mostPropabilityPDB = pdbId
                mostPropabilityQuate = quateId
            end
        end
        push!(posteriors, sumPropability)
    end
    posteriors ./= sum(posteriors)
    return BioAFMResult(posteriors, mostPropabilityPDB, mostPropabilityQuate)
end