include("Header.jl")

function getDataType(data)
    if     data == 0x5054 return "topography" 
    elseif data == 0x5245 return "error" 
    elseif data == 0x4850 return "phase" 
    else return "none" end
end

function getAdRange(data)
    # ADレンジ定数（ユニポーラ0～1V）(使われていないらしい)
    if     data == 0x00000001 @assert false
    # ADレンジ定数（ユニポーラ0～2.5V）(使われていないらしい)
    elseif data == 0x00000002 @assert false
    # ADレンジ定数（ユニポーラ0～5V）(使われていないらしい)
    elseif data == 0x00000004 @assert false
    # ADレンジ定数（バイポーラ±1V）
    elseif data == 0x00010000 return 2.0
    # ADレンジ定数（バイポーラ±2.5V）
    elseif data == 0x00020000 return 5.0
    # ADレンジ定数（バイポーラ±5V）
    elseif data == 0x00040000 return 10.0
    # ADレンジ定数（バイポーラ±80V, データを編集した場合に仮想的にこれを使う。実際にバイポーラ80VでAD変換したわけではない。また、分解能は16ビットにする）
    elseif data == 0x00080000 return 160.0
    # 何も当てはまらない
    else @assert false end
    return nothing
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

function readDate(io::IOStream)
    year              = Int64(read(io, Int16))
    month             = Int64(read(io, UInt8))
    day               = Int64(read(io, UInt8))
    hour              = Int64(read(io, UInt8))
    minute            = Int64(read(io, UInt8))
    second            = Int64(read(io, UInt8))
    return DateTime(year, month, day, hour, minute, second)
end

function readHeaderV0(io::IOStream)
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
    AdResolution      = (2.0)^Int64(read(io, Int32))
    isAveraged        = read(io, Bool)
    averageWindow     = Int64(read(io, Int32))
    legacy            = Int64(read(io, Int16)) # ダミー
    day               = readDate(io)
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
        
    return HeaderV0(fileVersion, dataType1ch, dataType2ch, fileHeaderSize, frameHeaderSize, operatorNameSize, commentOffsetSize, commentSize, pixelX, pixelY, scanningRangeX, scanningRangeY, frameRate, piezoExtensionZ, piezoGainZ, adRange, AdResolution, isAveraged, averageWindow, day, roundingDegree, maxRangeX, maxRangeY, booked1, booked2, booked3, initFrame, numFrames, machineId, fileId, operatorName, sensorSensitivity, phaseSensitivity, scannigDirection, comment)
end