
module CairoTools

using LinearAlgebra
using ..Cairo
using ..Tools
using ..Colors




# structs
export Point, LineStyle, Box

# just data funs
export star, triangle, oblong, curve_to_bezier, bezier_point,
    bezier2, curve_from_endpoints, split_bezier

# colors
export gblue, gred, ggreen, gyellow,
    lightgblue, lightgred, lightgyellow, lightggreen,
    darkgblue, darkgred, darkgyellow, darkggreen

# color funs
export hexcol, colormap, hsv, make_gradient

# text funs
export text, get_text_info

# surface funs
export  makepdfsurface, makepngsurface, makesurface,
    closepdfsurface, closepngsurface, closesurface

# core cairo wrappers
export source, set_linestyle

# elementary drawing
export rect, line, circle, curve, move_to, line_to, stroke

# convenience drawing
export draw, polygon, curve_between
export Node, CircularNode, RectangularNode
export StraightPath, CurvedPath, BezierPath, Path
export TriangularArrow, Arrow 

# images
export Pik, cairo_memory_surface_ctx, drawimage, drawimage_to_mask

# boxes
export expand_box, scale_box, inbox

##############################################################################
# points

struct Point
    x::Number
    y::Number
end

eval(makevector(Point))

function Base.:*(A::Matrix, b::Point) 
    return  Point(A[1,1]*b.x + A[1,2]*b.y,  A[2,1]*b.x + A[2,2]*b.y)
end

# utils
polar(r, theta) = Point(r*cos(theta), r*sin(theta))

##############################################################################
# colors




##############################################################################
# boxes

"""
    struct Box
        xmin, xmax, ymin, ymax
    end

"""
mutable struct Box
    xmin
    xmax
    ymin
    ymax
end


Box(; xmin=missing, xmax=missing, ymin=missing, ymax=missing) = Box(xmin, xmax, ymin, ymax)

# just specify topleft
Box(xmin, ymin; width = 0, height = 0) = Box(xmin, xmin + width,
                                             ymin, ymin + height)

Box(tl::Point, br::Point) = Box(tl.x, br.x, tl.y, br.y)

Base.copy(a::Box) =  Box(a.xmin, a.xmax, a.ymin, a.ymax)

function expand_box(b::Box, dx, dy)
    return Box(b.xmin - dx, b.xmax + dx, b.ymin - dy, b.ymax + dy)
end

function scale_box(b::Box, rx, ry)
    width = b.xmax - b.xmin
    height = b.ymax - b.ymin
    cx = (b.xmax + b.xmin) / 2
    cy = (b.ymax + b.ymin) / 2
    return Box(cx - rx*width/2, cx + rx*width/2, cy - ry*height/2, cy + ry*height/2)
end

inbox(p::Point, b::Box) = (b.xmin <= p.x <= b.xmax) && (b.ymin <= p.y <= b.ymax)

function Base.getproperty(b::Box, s::Symbol)
    if s == :width
        return getfield(b, :xmax) - getfield(b, :xmin)
    elseif s == :height
        return getfield(b, :ymax) - getfield(b, :ymin)
    elseif s == :center
        return Point((getfield(b, :xmin) + getfield(b, :xmax))/2,
                     (getfield(b, :ymin) + getfield(b, :ymax))/2)
    elseif s == :topleft
        return Point(getfield(b, :xmin), getfield(b, :ymin))
    elseif s == :topright
        return Point(getfield(b, :xmax), getfield(b, :ymin))
    elseif s == :botright
        return Point(getfield(b, :xmax), getfield(b, :ymax))
    elseif s == :botleft
        return Point(getfield(b, :xmin), getfield(b, :ymax))
    elseif s == :corners
        return (Point(getfield(b, :xmin), getfield(b, :ymin)),
                Point(getfield(b, :xmin), getfield(b, :ymax)),
                Point(getfield(b, :xmax), getfield(b, :ymax)),
                Point(getfield(b, :xmax), getfield(b, :ymin)))
    elseif s == :size
        return Point(getfield(b, :xmax) - getfield(b, :xmin),
                     getfield(b, :ymax) - getfield(b, :ymin))
    else
        return getfield(b, s)
    end
end
    



##############################################################################

mutable struct LineStyle
    color
    width
end

#LineStyle(c::Tuple, w) = LineStyle(Color(c), w)



