using CoolWalksUtils
using Dates
using ArchGDAL
using Test

@testset "CoolWalksUtils.jl" begin
    # Write your tests here.
end

include("SunPosition.jl")
include("Projection.jl")
include("BoundingBox.jl")
include("Maths.jl")
include("Testing.jl")