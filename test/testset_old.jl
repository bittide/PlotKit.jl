
# module TestSet

# using Test

# ##############################################################################
# #include("/home/sanjaylall/links/gitonborg/luna/src/packages/PlotKit/src/PlotKit.jl")
# #using .PlotKit
# #plotpath(x) = joinpath(ENV["HOME"], "plots/", x)

# ##############################################################################
# using PlotKit
# plotpath(x) = joinpath(tempdir(), x)

# ##############################################################################


# const pk = PlotKit



pzip(a,b) = Point.(zip(a,b))
plot(x,y; kw...) = drawplot(pzip(x,y); kw...)
plot(x; kw...) = drawplot(x; kw...)
plot(ax, ctx, data; kw...) = drawplot(ax, ctx, data; kw...)

getoptions(;kw...) = kw

function main()
    @testset "plotkit basic plots" begin
        @test main1()
        @test main2()
        @test main3()
        @test main4()
        @test main5()
        @test main6()
        @test main7()
        @test main8()
        @test main9()
        @test main10()
        @test main11()
        @test main12()
        @test main13()
        @test main14()
        @test main15()
        @test main16()
        @test main17()
        @test main18()
        @test main19()
        @test main20()
        @test main21()
        @test main22()
        @test main23()
        @test main24()
        @test main25()
        @test main26()
        @test main27()
        @test main28()
        @test main29()
        @test main32()
        @test main34()
        @test main35()
        @test main37()
    end
end
    
# # just the basic plot
# # now in axisbuilder
# function main1()
#     x = -0.1:0.1:2.85
#     y = x.*x
#     data = pzip(x,y)
#     d = plot(data)
#     over(d) do ctx
#         for p in data
#             circle(d.axis.ax, ctx, p, 2; fillcolor = 0.5*Color(:white))
#         end
#     end
#     qsave(d, "basic1.pdf")
# end


# 
# # basic two plots on the same graph
# # now in axisbuilder
# function main2()
#     x1 = -0.1:0.1:1.8
#     y1 = x1.*x1
#     x2 = -0.2:0.05:1.4
#     y2 = x2.*(x2 .- 0.6) .* (x2 .- 1)
#     fig = plot( [pzip(x1, y1), pzip(x2, y2)] )
#     qsave(fig, "basic2.pdf")
# end


# # doing it yourself
# # in testset_drawaxis
# function main3()
#     x = 0:0.1:10
#     y = x.*x/10
#     xt = best_ticks(minimum(x), maximum(x), 10)
#     yt = best_ticks(minimum(y), maximum(y), 10)
#     xl = best_labels(xt)
#     yl = best_labels(yt)
#     ticks = Ticks(xt, xl, yt, yl)
#     box = Box(minimum(xt), maximum(xt), minimum(yt), maximum(yt))
#     width = 800
#     height = 600
#     margins = (80, 80, 80, 80)
#     windowbackgroundcolor = Color(:white)
#     as = AxisStyle()
#     ax = pk.AxisMap(width, height, margins, box, false, true)
#     function fn(ctx)
#         rect(ctx, Point(0,0), Point(width, height); fillcolor =  windowbackgroundcolor)
#         drawaxis(ctx, ax, ticks, box, as)
#         setclipbox(ctx, ax, box)
#         line(ax, ctx, Point.(zip(x, y)); linestyle=LineStyle(Color(:blue), 1))
#     end
#     d = pk.Drawable(width, height)
#     over(fn, d) 
#     qsave(d, "basic3.pdf")
# end




# # two plots, one above the other
# # # now in testset_axisbuilder
# function main4()
#     x1 = -0.1:0.1:1.3
#     y1 = x1.*x1
#     d1 = plot(x1, y1; height=400)
#
#     x2 = -0.2:0.05:1.4
#     y2 = x2.*(x2 .- 0.6) .* (x2 .- 1)
#     d2 = plot(x2, y2; height=320, tmargin=0)
#
#     qsave(vbox(d1, d2), "basic4.pdf")
# end


