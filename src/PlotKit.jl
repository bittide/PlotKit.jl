
module PlotKit

using PlotKitAxes
using PlotKitDiagrams
using PlotKitGL
using PlotKitCharts

function reexport(m)
    for a in names(m)
        eval(Expr(:export, a))
    end
end

reexport(PlotKitAxes)
reexport(PlotKitDiagrams)
reexport(PlotKitGL)
reexport(PlotKitCharts)

# For extensions
abstract type Extension end
abstract type Shape end
abstract type Texture end
abstract type Uniform <: Texture end
abstract type Ellipsoid <: Shape end
abstract type Box3 end

fnames = [:mesh_height_color_fn, :mesh_height_fn, :mesh, :surf, :Uniform, :Ellipsoid, :Box3, :raytrace]
for f in fnames
    @eval $f(a::Extension) = return
    @eval export $f
end




end
