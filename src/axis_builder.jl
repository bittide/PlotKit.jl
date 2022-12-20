
Base.@kwdef mutable struct AxisStyle
    drawbox = false
    edgelinestyle = LineStyle((0,0,0),2)
    drawaxisbackground = true
    xtickverticaloffset = 16
    ytickhorizontaloffset = -8
    backgroundcolor = (0.917, 0.917, 0.949)
    gridlinestyle = LineStyle((1,1,1), 1)
    fontsize = 13
    fontcolor = (0,0,0)
    drawxlabels = true
    drawylabels = true
    drawaxis = true
    drawvgridlines = true
    drawhgridlines = true
    title = ""
end

mutable struct Axis
    width            # in pixels, including margins
    height           # in pixels, including margins
    ax::AxisMap      # provides function mapping data coords to pixels
    box::Box         # extents of the axis in data coordinates
    ticks::Ticks
    as::AxisStyle
    yoriginatbottom
    windowbackgroundcolor
    drawbackground   # bool
end

Base.@kwdef mutable struct AxisOptions
    xmin = -Inf
    xmax = Inf
    ymin = -Inf
    ymax = Inf
    xdatamargin = 0
    ydatamargin = 0 
    widthfromdata = 0 
    heightfromdata = 0
    width = 800
    height = 600
    lmargin = 80
    rmargin = 80
    tmargin = 80
    bmargin = 80
    xidealnumlabels = 10
    yidealnumlabels = 10
    yoriginatbottom = true
    axisequal = false
    windowbackgroundcolor = (1,1,1)
    drawbackground = true
    drawaxis = true
    ticks = Ticks()
    axisstyle = AxisStyle()
    tickbox = Box()
    axisbox = Box()
end


##############################################################################

function set_window_size_from_data(width, height, b::Box,
                                   (lmargin, rmargin, tmargin, bmargin),
                                   widthfromdata, heightfromdata)
    if widthfromdata != 0
        width = (b.xmax - b.xmin) * widthfromdata + lmargin + rmargin
    end
    if heightfromdata != 0
        height = (b.ymax - b.ymin) * heightfromdata + tmargin + bmargin
    end
    return width, height
end

  
# used when you don't have any data and want to ask
# for specific limits on the axis
fit_box_around_data(p::Missing, box0::Box) = iffinite(box0, Box(0,1,0,1))


function fit_box_around_data(p, box0::Box)
    flattened_data = flat_list_of_points(p)
    truncdata = remove_data_outside_box(flattened_data, box0)
    boxtmp = smallest_box_containing_data(truncdata)
    box1 = iffinite(box0, boxtmp)
end

##############################################################################

function Axis(p, ao::AxisOptions)
    
    ignore_data_outside_this_box = getbox(ao)
    
    # tickbox is set to a box that contains the data
    # so if ignore_data_outside_this_box specifies limits on x,
    # then the data is used to determine limits on y
    # and these limits go into tickbox
    boxtmp = fit_box_around_data(p, ignore_data_outside_this_box)
    tickbox = ifnotmissing(ao.tickbox, expand_box(boxtmp, ao.xdatamargin, ao.ydatamargin))

    # tickbox used to define the minimum area which the ticks
    # are guaranteed to contain
    # Ticks is a set of ticks chosen to be pretty, and to contain tickbox
    ticks = ifnotmissing(ao.ticks, Ticks(tickbox,  ao.xidealnumlabels, ao.yidealnumlabels))

    # axisbox is set to the actual min and max of the values of the ticks
    # and determines the extent of the axis region of the plot
    axisbox = ifnotmissing(ao.axisbox, get_tick_extents(ticks))

    # set window width/height based on axis limits
    # if asked to do so
    wh = set_window_size_from_data(ao.width, ao.height, axisbox, margins(ao),
                                   ao.widthfromdata, ao.heightfromdata)

    ax = AxisMap(wh..., margins(ao), axisbox,
                 ao.axisequal, ao.yoriginatbottom)
  
    axis = Axis(wh..., ax, axisbox, ticks, ao.axisstyle,
                ao.yoriginatbottom, ao.windowbackgroundcolor,
                ao.drawbackground)
    return axis
end

Axis(ao::AxisOptions) = Axis(missing, ao)
    
##############################################################################


function parse_axis_options(; kw...)
    ao = AxisOptions()
    setoptions!(ao, "", kw...)
    setoptions!(ao.tickbox, "tickbox_", kw...)
    setoptions!(ao.axisbox, "axisbox_", kw...)
    setoptions!(ao.ticks, "ticks_", kw...)
    setoptions!(ao.axisstyle, "axisstyle_", kw...)
    return ao
end
    

Axis(p; kw...) = Axis(p, parse_axis_options(; kw...))

Axis(; kw...) = Axis(missing; kw...)

