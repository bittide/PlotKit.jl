
module TestSet

using PlotKit

using Test
include("testset.jl")
end

using .TestSet
TestSet.main()