##############################################################################
# text functions

"""
    get_text_info(ctx, fsize, txt)

Returns the Cairo text_extents data giving the dimensions of the text at size fsize.
"""
function get_text_info(ctx, fsize, txt)
    Cairo.select_font_face(ctx, "Sans", Cairo.FONT_SLANT_NORMAL,
                           Cairo.FONT_WEIGHT_NORMAL)
    Cairo.set_font_size(ctx, fsize)
    return Cairo.text_extents(ctx, txt)
end

"""
    text(ctx, p, fsize, color, txt; horizontal, vertical)

Write txt to the Cairo context at point p, with given size and color.

Here horizontal alignment can be "left", "center", or "right".
Vertical alignment can be "top", "center", "bottom" or "baseline".
"""
function Cairo.text(ctx, p::Point, fsize, fcolor, txt; horizontal = "left", vertical="baseline")
    left, top, width, height = get_text_info(ctx, fsize, txt)
    if horizontal == "left"
        dx = left
    elseif horizontal == "center"
        dx = left + width/2
    elseif horizontal == "right"
        dx = left + width
    end
    if vertical == "top"
        dy = top 
    elseif vertical == "center"
        dy = top + height/2
    elseif vertical == "bottom"
        dy = top + height
    elseif vertical == "baseline"
        dy = 0
    end
    p = p - Point(dx, dy)
    textx(ctx, p, fsize, fcolor, txt)
end

##############################################################################
# surface functions

"""
    makerecordingsurface(width, height)

Create a Cairo recording surface.
"""
function makerecordingsurface(width, height)
    surface = CairoRecordingSurface(Cairo.CONTENT_COLOR_ALPHA,
                                    Cairo.CairoRectangle(0,0,width,height))
    ctx = CairoContext(surface)
    return surface, ctx
end


"""
     makepdfsurface(width, height, fname)

Create a Cairo surface for writing to pdf file fname.
"""
function makepdfsurface(width, height, fname)
    surface = CairoPDFSurface(fname, width, height)
    ctx = CairoContext(surface)
    return surface, ctx
end



"""
     makesvgsurface(width, height, fname)

Create a Cairo surface for writing to svg file fname.
"""
function makesvgsurface(width, height, fname)
    surface = CairoSVGSurface(fname, width, height)
    ctx = CairoContext(surface)
    return surface, ctx
end


"""
    makepngsurface(width, height)

Create a Cairo surface for writing to a png file.
"""
function makepngsurface(width, height)
    surface = CairoARGBSurface(width, height)
    ctx = CairoContext(surface)
    return surface, ctx
end


"""
    makesurface(width, height, fname)

Create a Cairo surface with given width/height. Determine type from the file extension.
"""
function makesurface(width, height, fname)
    if lowercase(fname[end-2:end]) == "png"
        surface, ctx = makepngsurface(width, height)
    elseif lowercase(fname[end-2:end]) == "svg"
        surface, ctx = makesvgsurface(width, height, fname)
    else
        surface, ctx = makepdfsurface(width, height, fname)
    end
    return surface, ctx
end


"""
    closesurface(surface, fname)

Close the Cairo surface and write output to fname.
"""
function closesurface(surface, fname)
    if lowercase(fname[end-2:end]) == "png"
        closepngsurface(surface, fname)
    else
        closepdfsurface(surface)
    end
end

"""
    closepdfsurface(surface)

Close the Cairo surface.
"""
closepdfsurface(surface)  =  Cairo.finish(surface)

"""
    closepngsurface(surface, fname)

Close the Cairo surface, and write output to the png file fname.
"""
closepngsurface(surface, fname)  =  Cairo.write_to_png(surface, fname)

"""
    closerecordingsurface(surface)

Close the Cairo surface.
"""
closerecordingsurface(surface) = Cairo.finish(surface)


"""
    get_scale(ctx)

Return the Cairo x,y scale factors between device and user space.
"""
function get_scale(ctx)
    s = Cairo.device_to_user_distance!(ctx, [1.0,0.0])
    return s[1], s[2]
end



##############################################################################
# polygons

"""
    centerx(p)

Translate a list of points p so that the mean is zero.
"""
function centerx(p::Vector{Point})
    c = sum(p)/length(p)
    return translate(p, -1 * c)
