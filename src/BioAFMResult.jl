mutable struct BioAFMResult
    Posteriors::Array{<:AbstractFloat,1}
    MostPlausiblePDB::Int64
    MostPlausibleQuate::Int64
end

BioAFMResult() = BioAFMResult([], 0, 0)