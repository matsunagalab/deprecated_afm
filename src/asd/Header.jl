abstract type AbstractHeader end

function getDataType(data)
    if     data == 0x5054 return "topography" 
    elseif data == 0x5245 return "error" 
    elseif data == 0x4850 return "phase" 
    else return "none" end
end

function getAdRange(data)
    if     data == 0x00000001 return "unipolar_1_0V" 
    elseif data == 0x00000002 return "unipolar_2_5V" 
    elseif data == 0x00000004 return "unipolar_5_0V" 
    elseif data == 0x00010000 return "bipolar_1_0V" 
    elseif data == 0x00020000 return "bipolar_2_5V" 
    elseif data == 0x00040000 return "bipolar_5_0V" 
    else return "dummy_value" end
end

function getOperatorName(io, operatorNameSize)
    ret = []
    for i in 1:operatorNameSize
        push!(ret, Int64(read(io, UInt8)))
    end
    return ret
end

function getComment(io, commentOffsetSize, commentSize)
    for i in 1:commentOffsetSize
        read(io, Bool)
    end
    ret = []
    for i in 1:commentSize
        push!(ret, Int64(read(io, UInt8)))
    end
    return ret
end
    
struct HeaderV0 <: AbstractHeader
    
    fileVersion       ::Int64
    dataType1ch       ::String
    dataType2ch       ::String
    fileHeaderSize    ::Int64
    frameHeaderSize   ::Int64
    operatorNameSize  ::Int64
    commentOffsetSize ::Int64
    commentSize       ::Int64
    pixelX            ::Int64
    pixelY            ::Int64
    scanningRangeX    ::Int64
    scanningRangeY    ::Int64
    frameRate         ::Float64
    piezoExtensionZ   ::Float64
    piezoGainZ        ::Float64
    adRange           ::String
    bitsData          ::Int64
    isAveraged        ::Bool
    averageWindow     ::Int64
    legacy            ::Int64
    year              ::Int64
    month             ::Int64
    day               ::Int64
    hour              ::Int64
    minute            ::Int64
    second            ::Int64
    roundingDegree    ::Int64
    maxRangeX         ::Float64
    maxRangeY         ::Float64
    booked1           ::Int64
    booked2           ::Int64
    booked3           ::Int64
    initFrame         ::Int64
    numFrames         ::Int64
    machineId         ::Int64
    fileId            ::Int64
    operatorName      ::Array{Int, 1}
    sensorSensitivity ::Float64
    phaseSensitivity  ::Float64
    scannigDirection  ::Int64
    comment           ::Array{Int, 1}

    
    function HeaderV0(io::IOStream)
        fileVersion       = 0
        dataType1ch       = getDataType(read(io, Int16))
        dataType2ch       = getDataType(read(io, Int16))
        fileHeaderSize    = Int64(read(io, Int32))
        frameHeaderSize   = Int64(read(io, Int32))
        operatorNameSize  = Int64(read(io, Int32))
        commentOffsetSize = Int64(read(io, Int32))
        commentSize       = Int64(read(io, Int32))
        pixelX            = Int64(read(io, Int16))
        pixelY            = Int64(read(io, Int16))
        scanningRangeX    = Int64(read(io, Int16))
        scanningRangeY    = Int64(read(io, Int16))
        frameRate         = Float64(read(io, Float32))
        piezoExtensionZ   = Float64(read(io, Float32))
        piezoGainZ        = Float64(read(io, Float32))
        adRange           = getAdRange(read(io, UInt32))
        bitsData          = Int64(read(io, Int32))
        isAveraged        = read(io, Bool)
        averageWindow     = Int64(read(io, Int32))
        legacy            = Int64(read(io, Int16))
        year              = Int64(read(io, Int16))
        month             = Int64(read(io, UInt8))
        day               = Int64(read(io, UInt8))
        hour              = Int64(read(io, UInt8))
        minute            = Int64(read(io, UInt8))
        second            = Int64(read(io, UInt8))
        roundingDegree    = Int64(read(io, UInt8))
        maxRangeX         = Float64(read(io, Float32))
        maxRangeY         = Float64(read(io, Float32))
        booked1           = Int64(read(io, Int32))
        booked2           = Int64(read(io, Int32))
        booked3           = Int64(read(io, Int32))
        initFrame         = Int64(read(io, Int32))
        numFrames         = Int64(read(io, Int32))
        machineId         = Int64(read(io, Int32))
        fileId            = Int64(read(io, Int16))
        operatorName      = getOperatorName(io, operatorNameSize)
        sensorSensitivity = Float64(read(io, Float32))
        phaseSensitivity  = Float64(read(io, Float32))
        scannigDirection  = Int64(read(io, Int32))
        comment           = getComment(io, commentOffsetSize, commentSize)
        
        return new(fileVersion, dataType1ch, dataType2ch, fileHeaderSize, frameHeaderSize, operatorNameSize, commentOffsetSize, commentSize, pixelX, pixelY, scanningRangeX, scanningRangeY, frameRate, piezoExtensionZ, piezoGainZ, adRange, bitsData, isAveraged, averageWindow, legacy, year, month, day, hour, minute, second, roundingDegree, maxRangeX, maxRangeY, booked1, booked2, booked3, initFrame, numFrames, machineId, fileId, operatorName, sensorSensitivity, phaseSensitivity, scannigDirection, comment)
    end
end