end

translate(p::Vector{Point}, c::Point) = [a + c for a in p]

"""
    rotate(p, theta)

Rotate a list of points p anticlockwise by theta about the origin, in x-right y-up coords.
"""
function rotate(p::Vector{Point}, theta::Number)
    R = [cos(theta) -sin(theta); sin(theta) cos(theta)]
    q = [R*x for x in p]
    return q
end

"""
    rotate(p, dir)

Rotate list of points p so that the x-axis points along dir.
"""
function rotate(p::Vector{Point}, dir::Point)
    dir = dir/norm(dir)
    R = [dir.x -dir.y ; dir.y dir.x]
    q = [R*x for x in p]
    return q
end

"""
    triangle(t)

Return a triangle with half-angle t at the right-hand vertex.

Returns a list of 3 vertices, (a,0,b). Here a and b are related by reflection about the x-axis.
The angle between a and b is 2t.
"""
triangle(t) = Point[ (-cos(t), sin(t)), (0,0), (-cos(t), -sin(t))]

"""
    oblong(w,h)

Return the vertices of a rectangle with one corner at the origin and the opposite corner at w,h.
"""
oblong(w, h) = Point[(0,0), (w,0), (w,h), (0,h)]

"""
    star(n,r)

Return a star of radius r with n points.
"""
function star(n, r)
    x = Point[]
    for i=1:2n
        radius = i % 2 == 0 ? 1 : r
        push!(x, Point(radius*cos(i*pi/n), radius*sin(i*pi/n)))
    end
    return x
end

"""
    polygon(ctx, p, theta, scale, points; center, closed, linestyle, fillcolor)

Draw a polygon specified by the list points, translated to p, rotated by theta, scaled.
"""
function polygon(ctx::CairoContext, p, theta, scale, points;
               center = false, closed = true, linestyle = nothing, fillcolor = nothing)
    if center
        points = centerx(points)
    end
    points = translate(scale .* rotate(points, theta), p)
    line(ctx, points; closed, linestyle, fillcolor)
end


##############################################################################
# core cairo

"""
    source(ctx, c)

Set the current Cairo source to be the color c.
"""
source(ctx::CairoContext, c::RGBColor) = Cairo.set_source_rgb(ctx, c.r, c.g, c.b)
source(ctx::CairoContext, c::RGBAColor) = Cairo.set_source_rgba(ctx, c.r, c.g, c.b, c.a)



"""
    rectangle(ctx, p, wh)

Add a rectangle to the current path. p is the upper left, wh is the width-height.
"""
Cairo.rectangle(ctx::CairoContext, p::Point, wh::Point) = Cairo.rectangle(ctx, p.x, p.y, wh.x, wh.y)

"""
    move_to(ctx, p)

Set the current point to p.
"""
Cairo.move_to(ctx, p::Point) = Cairo.move_to(ctx, p.x, p.y)


"""
    line_to(ctx, p)

Add a line to the current path from the current point to p.
"""
Cairo.line_to(ctx, p::Point) = Cairo.line_to(ctx, p.x, p.y)


"""
    arc(ctx, p, r, t1, t2)

Draw a Cairo arc of radius r, centered at p, starting at angle t1, ending angle t2
"""
Cairo.arc(ctx, p::Point, r, t1, t2) = Cairo.arc(ctx, p.x, p.y, r, t1, t2)


"""
    curve_to(ctx, p1, p2, p3)

Draw a Bezier curve from the current point to p3 with control points p1,p2.
"""
function Cairo.curve_to(ctx::CairoContext, p1::Point, p2::Point, p3::Point)
    Cairo.curve_to(ctx, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y)
end

"""
    set_linestyle(ctx, linestyle)

Set the linewidth and color of the pen for Cairo.
"""
function set_linestyle(ctx::CairoContext, ls::LineStyle)
    Cairo.set_line_width(ctx, ls.width)
    source(ctx, ls.color)
end


"""
    stroke(ctx, linestyle)

Stroke the current Cairo path with linestyle
"""
function Cairo.stroke(ctx::CairoContext, ls::LineStyle)
    set_linestyle(ctx, ls)
    Cairo.stroke(ctx)
end


"""
    colorfill(ctx, color)

Fill the current Cairo path with color.
"""
function colorfill(ctx::CairoContext, fillcolor)
    source(ctx, fillcolor)
    Cairo.fill(ctx)
