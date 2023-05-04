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

    abstract type Drawable end

An object which is a Drawable stores Cairo drawings.

A Drawable has three methods

 - Drawable(width, height)         constructor
 - paint(ctx, drawable, point)     write the contents of the drawable onto ctx
                                   and delete the drawable
 - save(drawable, filename)        save the contents to a pdf or png file
 - over!(fn, drawable)             fn is a function which takes a Cairo Context.
                                   over! calls that function to draw on the drawable.

The drawable has a member drawable.axis, which may contain an Axis object,
or may be nothing.
"""
abstract type Drawable
end




mutable struct Recorder <: Drawable
    surface
    ctx
    width
    height
    axis
end

##############################################################################
# create empty
    
function Recorder(width, height)
    surface, ctx = CairoTools.makerecordingsurface(width, height)
    return Recorder(surface, ctx, width, height, nothing)
end
    
##############################################################################
# output it

# output to a context
function Cairo.paint(ctx, r::Recorder, p = Point(0,0), scale=1.0)
    Cairo.save(ctx)
    Cairo.scale(ctx, scale, scale)
    set_source_surface(ctx, r.surface, p.x/scale, p.y/scale)
    paint(ctx)
    Cairo.restore(ctx)
    Cairo.finish(r.surface)
    Cairo.destroy(r.surface)
    Cairo.destroy(r.ctx)
    # rely on the finalizer in Cairo.jl to kill the ctx
end
    
# output to a file
#
# needs a scale option
function Cairo.save(r::Recorder, fname, scale=1)
    surface2, ctx2 = makesurface(scale*r.width, scale*r.height, fname)
    Cairo.scale(ctx2, scale, scale)
    paint(ctx2, r, Point(0,0))
    closesurface(surface2, fname)
    Cairo.finish(surface2)
    Cairo.destroy(surface2)
    Cairo.destroy(ctx2)
    Cairo.finish(r.surface)
    Cairo.destroy(r.surface)
    Cairo.destroy(r.ctx)
    # rely on the finalizer in Cairo.jl to kill the ctx
end
    

##############################################################################
# write to a record
    
function over(top::Function, d::Recorder; clip = true)
    save(d.ctx)
    if clip && !isnothing(d.axis)
        setclipbox(d.ctx, d.axis)
    end
    top(d.ctx)
    restore(d.ctx)
end


##############################################################################
# API functions
    
Drawable(width, height) = Recorder(width, height)
function Drawable(axis::Axis)
    d = Drawable(axis.width, axis.height)
    over(d) do ctx
        drawaxis(ctx, axis)    
    end
    d.axis = axis
    return d
end

function Drawable(fn::Function, width, height)
    d = Drawable(width, height)
    over(fn, d)
    return d
end


