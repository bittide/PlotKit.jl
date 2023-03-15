

function setclipbox(ctx::CairoContext, ax::AxisMap, box)
    @plotfns ax
    xmin, xmax, ymin, ymax = box.xmin, box.xmax, box.ymin, box.ymax
    Cairo.rectangle(ctx, rfx(xmin), rfy(ymin), rfx(xmax)-rfx(xmin),
                    rfy(ymax)-rfy(ymin))
    Cairo.clip(ctx)
    Cairo.new_path(ctx)
end


##############################################################################
# from tools

# TODO: circle radius shouldbe in axis coords too? What about non-uniform x,y scaling

# does this:
#
# CairoTools.line(ax::AxisMap, ctx, p, args...)
#    = CairoTools.line(ctx, ax(p), args...)
#
for f in (:line, :circle, :text)
    @eval function CairoTools.$f(ax::AxisMap, ctx::CairoContext, p, args...; kwargs...)
        CairoTools.$f(ctx::CairoContext, ax(p), args...; kwargs...)
    end
end


# for functions with two arguments of type Point
for f in (:line,)
    @eval function CairoTools.$f(ax::AxisMap, ctx::CairoContext, p::Point, q::Point, args...; kwargs...)
        CairoTools.$f(ctx::CairoContext, ax(p), ax(q), args...; kwargs...)
    end
end


# for functions with four arguments of type Point
for f in (:curve,)
    @eval function CairoTools.$f(ax::AxisMap, ctx::CairoContext, p, q, r, s, args...; kwargs...)
        CairoTools.$f(ctx::CairoContext,
                      ax(p), ax(q), ax(r), ax(s), args...; kwargs...)
    end
end

# some similar functions (distinguished by type dispatch not number of args)
CairoTools.draw(ax::AxisMap, ctx, p, obj::Node) = CairoTools.draw(ctx, ax(p), obj)
CairoTools.draw(ax::AxisMap, ctx, p, q, obj::Path) = CairoTools.draw(ctx, ax(p), ax(q), obj)




##############################################################################
# higher level drawing

# TODO: remove the no-axis version of Nodes, Paths, Arrows ?
function CairoTools.draw(ax::AxisMap, ctx::CairoContext, p, node::RectangularNode)
    left, top, txtwidth, txtheight = get_text_info(ctx, node.fontsize, node.text)
    if isnothing(node.widthheight)
        w = txtwidth + 6
        h = txtheight + 6
    else
        w = node.widthheight.x
        h = node.widthheight.y
    end
    box = [p + a for a in Point[(w/2,-h/2), (w/2,h/2), (-w/2,h/2), (-w/2,-h/2)]]
    line(ax, ctx, box; closed=true, node.linestyle, node.fillcolor)
    text(ax, ctx, p, node.fontsize, node.textcolor, node.text;
         horizontal = "center", vertical = "center")
end

CairoTools.draw(ax::AxisMap, ctx, obj::RectangularNode) = CairoTools.draw(ax, ctx, obj.center, obj)

function CairoTools.draw(ax::AxisMap, ctx::CairoContext, p::Point, node::CircularNode)
    circle(ax, ctx, p, ax.fx(node.radius) - ax.fx(0);
           linestyle = node.linestyle, fillcolor = node.fillcolor)
    text(ctx, p, node.fontsize, node.textcolor, node.text;
         horizontal = "center", vertical = "center")
end

CairoTools.draw(ax::AxisMap, ctx, obj::CircularNode) = CairoTools.draw(ax, ctx, obj.center, obj)

function lineinterp(points, alpha)
    if alpha == 0
        return points[1]
    elseif alpha == 1
        return points[end]
    end
    println("ERROR: cannot interpolate polyline")
end

function lineinterpdirection(points, alpha)
    if alpha == 0
        p1 = points[1]
        p2 = points[2]
        # TODO why is this a Tuple instead of a Point?
        return (x = p2.x-p1.x, y = p2.y-p1.y)
    elseif alpha == 1
        p1 = points[end-1]
        p2 = points[end]
        return (x = p2.x-p1.x, y = p2.y-p1.y)
    end
    println("ERROR: cannot interpolate polyline")
end

function CairoTools.draw(ax::AxisMap, ctx, path::Path)
    line(ax, ctx, path.points, ; linestyle = path.linestyle)
        for (alpha, node) in path.nodes
        x = lineinterp(path.points, alpha)
        draw(ctx, ax(x), node)
    end
    for (alpha, arrow) in path.arrows
        x = lineinterp(path.points, alpha)
        dir = lineinterpdirection(path.points, alpha)
        if ax.fy(1) < ax.fy(0)
            dir2 = (x = dir.x, y = -dir.y)
        else
            dir2 = dir
        end
        draw(ctx, ax(x), dir2, arrow)
    end

end