# a simple animated plot
# in PlotKitGL/testset
# function main5()
#     x = collect(0:0.01:10)
#     pf(t) = pzip(x, sin.(x *(1+t)))
#     ff(t) = plot(pf(t); ymin =-2, ymax = 2,
#                  windowbackgroundcolor = Color(1-exp(-t),0.8,0.8))
#     anim = Anim(ff)
#     anim.tmax = 5
#     qsee(anim)
# end


# # a simple animated plot, saving a frame
# # in PlotKitGL/testset
# function main6()
#     x = collect(0:0.01:10)
#     pf(t) = pzip(x, sin.(x *(1+t)))
#     ff(t) = plot(pf(t); ymin =-2, ymax = 2,
#                      windowbackgroundcolor=Color(1-exp(-t),0.8,0.8))
#     anim = Anim(ff)
#     qsave(frame(anim, 1.2), "basic6.png")
#     anim.tmax = 1
#     qsee(anim)
# end

    
# # two animated plots
# # needs both PlotKitGL and PlotKitAxes, so in PlotKit/test
# function main7()
#     x = collect(0:0.01:10)
#     p1(t) = pzip(x, sin.(x *(1+t)))
#     f1(t) = plot(p1(t); ymin =-2, ymax = 2,
#                      windowbackgroundcolor=Color(1-exp(-t),0.8,0.8))
#     p2(t) = pzip(x, exp(-t)*sin.(x *(1+t)))
#     f2(t) = plot(p2(t); ymin =-2, ymax = 2)

#     f(t) = hbox(f1(t),f2(t))
#     anim = Anim(f)
#     anim.tmax = 1
#     qsee(anim)
# end

# # test graph plot
# # now in plotkitdiagrams
# function main8()
#     links = [[1, 2], [1, 4], [2, 3], [2, 5], [3, 6], [4, 5], [5, 6]]
#     x = Point[(0, 0), (1, 0), (2, 0), (0, 1), (1, 1), (2, 1)]
#     f = drawgraph(links, x; graph_nodes = Node(;fillcolor=Color(:red)))
#     qsave(f, "basic8.pdf")
# end

# overlays on basic plot
function main9()
    x = -0.1:0.1:1.3
    y = x.*x
    d = plot(x,y)
    over(d; clip=false) do ctx
        line(d.axis.ax, ctx, Point(0, 0), Point(1, 1);
             linestyle = LineStyle( Color(:black), 2))
        line(ctx, Point(0, 0), Point(400, 300);
             linestyle = LineStyle( Color(:blue), 2))
    end
    qsave(d, "basic9.pdf")
end

# many subplots
function main10()
    fns = [sin, cos, exp, tan, sec, sinc]
    x = collect(-1:0.01:1)
    fs = [ plot(x, a.(x)) for a in fns ]
    qsave(hvbox(stack(fs, 3)), "basic10.pdf")
end

# using the animator to show a fixed plot
function main11()
    x = -0.1:0.1:1.3
    y = x.*x
    qsee(plot(x,y); tmax = 1)
end

# set marker styles
function main12()
    x = -0.3:0.1:1.3
    y = x.*x
    data = pzip(x,y)
    markerfn = (ax, ctx, p, args...) -> circle(ax, ctx, p, 10;
                                               linestyle=LineStyle(Color(:red),2),
                                               fillcolor = Color(:cyan))
    d = plot(data; ymin=-0.2, markerfn)
    qsee(d; tmax = 1)
end

# partial diy
function main13()
    p = Point[(x, x.*x) for x = 1:0.5:10]
    axis = Axis(p)
    d = Drawable(axis)
    over(d) do ctx
        line(d.axis.ax, ctx, p; linestyle=LineStyle(Color(:black),1))
        for x in p
            circle(d.axis.ax, ctx, x, 3; fillcolor = Color(0.9,0.4,0.4))
        end
    end
    qsave(d, "basic13.pdf")
