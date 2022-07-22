


"""
    lineplot(data; kwargs...)

Plot one or more sequences of points as a line, possibly with markers.

Creates a new Drawable and Axis.
The data is a list of Point objects, or an array of such lists.
The keyword arguments are those supported by the Axis function
and the LinePlot struct.
"""
function drawplot(data; clip=true,  kwargs...)
    axis = Axis(data; kwargs...)
    d = Drawable(axis)
    over(d; clip) do ctx
        drawplot(axis.ax, ctx, data;  kwargs...)
    end
    return d
end

#
# should call this with over, if you want clipping
#
function drawplot(ax::AxisMap, ctx::CairoContext, data; linestyle = nothing,
                  markerfn = nothing, kwargs...)
    for (i,j,x) in DataIndices(data)
        ls = ifnotnothing(linestyle, LineStyle(colormap(i,j) , 1))
        line(ax, ctx, x; linestyle = ls)
        if !isnothing(markerfn)
            for p in x
                markerfn(ax, ctx, p, i, j)
            end
        end
    end
   
end

