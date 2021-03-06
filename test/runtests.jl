using RoME
using Base.Test


println("[TEST] Camera functions evaluations...")
include("testCameraFunctions.jl")
println("[SUCCESS]")

println("[TEST] Linear array functions evaluations...")
include("testDidsonFunctions.jl")
println("[SUCCESS]")

println("[TEST] Pose2 evaluations...")
include("TestPoseAndPoint2Constraints.jl")
println("[SUCCESS]")

println("[TEST] Pose3 evaluations...")
include("threeDimLinearProductTest.jl")
println("[SUCCESS]")
