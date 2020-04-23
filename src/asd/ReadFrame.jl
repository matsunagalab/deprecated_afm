include("Frame.jl")

"""
ADのバイナリ－物理量の変換公式は
物理量 = ボードのAD変換レンジ*(サンプリングバイナリデータ)/2^(分解能) - ボードのAD変換レンジの半分。 
また、PIDの信号を高さ情報として取り込んでいるので、

バイナリデータが大きい　＝　PIDの出力電圧が高い　＝　試料に対して押し込んでいる　＝　高さが低い

という関係になる。
したがって、高さの最大最小は

高さ最値小 = バイナリ最大値から計算した高さ
高さ最大値 = バイナリ最小値から計算した高さ
"""
function binaryToPhysicalQuantity(data, header, chanelType)
    # 電圧データに変換
    cc = header.adRange / header.AdResolution
    adUiniRange = header.adRange / 2
    
    # 電圧データを高さor位相データに変換するための乗数。ErrorとPhaseの場合はTopo像とは逆符号になる点に注意。
    multiplier = Float64(0)
    if chanelType == "topography"
        multiplier = header.piezoGainZ * header.piezoExtensionZ
    elseif chanelType == "error"
        multiplier = -1.0 * header.sensorSensitivity
    elseif chanelType == "phase"
        multiplier = if header.phaseSensitivity != 0 phaseSensitivity else -1.0 end
    else
        # ここには来ない
        @assert false
    end
    
    # nm -> angstrom(要議論)
    unitConversion = 10
    
    for y in 1:header.pixelY, x in 1:header.pixelX
        data[y, x] = (adUiniRange - data[y, x] * cc) * multiplier * unitConversion
    end
end

function readFrameHeader(io::IOStream)
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
        
    return FrameHeader(number, maxData, minData, offsetX, offsetY, tiltX, tiltY, isStimulated, booked1, booked2, booked3, booked4)
end

function readImage(io::IOStream, header, chanelType)
    data = zeros(header.pixelY, header.pixelX)
    # TODO: 平均化回数が1じゃないことがあるらしい(今は不必要？)
    for y in 1:header.pixelY, x in 1:header.pixelX
        data[y, x] = Int64(read(io, Int16))
    end
    binaryToPhysicalQuantity(data, header, chanelType)
    return data
end

function readFrame(io::IOStream, header)
    frameHeader = readFrameHeader(io)
        
    data = readImage(io, header, header.dataType1ch)
    
    if header.dataType2ch == "none"
        return Frame(frameHeader, data, nothing)
    end
    
    subData = readImage(io, header, header.dataType2ch)
        
    return Frame(frameHeader, data, subData)
end