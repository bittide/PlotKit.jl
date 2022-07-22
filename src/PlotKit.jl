module PlotKit

using Cairo



# These do not depend on PlotKit
include("cairotools.jl")
using .CairoTools

include("graphlayout.jl")
using .GraphLayout

include("cairogl.jl")
using .CairoGL


# since cairotools also exports draw
# put these here so we can access draw in CairoGL as well
CairoTools.draw(bren::CairoGL.Renderer, tex) = CairoGL.draw(bren, tex)
CairoTools.draw(cw::CairoWindow) = CairoGL.draw(cw)

#------------------------------------------------------------------------------
# exports 

# basic.jl
export @plotfns, DataIndices, getbox, setoptions!, expand_box

# axis.jl
export AxisMap, Ticks, best_labels, best_ticks, get_tick_extents

# axisbuilder.jl
export AxisStyle, AxisOptions, Layout, Axis, fit_box_around_data, set_window_size_from_data

# drawaxis.jl
export drawaxis, setclipbox

# graphs.jl
export Graph, drawgraph, shaded_graph, draw_digraph

# recorder.jl
export Drawable, Recorder, paint, save, over

# lineplots.jl
export drawplot

# layout.jl
export hbox, vbox, hvbox, stack, offset

# animator.jl
export Anim, frame, see, save_frames
    


#------------------------------------------------------------------------------
# reexport from cairotools

# structs
export Point, LineStyle, Box, Box2

# just data funs
export norm, interp, star, triangle, oblong, curve_to_bezier, bezier_point,
    bezier2, curve_from_endpoints, split_bezier

# colors
# TODO separate package
#export gblue, gred, ggreen, gyellow,
#    lightgblue, lightgred, lightgyellow, lightggreen,
#    darkgblue, darkgred, darkgyellow, darkggreen

# color funs
export hexcol, alphacol, cols, colormap, make_gradient

# text funs
export text, get_text_info

# surface funs
export  makepdfsurface, makepngsurface, makesurface,
    closepdfsurface, closepngsurface, closesurface

# core cairo wrappers
export source, set_linestyle

# elementary drawing
export rect, polyline, line, circle, curve, move_to, line_to, stroke

# convenience drawing
export draw, polygon, curve_between
export Node, CircularNode, RectangularNode
export StraightPath, CurvedPath, BezierPath, Path
export TriangularArrow, Arrow 

# images
export Pik, cairo_memory_surface_ctx, drawimage

# boxes
export expand_box, inbox


#----------------------------------------------------------
# reexport from graphlayout
export graphlayout, meshlayout



################################################################



#################################################################

greet() = "Hello World!"

include("basic.jl")
include("axis.jl")
include("axis_builder.jl")
include("draw_axis.jl")

include("graphs.jl")
include("drawing.jl")
include("recorder.jl")

include("lineplots.jl")

include("layout.jl")

include("animator.jl")




end