end

"""
    strokefill(ctx, linestyle, fillcolor)

Stroke and fill the current cairo path.
"""
function strokefill(ctx::CairoContext, ls, fillcolor)
    set_linestyle(ctx, ls)
    Cairo.stroke_preserve(ctx)
    source(ctx, fillcolor)
    Cairo.fill(ctx)
end

"""
    textx(ctx, p, size, color, txt)

Write txt at point p, with the given font size and color.
"""
function textx(ctx::CairoContext, p::Point, fsize, color, txt)
    Cairo.select_font_face(ctx, "Sans", Cairo.FONT_SLANT_NORMAL, Cairo.FONT_WEIGHT_NORMAL)
    Cairo.set_font_size(ctx, fsize)
    Cairo.move_to(ctx, p)
    source(ctx, color)
    Cairo.show_text(ctx, txt)
end


"""
    draw(ctx; closed, linestyle, fillcolor)

Fill and/or stroke the current Cairo path.
"""
function draw(ctx::CairoContext; closed = false, linestyle = nothing,
              fillcolor = nothing, keep = false)
    if closed
        Cairo.close_path(ctx)
    end
    if closed && !isnothing(linestyle) && !isnothing(fillcolor)
        strokefill(ctx, linestyle, fillcolor)
        return
    end
    if closed && !isnothing(fillcolor)
        colorfill(ctx, fillcolor)
        return
    end
    if !isnothing(linestyle)
        stroke(ctx, linestyle)
        return
    end
    if isnothing(fillcolor) && isnothing(linestyle) && !keep
        Cairo.new_path(ctx)
    end
end

##############################################################################
# elementary

"""
    rect(ctx, p, wh; linestyle, fillcolor)

Draw a rectangle with top-left corner at p and width-height given by wh.

"""
function rect(ctx::CairoContext, p::Point, wh::Point; linestyle = nothing, fillcolor = nothing)
    rectangle(ctx, p, wh)
    draw(ctx; closed = true, linestyle, fillcolor)
end

rect(ctx::CairoContext, b::Box;  linestyle = nothing, fillcolor = nothing) = rect(ctx, Point(b.xmin, b.ymin), Point(b.xmax - b.xmin, b.ymax - b.ymin); linestyle, fillcolor)


"""
    circle(ctx, p, r; linestyle, fillcolor)

Draw a circle centered at p with radius r.
"""
function Cairo.circle(ctx::CairoContext, p::Point, r; linestyle = nothing, fillcolor = nothing)
    Cairo.new_sub_path(ctx)
    Cairo.arc(ctx, p, r, 0, 2*pi)
    draw(ctx; closed=true, linestyle, fillcolor)
end


"""
    curve(ctx, p0, p1, p2, p3; closed, linestyle, fillcolor)

Draw a cubic bezier curve with control points p0, p1, p2, p3.
"""
function curve(ctx::CairoContext, p0, p1, p2, p3;
               closed = false, linestyle = nothing, fillcolor = nothing)
    Cairo.move_to(ctx, p0)
    Cairo.curve_to(ctx, p1, p2, p3)
    draw(ctx; closed, linestyle, fillcolor)
end

#     for pos in arrowpos
#         b, bt = bezier2(pos, p0, p1, p2, p3)
#         theta = atan(bt.y, bt.x)
#         if isnothing(arrowstyle)
#             polygon(ctx, b, theta, 10, triangle(pi/8); fillcolor = linestyle.color)
#         else
#             arrowstyle(ctx, x, theta, pos)
#         end
#     end
# end


"""
    line(ctx, x; closed, linestyle, fillcolor)

Draw a line joining the points in the list of points x.
"""
function line(ctx::CairoContext, p::Array{Point};
              closed = false, linestyle = nothing, fillcolor = nothing,
              keep = false)
    Cairo.move_to(ctx, p[1])
    for i=2:length(p)
        Cairo.line_to(ctx, p[i])
    end
    draw(ctx; closed, linestyle, fillcolor, keep)
end


"""
    line(ctx, p, q; linestyle, arrowstyle, arrowpos)

Draw a line from Point p to Point q on the Cairo context ctx.
"""
function line(ctx::CairoContext, p::Point, q::Point; linestyle = nothing)
    Cairo.move_to(ctx, p)
    Cairo.line_to(ctx, q)
    draw(ctx; linestyle)