end



# change the axis style
function main14()
    data = Point[(x, x*x) for x in -0.1:0.01:1.85]
    opts = getoptions(; axisstyle_edgelinestyle = LineStyle(0.5 * Color(:white), 2),
                      axisstyle_gridlinestyle = LineStyle(Color(0.5,0.5,0.7), 1),
                      axisstyle_backgroundcolor = Color(:white),
                      axisstyle_drawbox = true,
                      windowbackgroundcolor = 0.9 * Color(:white)
                      )
    d = plot(data; opts...)
    over(d) do ctx
        line(d.axis.ax, ctx, Point(1,1), Point(4, 3);
             linestyle = LineStyle(Color(:green),2))
    end
    qsave(d, "basic14.pdf")
end

# draw on existing plot
function main15()
    data = Point[(x, x*x) for x in -0.1:0.01:1.85]
    d = plot(data)
    over(d) do ctx
        line(d.axis.ax, ctx, Point(1,1), Point(4, 3);
             linestyle = LineStyle(Color(:green), 2))
    end
    qsave(d, "basic15.pdf")
end


# draw using cairo
function main16()
    d = Drawable(800, 600) do ctx
        rect(ctx, Point(0,0), Point(800, 600); fillcolor = Color(:red))
        line(ctx, Point(10, 20), Point(800, 450);
             linestyle = LineStyle(Color(:blue), 5))
        line(ctx, Point(10, 500), Point(600, 50);
             linestyle = LineStyle(Color(:green), 5))
    end
    qsave(d, "basic16.png")
end


# check limits
function main17()
    x1 = -2:0.1:2
    y1 = x1
    x2 = -0.5:0.1:0.7
    y2 = x2.*x2 .-3
    x2 = x2 
    d = plot([pzip(x1,y1), pzip(x2,y2)])
    qsave(d, "basic17.pdf")
end

# directed graph 
function main18()
    links = [[1, 2], [1, 4], [2, 3], [2, 5], [3, 6], [4, 5], [5, 6]]
    x = Point[(0, -2), (1, 0), (2, -2), (0, 1), (1, 1), (2, 1)]
    arrows=((0.5, TriangularArrow()),)
    f = drawgraph(links, x; graph_paths = Path(; arrows))
    qsave(f, "basic18.pdf")
end


function main19()
    d = Drawable(Axis(; xmin = -10, xmax = 20, ymin=-20, ymax=20))
    over(d) do ctx
        circle(d.axis.ax, ctx, Point(0,0), 50;
               linestyle = LineStyle(Color(:black), 4))
    end
    qsave(d, "basic19.pdf")
end

function main20()
    d= Drawable(800, 600) do ctx
        rect(ctx, Point(300,20), Point(200, 100);
             fillcolor = Color(1,0.8,0.8))
        text(ctx, Point(300,120), 50, Color(:black),
             "Hellogello"; horizontal = "left", vertical="bottom")
    end
    qsave(d, "basic20.pdf")
end


# curved directed graph
function main21()
    links = [[1, 2], [2,1], [1, 4], [2, 3], [2, 5], [5,2], [3, 2], [4, 5], [5, 6]]
    x = Point[(0, -2), (1, -0.5), (2, -2), (0, 1), (1, 1), (2, 1)]
    arrows=((0.5, TriangularArrow()),)
    f = drawgraph(links, x; lmargin=20,
                  graph_paths = CurvedPath(; arrows))
    qsave(f, "basic21.pdf")
end

# NEEDS to be fixed, slow and bad
# test graph layout
function main22()
    links = [[1, 2], [1, 4], [2, 3], [2, 5], [3, 6], [4, 5], [5, 6]]
    x = graphlayout(links, 6)
    f = drawgraph(links, x)
    qsave(f, "basic22.pdf")
end


