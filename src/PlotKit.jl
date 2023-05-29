
module PlotKit

using PlotKitAxes
using PlotKitDiagrams
using PlotKitGL

function reexport(m)
    for a in names(m)
        eval(Expr(:export, a))
    end
end

reexport(PlotKitAxes)
reexport(PlotKitDiagrams)
reexport(PlotKitGL)

end