end


#     for pos in arrowpos
#         theta = atan(q.y-p.y, q.x-p.x)
#         x = interp(p, q, pos)
#         if isnothing(arrowstyle) && !isnothing(linestyle)
#             polygon(ctx, x, theta, 10, triangle(pi/8); fillcolor = linestyle.color)
#         else
#             arrowstyle(ctx, x, theta, pos)
#         end
#     end
#     if !isnothing(label)
#         x = interp(p, q, labelpos)
#         boxed_label(ctx, x, label)
#     end
# end


##############################################################################
# arrows

abstract type Arrow end

Base.@kwdef mutable struct TriangularArrow <: Arrow
    size = 10
    angle = pi/8
    fillcolor = Color(:black)
    linestyle = nothing
end

function draw(ctx, x, dir, arrow::TriangularArrow)
    theta = atan(dir.y, dir.x)
    polygon(ctx, x, theta, arrow.size, triangle(arrow.angle); fillcolor = arrow.fillcolor)
end

Arrow(args...; kw...) = TriangularArrow(args...; kw...)

##############################################################################
# paths

# TODO: this should all be higher level
# and contain coordinates
abstract type Path end

# straight path between two points
# TODO: should have "closed" attribute
Base.@kwdef mutable struct StraightPath <: Path
    arrows = ()
    nodes = ()
    linestyle = LineStyle(Color(:black), 1)
    points = nothing
end

# curved path between two points
Base.@kwdef mutable struct CurvedPath <: Path
    closed = false
    fillcolor = (0,0,1)
    theta1 = -pi/6
    theta2 = -pi/6
    curveparam = 0.3
    arrows = ()
    nodes = ()
    linestyle = LineStyle(Color(:black),1)
end

# curved path with four bezier points
Base.@kwdef mutable struct BezierPath <: Path
    closed = false
    fillcolor = Color(:blue)
    nodes = ()
    arrows = ()
    linestyle = LineStyle(Color(:black),1)
end

Path(args...; kw...) = StraightPath(args...; kw...)

function draw(ctx, p1, p2, path::StraightPath)
    line(ctx, p1, p2; linestyle = path.linestyle)
    for (alpha, node) in path.nodes
        x = interp(p1, p2, alpha)
        draw(ctx, x, node)
    end
    for (alpha, arrow) in path.arrows
        x = interp(p1, p2, alpha)
        dir = (x = p2.x-p1.x, y = p2.y-p1.y)
        draw(ctx, x, dir, arrow)
    end
end

function draw(ctx, p1, p2, path::CurvedPath)
    bezier_points = curve_from_endpoints(p1, p2, path.theta1, path.theta2, path.curveparam)
    curve(ctx, bezier_points...;
          closed = path.closed, linestyle = path.linestyle,
          fillcolor = path.fillcolor)
    for (alpha, node) in path.nodes
        x = bezier_point(alpha, bezier_points...)
        draw(ctx, x, node)
    end
   for (alpha, arrow) in path.arrows
        x, dir = bezier2(alpha, bezier_points...)
        draw(ctx, x, dir, arrow)
    end
end

function draw(ctx, p0, p1, p2, p3, path::BezierPath)
    curve(ctx, p0, p1, p2, p3;
          closed = path.closed, linestyle = path.linestyle,
          fillcolor = path.fillcolor)
    for (alpha, node) in path.nodes
        x = bezier_point(alpha, bezier_points...)
        draw(ctx, x, node)
    end
    for (alpha, arrow) in path.arrows
        x, dir = bezier2(pos, p0, p1, p2, p3)
        draw(ctx, x, dir, arrow)
    end
end



##############################################################################
# nodes
abstract type Node end

Base.@kwdef mutable struct CircularNode <: Node
    text = ""
    fontsize = 8
    textcolor = Color(:white)
    fillcolor = colormap(3)
    linestyle = LineStyle(Color(:black), 1)
    radius = 9
    center = nothing
    unscaled = true
end

Base.@kwdef mutable struct RectangularNode <: Node
    text = ""
    fontsize = 8
    textcolor = Color(:black)
    fillcolor = Color(:white)  # can be nothing
    linestyle = nothing  # can be nothing
    center = nothing
    widthheight = nothing