# checking out limits
function main23()
    x = collect(-2:0.01:2)
    y = x.*x
    f1 = plot(x, y)
    f2 = plot(x, y; xmin = -1, xmax = 1.5, ymax=5)
    f3 = plot(x, y; xmin = -1, xmax = 6.5)
    f4 = plot(x, y; ymin = -1, ymax = 10)
    qsave(hvbox([f1 f2; f3 f4]), "basic23.pdf")
end

# plotting a bunch of data, with missings
function main24()
    x = collect(-2:0.01:2)
    y1 = x.*x
    y2 = x.*x.*x .- 1
    y3 = sin.(x)

    A = Array{Any}(missing, 2,2)
    A[1,1] = pzip(x,y1)
    A[2,1] = pzip(x,y2)
    A[2,2] = pzip(x,y3) 
    f = plot(A)
    qsave(f, "basic24.pdf")
end


# checking out limits more
function main25()
    x = collect(-1:0.01:2)
    y = x.*x
    f1 = plot(x, y)
    f2 = plot(x, y; xmax = 2.7) 
    f3 = plot(x, y; tickbox_xmax = 2.7, axisbox_xmax = 2.7)

    f4 = plot(x, y; tickbox_xmax = 1.3)
    f5 = plot(x, y; axisbox_xmax = 1.3)
    f6 = plot(x, y; axisbox_xmax = 1.3, tickbox_xmax = 1.3)
    qsave(hvbox([f1 f2 f3; f4 f5 f6]), "basic25.pdf")
end

# beziers
function main26()
    d = Drawable(800, 600) do ctx
        rect(ctx, Point(0,0), Point(800, 600); fillcolor = Color(:white))
        bps = curve_from_endpoints(Point(100,100), Point(600,200), pi/6, pi/6, 0.3)
        curve(ctx, bps...; linestyle = LineStyle( Color(:black), 2))

        for i=0:0.1:0.5
            p = bezier_point(i, bps...)
            circle(ctx, p, 10;fillcolor = Color(:red))
        end
    end
    qsave(d, "basic26.pdf")
end

    
# beziers
function main27()
    d = Drawable(Axis(; xmin=0, xmax = 29, ymin = 0, ymax = 3,
                 yoriginatbottom = true, axisequal = false))
    over(d) do ctx
        p = Point(1,1)
        q = Point(6,2)
        th1 = pi/6
        th2 = pi/6
        ax = d.axis.ax

        # bad choice, angles wrong in axis space
        bps = curve_from_endpoints(p, q, th1, th2, 0.3)
        curve(d.axis.ax, ctx, bps...; linestyle = LineStyle( Color(:black), 4))
        a = bezier_point(0.3, bps...)
        circle(d.axis.ax, ctx, a, 10;fillcolor = Color(:red))

        # good choice, angles correct in pixel space
        bps = curve_from_endpoints(ax(p), ax(q), th1, th2, 0.3)
        curve(ctx, bps...; linestyle = LineStyle(Color(:cyan), 1))
        a = bezier_point(0.3, bps...)
        circle(ctx, a, 5;fillcolor = Color(:green))

        bps1 = curve_from_endpoints(ax(p), ax(q), th1, th2, 0.3)
        #println.("cfe composed with ax = ", bps1)

        bps2 = ax.(curve_from_endpoints(p, q, th1, th2, 0.3))
        #println.("ax composed with cfe = ", bps2)
        
    end
    qsave(d, "basic27.pdf")
end



# plotting sequentially
function main28()
    x = collect(-2:0.01:2)
    y1 = x.*x.*x .- 1
    y2 = x.*x

    d = plot(x, y1)
    over(d) do ctx
        plot(d.axis.ax, ctx, pzip(x, y2))
        plot(d.axis.ax, ctx, pzip(x, y2.-1); linestyle=LineStyle(Color(:blue),3))
    end
    qsave(d, "basic28.pdf")
end


