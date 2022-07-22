


getentry(a, i) = a
getentry(a::Array, i) = a[i]

Base.@kwdef mutable struct Graph
    nodes = Node()
    paths = Path()
end


function drawgraph(ax, ctx, links, x, st)
    for (j, (src,dst)) in enumerate(links)
        path = getentry(st.paths, j)
        draw(ax, ctx, x[src], x[dst], path)
    end
    for i=1:length(x)
        node = getentry(st.nodes, i)
        draw(ax, ctx, x[i], node)
    end
end

function drawgraph(links, x; kwargs...)
    graph = Graph()
    setoptions!(graph, "graph_", kwargs...)

    defaults = Dict(
        :axisstyle_drawaxisbackground => false,
        :axisstyle_drawxlabels => false,
        :axisstyle_drawylabels => false,
        :widthfromdata => 60,
        :heightfromdata => 60,
        :lmargin => 0,
        :rmargin => 0,
        :tmargin => 0,
        :bmargin => 0,
        :xdatamargin => 0.25,
        :ydatamargin => 0.25
    )

    axis = Axis(x; merge(defaults, kwargs)...)
    d = Drawable(axis)
    over(d; clip=false) do ctx
        rect(ctx, Point(0,0), Point(d.width, d.height);
             fillcolor = d.axis.windowbackgroundcolor)
        drawgraph(d.axis.ax, ctx, links, x, graph)
    end
    return d
end


    
# w is node shade, between 0 and 1
#shaded_graph(links, x, w; kw...) = drawgraph(links, x; graph_nodecolor = make_gradient().(w), kw...)
