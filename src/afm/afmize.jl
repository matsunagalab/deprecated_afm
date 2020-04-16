using MDToolbox

include("AfmizeConfig.jl")
include("Probe.jl")

function moveBottom(atoms::Array{Sphere})
    bottom = atoms[1].z - atoms[1].r
    for atom in atoms
        bottom = min(bottom, atom.z - atom.r)
    end
    for atom in atoms
        atom.z -= bottom
    end
end

function calcCollisionAsSphere(probe::Probe, atom::Sphere)
    distXY = sqrt((probe.x - atom.x)^2 + (probe.y - atom.y)^2)
    dr = probe.r + atom.r
    if 0 < dr^2 - distXY^2
        return atom.z + sqrt(dr^2 - distXY^2) - probe.r
    else
        return 0.0
    end
end

function calcCollisionAsCircularThrusters(probe::Probe, atom::Sphere)
    distXY = sqrt((probe.x - atom.x)^2 + (probe.y - atom.y)^2)
    collisionDist = probe.r + atom.r * cos(probe.angle)
    if collisionDist < distXY
        return atom.z + atom.r * sin(probe.angle) - (distXY - collisionDist) / tan(probe.angle) - probe.r
    elseif probe.r < distXY
        return atom.z + sqrt(atom.r^2 - (distXY - probe.r)^2) - probe.r
    else
        return 0.0
    end
end

function afmize(tra::TrjArray, config::AfmizeConfig)
    message = checkConfig(tra, config)
    if !isnothing(message)
        println(message)
        return zeros(1, 1)
    end
    
    width = floor(Int, (config.range_max.x - config.range_min.x) / config.resolution.x)
    height = floor(Int, (config.range_max.y - config.range_min.y) / config.resolution.y)
    atoms = [Sphere(tra.x[i], tra.y[i], tra.z[i], 
            config.atomRadiusDict[tra.atomname[i]]) for i in 1:tra.natom]
    moveBottom(atoms)

    stage = zeros(height, width)
    
    for h in 1:height, w in 1:width
        probe = Probe(conf.range_min.x + (w-0.5) * conf.resolution.x, 
                      conf.range_min.y + (h-0.5) * conf.resolution.y, 
                      conf.probeRadius, conf.probeAngle)
        for atom in atoms
            stage[h, w] = max(stage[h, w], calcCollisionAsSphere(probe, atom))
            stage[h, w] = max(stage[h, w], calcCollisionAsCircularThrusters(probe, atom))
        end
    end
    
    return stage
end