# many colors
function main29()
    x = collect(-1:0.01:1)
    fns = [sin, cos, exp, tan, sec, sinc]
    fs = [ pzip(x, a.(x)) for a in fns ]
    qsave(plot(fs), "basic29.pdf")
end

# doing it yourself
function main30()
    x = 0:0.1:10
    y = x.*x/10

    desired_range = Box(xmin = 0, xmax = 10, ymin = 0, ymax = 30)
    ticks = Ticks(desired_range, 10, 10)
    range = get_tick_extents(ticks)
    width = 800
    height = 600
    margins = (80, 80, 80, 80)
    windowbackgroundcolor = Color(:white)
    as = AxisStyle()
    ax = pk.AxisMap(width, height, margins, range, false, true)
    function fn(ctx)
        rect(ctx, Point(0,0), Point(width, height); fillcolor =  windowbackgroundcolor)
        drawaxis(ctx, ax, ticks, range, as)
        setclipbox(ctx, ax, range)
        line(ax, ctx, Point.(zip(x, y)); linestyle=LineStyle(Color(:black), 1))
    end
    d = pk.Drawable(width, height)
    over(fn, d) 
    qsave(d, "basic30.pdf")
end

# directed graph with labels
function main31()
    links = [[1, 2], [1, 4], [2, 3], [2, 5], [3, 6], [4, 5], [5, 6]]
    x = Point[(0, -2), (1, 0), (2, -2), (0, 1), (1, 1), (2, 1)]
    n = length(x)
    m = length(links)
  
    graph_nodes = [Node(; text=string(i), fillcolor = Color(0,0,0.6)) for i=1:n]

    arrows = ((0.8, TriangularArrow()),)
    node(i) = (0.5, Node(; fillcolor = Color(:white),
                         textcolor = Color(:black),
                         linestyle = nothing,
                         text=string(i)))
    
    graph_paths = [Path(; arrows, nodes = (node(i),)) for i=1:m]

    f = drawgraph(links, x; graph_nodes, graph_paths)
    qsave(f, "basic31.pdf")
end
#
# fully sequential
#
function main32()
    width = 1200
    height = 600
    fname = plotpath("basic32.pdf")
    
    x = -0.1:0.01:1.85
    y = x.*x
    data = pzip(x,y)

    surface, ctx = makesurface(width, height, fname)
    axis = Axis(data; width, height)
    drawaxis(ctx, axis)
    drawplot(axis.ax, ctx, data)
    qclosesurface(surface, fname)
end

function main34()
    axis = Axis(; xmin=-2, xmax=15, ymin=-2, ymax=20)
    r = Drawable(axis)
    over(r) do ctx
        x = 1
        for i = 1:10
            circle(r.axis.ax, ctx, Point(x, 5), 10; fillcolor = Color(:green))
            x += 1
        end
        for i = 1:10
            circle(r.axis.ax, ctx, Point(i, 2), 10; fillcolor = Color(:red))
        end
    end
    qsave(r, "basic34.pdf")
end

function main35()
    axis = Axis(; xmin=-2, xmax=15, ymin=-2, ymax=20)
    d = Drawable(axis)
    x = 1
    for i = 1:10
        over(d) do ctx
            circle(d.axis.ax, ctx, Point(x, 5), 10; fillcolor = Color(:green))
        end
        x += 1
    end
    for i = 1:10
        over(d) do ctx
            circle(d.axis.ax, ctx, Point(i, 2), 10; fillcolor = Color(:red))
        end
    end
    qsave(d, "basic35.pdf")
end



# offset two plots
function main37()
    x1 = -0.1:0.1:1.3
    y1 = x1.*x1
    d1 = plot(x1, y1)

    x2 = -0.2:0.05:1.4
    y2 = x2.*(x2 .- 0.6) .* (x2 .- 1)
    d2 = plot(x2, y2)

    d = pk.offset(d1, d2, 400, 200)
    qsave(d, "basic37.pdf")
end


    
##############################################################################


    
#end
