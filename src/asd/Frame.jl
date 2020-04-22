include("Header.jl")

struct FrameHeader
    number       ::Int64
    maxData      ::Int64
    minData      ::Int64
    offsetX      ::Int64
    offsetY      ::Int64
    tiltX        ::Float64
    tiltY        ::Float64
    isStimulated ::Bool
    booked1      ::Int64
    booked2      ::Int64
    booked3      ::Int64
    booked4      ::Int64
    
    function FrameHeader(io::IOStream)
        number       = Int64(read(io, Int32))
        maxData      = Int64(read(io, Int16))
        minData      = Int64(read(io, Int16))
        offsetX      = Int64(read(io, Int16))
        offsetY      = Int64(read(io, Int16))
        tiltX        = Float64(read(io, Float32))
        tiltY        = Float64(read(io, Float32))
        isStimulated = read(io, Bool)
        booked1      = Int64(read(io, Int8))
        booked2      = Int64(read(io, Int16))
        booked3      = Int64(read(io, Int32))
        booked4      = Int64(read(io, Int32))
        
        return new(number, maxData, minData, offsetX, offsetY, tiltX, tiltY, isStimulated, booked1, booked2, booked3, booked4)
    end
end

struct Frame
    header::FrameHeader
    data::Array{Int64, 2}
    
    function Frame(io::IOStream, header)
        frameHeader = FrameHeader(io)
        data = zeros(header.pixelY, header.pixelX)
        for y in 1:header.pixelY, x in 1:header.pixelX
            data[y, x] = Int64(read(io, Int16))
        end
        return new(frameHeader, data)
    end
end