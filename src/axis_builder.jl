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


#
# AxisStyle specifies how to draw the axis. It
# is set by the user
#
Base.@kwdef mutable struct AxisStyle
    drawbox = false
    edgelinestyle = LineStyle(Color(:black), 2)
    drawaxisbackground = true
    xtickverticaloffset = 16
    ytickhorizontaloffset = -8
    backgroundcolor = Color(:bluegray)
    gridlinestyle = LineStyle(Color(:white), 1)
    fontsize = 13
    fontcolor = Color(:black)
    drawxlabels = true
    drawylabels = true
    drawaxis = true
    drawvgridlines = true
    drawhgridlines = true
    title = ""
end

#
# We use Axis to draw the axis, in addition to the axisstyle.
# Axis also contains information about the window:
#
#   width, height, windowbackgroundcolor, drawbackground,
#
# and information about the axis which is not style
#
#   ticks, box, yoriginatbottom
#
# and the AxisStyle object "as". Note that the AxisStyle object
# is provided by the user, and unchanged, but the ticks, and box
# are computed by the Axis constructor.
#
# yoriginatbottom comes from the AxisOptions, and affects
# both the axis drawing and the axismap.
#
# All of this is necessary to draw the axis.
#
# We use AxisMap to draw the graph on the axis.
#
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

#
# AxisOptions is passed to the Axis constructor,
# which creates the Axis object above. It contains the style
# information for drawing the axis, in AxisStyle
# and the information used to construct the AxisMap, and the layout
# within the window.
#
# AxisOptions are set by the user
# They are only used to create the Axis object.
#
Base.@kwdef mutable struct AxisOptions
    xmin = -Inf
    xmax = Inf
    ymin = -Inf
    ymax = Inf
    xdatamargin = 0
    ydatamargin = 0
    xwidenfactor = 1
    ywidenfactor = 1
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
    windowbackgroundcolor = Color(:white)
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
    tickbox = ifnotmissing(ao.tickbox,
                           scale_box(expand_box(boxtmp, ao.xdatamargin, ao.ydatamargin),
                                     ao.xwidenfactor, ao.ywidenfactor))

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
    setoptions!(ao, "axisoptions_", kw...)
    setoptions!(ao.tickbox, "tickbox_", kw...)
    setoptions!(ao.axisbox, "axisbox_", kw...)
    setoptions!(ao.ticks, "ticks_", kw...)
    setoptions!(ao.axisstyle, "axisstyle_", kw...)
    return ao
end
    

Axis(p; kw...) = Axis(p, parse_axis_options(; kw...))

Axis(; kw...) = Axis(missing; kw...)