end


Node(args...; kw...) = CircularNode(args...; kw...)

function draw(ctx::CairoContext, p::Point, node::CircularNode)
    circle(ctx, p, node.radius;
           linestyle = node.linestyle, fillcolor = node.fillcolor)
    text(ctx, p, node.fontsize, node.textcolor, node.text;
         horizontal = "center", vertical = "center")
end

function draw(ctx::CairoContext, p, node::RectangularNode)
    left, top, txtwidth, txtheight = get_text_info(ctx, node.fontsize, node.text)
    if isnothing(node.widthheight)
        w = txtwidth + 6
        h = txtheight + 6
    else
        w = node.widthheight.x
        h = node.widthheight.y
    end
    T = [w 0 ; 0 h]
    box = [T*a for a in Point[(1,0), (1,1), (0,1), (0,0)]]
    polygon(ctx, p, 0, 1, box; center = true, node.linestyle, node.fillcolor)
    text(ctx, p, node.fontsize, node.textcolor, node.text;
         horizontal = "center", vertical = "center")
end

draw(ctx::CairoContext, node::Node) = draw(ctx, node.center, node)


# ##############################################################################
# # curves

# """
#     curve_between(ctx, p1, p2, theta1, theta2, r; closed, linestyle, fillcolor, arrowstyle, arrowpos)
    
# Draw a curve from p1 to p2, with departure angles theta1 and theta2, and parameter r.

# The parameter measures how curved the lines are. Note this curve is
# not invariant under coordinate changes, so be careful when using
# in axis coordinates.
# """
# function curve_between(ctx::CairoContext, p1::Point, p2::Point, theta1, theta2, r;
#                        label = nothing, labelpos = 0,
#                        closed = false, linestyle = nothing, fillcolor = nothing,
#                        arrowstyle = nothing, arrowpos = ())
#     bezier_points = curve_from_endpoints(p1, p2, theta1, theta2, r)
#     curve(ctx, bezier_points...; closed, linestyle, fillcolor, arrowstyle, arrowpos)
#     if !isnothing(label)
#         x = bezier_point(labelpos, bezier_points...)
#         boxed_label(ctx, x, label)
#     end
# end

##############################################################################
# nothing to do with Cairo really


"""
    curve_from_endpoints(p1, p2, theta1, theta2, r)

Construct bezier control points for a curve from p1 to p2 with departure angles and parameter.
"""
function curve_from_endpoints(p1::Point, p2::Point, theta1, theta2, r)
    u = (p2-p1)/norm(p2-p1)
    T = [u.x -u.y ; u.y  u.x]
    r0 = r * norm(p2-p1)
    c0 = p1
    c1 = p1 + T*polar(r0, theta1)
    c2 = p2 - T*polar(r0, -theta2)
    c3 = p2
    return c0, c1, c2, c3
end

"""
    split_bezier(a::Point, b::Point, c::Point, d::Point, t)

Returns two 4-tuples of Points (a, e, h, k), (k, j, g, d)
such that (a,e,h,k) defines a Bezier curve for the [0,t] segment
of the supplied curve, and (k, j, g, d) the [t,1] segment.

"""
function split_bezier(a::Point, b::Point, c::Point, d::Point, t)
    e = interp(a, b, t)
    f = interp(b, c, t)
    g = interp(c, d, t)
    h = interp(e, f, t)
    j = interp(f, g, t)
    k = interp(h, j, t)
    return (a, e, h, k), (k, j, g, d)
end


"""
     bezier_point(t, p0, p1, p2, p3)

Return the point at position t along the bezier curve with control points p0,p1,p2,p3
"""
function bezier_point(t, p0, p1, p2, p3)
    b = (1-t)^3 * p0 + 3*(1-t)^2*t*p1 + 3*(1-t)*t^2*p2 + t^3 * p3
    return b
end

"""
     bezier_tangent(t, p0, p1, p2, p3)

Return the tangent at position t along the bezier curve with control points p0,p1,p2,p3
"""
function bezier_tangent(t, p0, p1, p2, p3)
    bt = 3*(1-t)^2 *(p1-p0) + 6*(1-t)*t*(p2-p1) + 3*t*t*(p3-p2)
end

