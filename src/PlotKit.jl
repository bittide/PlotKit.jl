
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
export setup3d
setup3d(a::Extension) = println("Hello")




end
