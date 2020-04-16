using MDToolbox
include("../mathTool.jl")
include("AtomParameter.jl")

mutable struct AfmizeConfig
    probeAngle::Float64        # Radian
    probeRadius::Float64
    range_min::Point2D
    range_max::Point2D
    resolution::Point2D
    atomRadiusDict::Dict{String, Float64}
end

function defaultConfig()
    return AfmizeConfig(10.0 * (pi / 180),
                        10.0, 
                        Point2D(-100, -100), 
                        Point2D(100, 100), 
                        Point2D(10, 10), 
                        defaultParameters())
end

function checkConfig(tra::TrjArray ,config::AfmizeConfig)::Union{String, Nothing}
    if (config.range_max.x - config.range_min.x) % config.resolution.x != 0
        return "resolution.x must divide range"
    end
    if (config.range_max.y - config.range_min.y) % config.resolution.y != 0
        return "resolution.y must divide range"
    end
    if config.probeAngle == 0
        return "probeAngle must be positive"
    end
    
    for name in tra.atomname
        if !haskey(config.atomRadiusDict, name)
            return "config dosen't know atom name $(name)"
        end
    end
    
    return nothing
end