"""
     bezier2(t, p0, p1, p2, p3)

Return the position and tangent at position t along the bezier curve with control points p0,p1,p2,p3
"""
bezier2(args...) = bezier_point(args...), bezier_tangent(args...)




##############################################################################
# gradient

function make_gradient()
    c1 = [a for a in colormap(1)]
    c2 = [a for a in colormap(3)]
    interp(x,y,t) = (1-t)*x + t*y
    ext(t) = 2*abs(t-0.5)
    nc(weight) = interp([1,1,1],   interp(c2, c1, weight), 0.25 + 0.75*ext(weight))
    return nc
end

###############################################################
# images


mutable struct Pik
    # img is a matrix with #rows = width, #cols = height
    img::Matrix{UInt32}
    width
    height
end

Box(pik::Pik) = Box(0, pik.width, 0, pik.height)


Base.copy(pik::Pik) = Pik(copy(pik.img), pik.width, pik.height)


function Pik(img::Matrix)
    height, width = size(img)
    return Pik(convert(Matrix{UInt32}, img), width, height)
end

function Pik(width, height)
    img = Matrix{UInt32}(undef, width, height)
    return Pik(img, width, height)
end

function Base.getproperty(p::Pik, s::Symbol)
    if s == :size
        return Point(getfield(p, :width), getfield(p, :height))
    else
        return getfield(p, s)
    end
end

# draws an image with top,left at p, or centered at p
# scaled to given width and height, if given
function drawimage(ctx, pik::Pik, p; width = nothing, height = nothing, centered = false)
    if width == nothing
        w = pik.width
    else
        w = width
    end
    if height == nothing
        h = pik.height
    else
        h = height
    end
    drawimage_x(ctx, pik::Pik, p.x, p.y, w, h; centered = centered)
end

drawimage(ctx, pik::Pik, b::Box) = drawimage(ctx, pik, Point(b.xmin, b.ymin);
                                             width = b.xmax - b.xmin,
                                             height = b.ymax - b.ymin)

function drawimage_to_mask(ctx, pik::Pik, pts, sx, sy; format = Cairo.FORMAT_ARGB32,
                           operator = Cairo.OPERATOR_OVER)

    surface = Cairo.CairoSurface(pik; format)
    line(ctx, pts; closed=true, keep=true)
    Cairo.save(ctx)
    Cairo.scale(ctx, 1/sx, 1/sy)
    Cairo.set_source_surface(ctx, surface, 0, 0)
    Cairo.set_operator(ctx, operator)
    Cairo.fill(ctx)
    Cairo.restore(ctx)
end


function drawimage_x(ctx, pik::Pik, x, y, width, height; centered = centered)
    if centered
        x = x - width / 2
        y = y - height / 2
    end
    surface = Cairo.CairoSurface(pik)
    sx = pik.width/width  
    sy = pik.height/height
    Cairo.save(ctx)
    Cairo.scale(ctx, 1/sx, 1/sy)
    Cairo.set_source_surface(ctx, surface, sx*x, sy*y)
    Cairo.pattern_set_filter(Cairo.get_source(ctx), Cairo.FILTER_NEAREST)
    Cairo.scale(ctx, sx, sy)
    Cairo.rectangle(ctx, x, y, width, height)
    Cairo.fill(ctx)
    Cairo.restore(ctx)
end





##############################################################################
# surfaces

#
# One use of this is for converting an image to a surface,
# which can then be written to a context.
# Another use is for creating a surface in memory onto
# which one can write
#
# possible formats are Cairo.FORMAT_RGB24 or  Cairo.FORMAT_ARGB32
#
function Cairo.CairoSurface(pik::Pik; format = Cairo.FORMAT_RGB24)
    w = pik.width
    h = pik.height
    stride = Cairo.format_stride_for_width(format, w)
    ptr = ccall((:cairo_image_surface_create_for_data, Cairo.libcairo),
                Ptr{Nothing},
                (Ptr{Nothing}, Int32, Int32, Int32, Int32),
                pik.img, format, w, h, stride)
    return Cairo.CairoSurface(ptr, w, h, pik.img)
end

function cairo_memory_surface_ctx(width, height)
    pik = Pik(width, height)
    surface = CairoSurface(pik, format = Cairo.FORMAT_ARGB32)
    ctx = Cairo.CairoContext(surface)
    return pik, surface, ctx
end


end
