include("Asd.jl")
include("ReadHeader.jl")
include("ReadFrame.jl")

function readAsd(filePath)
    open(filePath, "r") do io
        headerVersion = Int64(read(io, Int32))
        
        if headerVersion == 0
            header = readHeaderV0(io)
            frames = []
            for i in 1:header.numFrames
                push!(frames, readFrame(io, header))
            end
            
            return Asd(header, frames)
        else
            # TODO
            @assert false
        end
    end
end