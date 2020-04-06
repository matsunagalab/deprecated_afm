@time using Revise, MDToolbox, Plots, JLD2, Printf, DelimitedFiles

function gaussian(data, mean, sigma)
    return exp(-(sum(data - mean)^2) / (2 * (sigma^2)))
end

function BioAFM_Quate(afmData, pdbList, quateList, sigma)::NamedTuple{(:Posteriors, :MostPlausiblePDB, :MostPlausibleQuate),Tuple{Array{Any,1},Int64,Int64}}
    img_height, img_width = size(afmData)
    pdbNum = size(pdbList, 1)
    quateNum = size(quateList, 1)
    posteriors = []
    mostPlausible = Float64(0)
    mostPlausiblePDB = Int(0)
    mostPlausibleQuate = Int(0)

    for pdb_id in 1:pdbNum
        sumPlausible = Float64(0)
        for quate_id in 1:quateNum

            pdb_rotated = MDToolbox.rotate(pdbList[pdb_id], quateList[quate_id, :])
            nowAfmData = MDToolbox.afmize(pdb_rotated, (150.0, 150.0), (img_height, img_width))
            nowPlausible = gaussian(nowAfmData, afmData, sigma)
            sumPlausible += nowPlausible
            if mostPlausible < nowPlausible
                mostPlausible = nowPlausible
                mostPlausiblePDB = pdb_id
                mostPlausibleQuate = quate_id
            end
        end
        push!(posteriors, sumPlausible)
    end
    posteriors ./= maximum(posteriors)
    return (Posteriors=posteriors, MostPlausiblePDB=mostPlausiblePDB, MostPlausibleQuate=mostPlausibleQuate)
end

quateList = DelimitedFiles.readdlm("quaternion/QUATERNION_LIST_576_Orient")
pdbList = [readpdb("model/0000$(i).pdb") for i in 1:4]
@load "testcase/fileNameList.jld2" fileNameList

println(fileNameList)

resultList = []
for fileName in fileNameList
    @load fileName afmData
    push!(resultList, BioAFM_Quate(afmData, pdbList, quateList, 1))
    break
end

println(resultList)
