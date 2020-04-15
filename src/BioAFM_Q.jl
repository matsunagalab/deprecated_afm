# Quate
function BioAFM_Q(afmData, pdbList, quateList, sigma)::BioAFMResult
    imgHeight, imgWidth = size(afmData)
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
            nowAfmData = MDToolbox.afmize(pdbRotated, (150.0, 150.0), (imgHeight, imgWidth))
            nowPropability = gaussian(nowAfmData, afmData, sigma)
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
