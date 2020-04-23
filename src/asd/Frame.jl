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
end

struct Frame
    header   ::FrameHeader
    data     ::Array{Float64, 2}
    subData  ::Union{Array{Float64, 2}, Nothing}
end
