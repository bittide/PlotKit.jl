
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

fnames = [:mesh_height_color_fn, :mesh_height_fn, :mesh, :surf,
          :raytrace, :ellipsoid, :box3, :sample_mesh, 
          :uniform, :polytope, :arbitrarysolid, :vec3, :pk3d]
for f in fnames
    @eval $f(a::Extension) = return
    @eval export $f
end







end
