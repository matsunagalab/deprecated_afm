using Revise, MDToolbox, Plots, JLD2, Printf, DelimitedFiles

function create_image(pdbFileNum, quatenionNum, saveFileName)
    # read structure and remove center of mass
    pdb = MDToolbox.readpdb("model/0000$(pdbFileNum).pdb")
    MDToolbox.decenter!(pdb)

    # read quaternions
    quater = DelimitedFiles.readdlm("quaternion/QUATERNION_LIST_576_Orient")

    # rotate by to a quaternion value
    pdb_rotated = MDToolbox.rotate(pdb, quater[quatenionNum, :])
    afmData = MDToolbox.afmize(pdb_rotated, (150.0, 150.0), (16, 16))
    @save saveFileName afmData
end

pdbFiles = [1 2 3 4]
quatenionNums = [7, 52, 91, 500]
fileNameList = []
for i in 1:4
    saveFileName = @sprintf "testCase/pdb%02d_quaternion%04d.jld2" pdbFiles[i] quatenionNums[i]
    create_image(pdbFiles[i], quatenionNums[i], saveFileName)
    push!(fileNameList, saveFileName)
end
@save "testCase/fileNameList.jld2" fileNameList
