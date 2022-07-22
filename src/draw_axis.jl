



##############################################################################
# drawing the axis



function drawaxis(ctx, axismap, ticks, box, as::AxisStyle)
    if !as.drawaxis
        return
    end
    xticks = ticks.xticks
    xtickstrings = ticks.xtickstrings
    yticks = ticks.yticks
    ytickstrings = ticks.ytickstrings
    xmin, xmax, ymin, ymax = box.xmin, box.xmax, box.ymin, box.ymax
    @plotfns(axismap)
    if as.drawaxisbackground
        Cairo.rectangle(ctx, rfx(xmin), rfy(ymin), rfx(xmax)-rfx(xmin),
                        rfy(ymax)-rfy(ymin))
        source(ctx, as.backgroundcolor)
        Cairo.fill(ctx)
    end
    Cairo.set_line_width(ctx, 1)
    for i=1:length(xticks)
        xt = xticks[i]
        if as.drawvgridlines
            if xt>xmin && xt<xmax
                Cairo.move_to(ctx, rfx(xt)-0.5, rfy(ymax))  
                Cairo.line_to(ctx, rfx(xt)-0.5, rfy(ymin))
                set_linestyle(ctx, as.gridlinestyle)
                Cairo.stroke(ctx)
            end
        end
        if xt>=xmin && xt<=xmax
            if as.drawxlabels
                text(ctx, Point(fx(xt), fy(ymin) + as.xtickverticaloffset),
                     as.fontsize, as.fontcolor, xtickstrings[i];
                     horizontal = "center")
            end
        end
    end
    for i=1:length(yticks)
        yt = yticks[i]
        if as.drawhgridlines
            if yt>ymin && yt<ymax
                Cairo.move_to(ctx, rfx(xmin), rfy(yt)-0.5) 
                Cairo.line_to(ctx, rfx(xmax), rfy(yt)-0.5)
                set_linestyle(ctx, as.gridlinestyle)
                Cairo.stroke(ctx)
            end
        end
        if yt>=ymin && yt<=ymax
            if as.drawylabels
                text(ctx, Point(fx(xmin) + as.ytickhorizontaloffset, fy(yt)),
                     as.fontsize, as.fontcolor, ytickstrings[i];
                     horizontal = "right", vertical = "center")
            end
        end
    end
    if as.drawbox
        Cairo.move_to(ctx, rfx(xmin)-0.5, rfy(ymax)-0.5)  #tl
        Cairo.line_to(ctx, rfx(xmin)-0.5, rfy(ymin)+0.5)  #bl
        Cairo.line_to(ctx, rfx(xmax)+0.5, rfy(ymin)+0.5)  #br
        Cairo.line_to(ctx, rfx(xmax)+0.5, rfy(ymax)-0.5)  #tr
        Cairo.close_path(ctx)
        set_linestyle(ctx, as.edgelinestyle)
        Cairo.stroke(ctx)
    end
    text(ctx, Point(fx((xmin+xmax)/2), fy(ymax) + 15), as.fontsize, as.fontcolor, as.title;
         horizontal = "center")
    
end

##############################################################################

# also draw background
function drawaxis(ctx, axis::Axis)
    if axis.drawbackground
        rect(ctx, Point(0,0), Point(axis.width, axis.height); fillcolor=axis.windowbackgroundcolor)
    end
    drawaxis(ctx, axis.ax, axis.ticks, axis.box, axis.as)
end

function setclipbox(ctx::CairoContext, axis::Axis)
    setclipbox(ctx, axis.ax, axis.box)
end

