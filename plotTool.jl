include("BioAFMResult.jl")

function plotPredictResult(afmDatas::Array{Any,1}, result::Array{BioAFMResult, 1})
    Plots.gr()
    n = size(result, 1)
    plts = Plots.Plot[]
    
    for i in 1:n
        push!(plts, heatmap(afmDatas[i]))
        push!(plts, bar(result[i].Posteriors, xlabel="PDB = $(result[i].MostPlausiblePDB), Quate = $(result[i].MostPlausibleQuate)"))
    end
    
    plot(plts..., layout=Plots.GridLayout(n, 2), size=(1000, 400*n))
end
