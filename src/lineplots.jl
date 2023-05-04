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




"""
    lineplot(data; kwargs...)

Plot one or more sequences of points as a line, possibly with markers.

Creates a new Drawable and Axis.
The data is a list of Point objects, or an array of such lists.
The keyword arguments are those supported by the Axis function
and the LinePlot struct.
"""
function drawplot(data; drawfn = nothing, clip=true,  kwargs...)
    axis = Axis(data; kwargs...)
    d = Drawable(axis)
    over(d; clip) do ctx
        if isnothing(drawfn)
            drawplot(axis.ax, ctx, data;  kwargs...)
        else
            drawfn(axis.ax, ctx, data)
        end
    end
    return d
end

#
# should call this with over, if you want clipping
#
function drawplot(ax::AxisMap, ctx::CairoContext, data;
                  linestyle = nothing, linefn = nothing,
                  markerfn = nothing, kwargs...)
    for (i,j,x) in DataIndices(data)
        if isnothing(linefn)
            ls = ifnotnothing(linestyle, LineStyle(colormap(i,j) , 1))
            line(ax, ctx, x; linestyle = ls)
        else
            linefn(ax, ctx, x, i, j)
        end
        if !isnothing(markerfn)
            for p in x
                markerfn(ax, ctx, p, i, j)
            end
        end
    end
   
end

