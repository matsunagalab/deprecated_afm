using Dates

abstract type AbstractHeader end
    
struct HeaderV0 <: AbstractHeader
    fileVersion       ::Int64
    dataType1ch       ::String     # 1chのデータ種別
    dataType2ch       ::String     # 2chのデータ種別
    fileHeaderSize    ::Int64      # ファイルヘッダサイズ（コメントのサイズ含む。）
    frameHeaderSize   ::Int64      # フレームヘッダサイズ（コメントのサイズ含む。）
    operatorNameSize  ::Int64
    commentOffsetSize ::Int64
    commentSize       ::Int64
    pixelX            ::Int64
    pixelY            ::Int64
    scanningRangeX    ::Int64
    scanningRangeY    ::Int64
    frameRate         ::Float64
    piezoExtensionZ   ::Float64    # Zピエゾ伸び係数[nm/V]
    piezoGainZ        ::Float64
    adRange           ::Float64    # AD電圧レンジ
    AdResolution      ::Float64    # AD分解能
    isAveraged        ::Bool       # 移動平均化フラグ（tureで移動平均）
    averageWindow     ::Int64      # 1ピクセルに使える最大データ数(最低１)
    day               ::DateTime
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
    sensorSensitivity ::Float64       # センサー感度
    phaseSensitivity  ::Float64       # 位相感度
    scannigDirection  ::Int64         # データ取得ステータスコード
    comment           ::Array{Int, 1}
end
