include("BioAFMResult.jl")

function plotPredictResult(filenameList, afmDatas::Array{Any,1}, result::Array{BioAFMResult, 1})
    Plots.gr()
    n = size(result, 1)
    plts = Plots.Plot[]
    
    for i in 1:n
        push!(plts, heatmap(afmDatas[i], xlabel="$(filenameList[i])"))
        push!(plts, bar(result[i].Posteriors, xlabel="PDB = $(result[i].MostPlausiblePDB), Quate = $(result[i].MostPlausibleQuate)"))
    end
    
    plot(plts..., layout=Plots.GridLayout(n, 2), size=(1000, 400*n))
end

function plotPredictResultWithAfmize(filenameList, afmDatas, result, pdbList, quateList)
    Plots.gr()
    n = size(result, 1)
    plts = Plots.Plot[]
    
    for i in 1:n
        pdb = pdbList[result[i].MostPlausiblePDB]
        pdb_rotated = MDToolbox.rotate(pdb, quateList[result[i].MostPlausibleQuate, :])
        calAfm = afmize_beta(pdb_rotated, defaultConfig())
        
        push!(plts, heatmap(afmDatas[i], xlabel="$(filenameList[i])"))
        push!(plts, heatmap(calAfm, xlabel="calculated"))
        push!(plts, bar(result[i].Posteriors, xlabel="PDB = $(result[i].MostPlausiblePDB), Quate = $(result[i].MostPlausibleQuate)"))
    end
    
    plot(plts..., layout=Plots.GridLayout(n, 3), size=(1500, 400*n))
end
