include("Header.jl")
include("Frame.jl")

# 現在単位はÅ
struct Asd
    header   ::AbstractHeader
    frames   ::Array{Frame, 1}
end