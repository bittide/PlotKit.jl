

using PlotKit
using PlotKitCairo
using PlotKitAxes
using PlotKitDiagrams
using PlotKitGL
using Cairo


include(joinpath(pkgdir(PlotKitCairo), "test/runtests.jl"))
include(joinpath(pkgdir(PlotKitAxes), "test/runtests.jl"))
include(joinpath(pkgdir(PlotKitDiagrams), "test/runtests.jl"))
include(joinpath(pkgdir(PlotKitGL), "test/runtests.jl"))



