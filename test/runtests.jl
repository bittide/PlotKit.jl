
module TestSet

using PlotKit
const pk = PlotKit
plotpath(x) = joinpath(tempdir(), x)
using Test
include("testset.jl")
qsee(args...; kwargs...) = true
qsave(d, f; kwargs...) = true
qclosesurface(d, f) = true

end

using .TestSet


TestSet.main()

