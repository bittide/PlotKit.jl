
"""

    struct Drawable
        fn, width, height, axis
    end

A Drawable object is something that you can draw on.  Drawing happens
using Cairo. The member drawable.fn is a function which takes a Cairo context
and does the actual drawing.

If the drawable.fn needs an axis, then drawable.axis is the corresponding
Axis object. Otherwise drawable.axis = nothing.
"""
mutable struct FunctionStore <: Drawable
    fn       # arguments are (ctx), or (ctx, t)
    width
    height
    axis     # maybe nothing, or an Axis object
end

##############################################################################
# create empty

function FunctionStore(width, height)
    fn(ctx, args...) = return
    return FunctionStore(fn, width, height, nothing)
end

##############################################################################
# output it

# output to a context
function Cairo.paint(ctx, d::FunctionStore, p = Point(0,0))
    Cairo.save(ctx)
    Cairo.translate(ctx, p.x, p.y)
    d.fn(ctx)
    Cairo.restore(ctx)
end

# output to a file
function Cairo.save(d::FunctionStore, fname)
    surface, ctx = makesurface(d.width, d.height, fname)
    d.fn(ctx)
    closesurface(surface, fname)
end


##############################################################################
# write to a record

function over(top::Function, bot::FunctionStore; clip=true)
    g = bot.fn
    fn = function(ctx, args...)
        g(ctx, args...)
        save(ctx)
        if clip
            setclipbox(ctx, bot.axis.ax, bot.axis.box)
        end
        top(ctx, args...)
        restore(ctx)
    end
    bot.fn = fn
end

##############################################################################



# specific constructors
FunctionStore(; kwargs...) = FunctionStore(Axis(; kwargs...))
FunctionStore(data; kwargs...) = FunctionStore(Axis(data; kwargs...))

# create with a function
function FunctionStore(fn::Function, width, height)
    d = FunctionStore(width, height)
    over(d, clip = false) do ctx
        fn(ctx)
    end
    return d
end

"""
    FunctionStore(axis::Axis)

Return a FunctionStore with an attached axis.
"""
function FunctionStore(axis::Axis)
    d = FunctionStore(axis.width, axis.height) do ctx
        drawaxis(ctx, axis)
    end
    d.axis = axis
    return d
end


##############################################################################

# surely Drawable(...) should always call FunctionStore(...) or Recorder(...)
#
Drawable(width, height; store=FunctionStore) = store(width, height)
Drawable(f::Function, width, height; store = FunctionStore) = store(f, width, height)
Drawable(axis::Axis; store = FunctionStore) = store(axis)

## Drawable(; store=FunctionStore, kwargs...) = store(Axis(; kwargs...))
## Drawable(data; store = FunctionStore, kwargs...) = store(Axis(data; kwargs...))
##

##############################################################################
# old recorder
## 
## 
## function over(top::Function, bot::Recorder; clip=true)
##     save(bot.ctx)
##     if clip
##         setclipbox(bot.ctx, bot.axis.ax, bot.axis.box)
##     end
##     top(bot.ctx)
##     restore(bot.ctx)
## end
## 
## 
## 
## 
## 
## 
## ##############################################################################
## 
## 
## 
## # specific constructors
## Recorder(; kwargs...) = Recorder(Axis(; kwargs...))
## Recorder(data; kwargs...) = Recorder(Axis(data; kwargs...))
## 
## # create with a function
## function Recorder(fn::Function, width, height)
##     r = Recorder(width, height)
##     over(r, clip = false) do ctx
##         fn(ctx)
##     end
##     return r
## end
## 
## """
##     Recorder(axis::Axis)
## 
## Return a Recorder with an attached axis.
## """
## function Recorder(axis::Axis)
##     r = Recorder(axis.width, axis.height) do ctx
##         drawaxis(ctx, axis)
##     end
##     r.axis = axis
##     return r
## end
