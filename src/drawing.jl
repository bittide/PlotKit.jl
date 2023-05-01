

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


function CairoTools.drawimage(ax::AxisMap, ctx, pik::Pik, b::Box)
    x1 = ax.fx(b.xmin)
    x2 = ax.fx(b.xmax)
    y1 = ax.fy(b.ymin)
    y2 = ax.fy(b.ymax)
    b2 = Box(min(x1, x2), max(x1, x2), min(y1, y2), max(y1,y2))
    drawimage(ctx, pik, b2)
end
