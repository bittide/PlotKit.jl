# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module PlotKit

using Cairo
using LinearAlgebra

include("tools.jl")
using .Tools

include("colors.jl")
# uses Tools
using .Colors

# These do not depend on PlotKit
# CairoTools uses Color and Tools
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
export @plotfns, DataIndices, expand_box, scale_box, getbox, ifnotmissing, overdata, setoptions!

# axis.jl
export AxisMap, Ticks, best_labels, best_ticks, get_tick_extents

# axisbuilder.jl
export Axis, AxisOptions, AxisStyle, Layout, fit_box_around_data, set_window_size_from_data

# drawaxis.jl
export drawaxis, setclipbox

# graphs.jl
export Graph, draw_digraph, drawgraph, shaded_graph

# recorder.jl
export Drawable, Recorder, over, paint, save

# lineplots.jl
export drawplot

# layout.jl
export hbox, hvbox, offset, stack, vbox

# animator.jl
export Anim, frame, save_frames, see
    
#------------------------------------------------------------------------------
# reexport from Colors

export Color, RGBAColor, RGBColor, hadamard, hadamarddiv

# ---------------------------------------------------------------------------
# reexport from Tools

export interp, makevector, normalize


#------------------------------------------------------------------------------
# reexport from cairotools

# structs
export Box, Box2, LineStyle, Point

# just data funs
export bezier2, bezier_point, curve_from_endpoints, curve_to_bezier, norm,
    oblong, split_bezier, star, triangle

# colors
# TODO separate package
#export gblue, gred, ggreen, gyellow,
#    lightgblue, lightgred, lightgyellow, lightggreen,
#    darkgblue, darkgred, darkgyellow, darkggreen

# color funs
export alphacol, colormap, cols, hexcol, make_gradient

# text funs
export get_text_info, text

# surface funs
export  closepdfsurface, closepngsurface, closesurface,
    makepdfsurface, makepngsurface, makesurface

# core cairo wrappers
export set_linestyle, source

# elementary drawing
export circle, curve, line, line_to, move_to, polyline, rect, stroke

# convenience drawing
export curve_between, draw, polygon 

# images
export Pik, cairo_memory_surface_ctx, drawimage, drawimage_to_mask

# boxes
export expand_box, inbox


#----------------------------------------------------------
# reexport from graphlayout
export graphlayout, meshlayout


#----------------------------------------------------------
# reexport from diagrams
export Arrow, BezierPath, CircularNode, CurvedPath, Node, Path
export RectangularNode, StraightPath, TriangularArrow


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



include("diagrams.jl")



end

