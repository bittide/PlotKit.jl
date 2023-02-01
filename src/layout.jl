
# functions for laying out drawables

function hbox(r1::T, r2::T; windowbackgroundcolor = Color(:white)) where T <: Drawable
    width = r1.width + r2.width
    height = max(r1.height, r2.height)
    r = T(width, height)
    over(r) do ctx
        rect(ctx, Point(0, 0), Point(width, height); fillcolor = windowbackgroundcolor)
        paint(ctx, r1, Point(0, 0))
        paint(ctx, r2, Point(r1.width, 0))
    end
    return r
end

function vbox(r1::T, r2::T; windowbackgroundcolor = Color(:white)) where T <: Drawable
    width = max(r1.width, r2.width)
    height = r1.height + r2.height
    r = T(width, height)
    over(r) do ctx
        rect(ctx, Point(0, 0), Point(width, height); fillcolor = windowbackgroundcolor)
        paint(ctx, r1, Point(0, 0))
        paint(ctx, r2, Point(0, r1.height))
    end
    return r
end


# position f2 relative to f1
function offset(f1::T, f2::T, dx, dy;  windowbackgroundcolor = Color(:white)) where T <: Drawable
    left = min(0, dx)
    top = min(0, dy)
    right = max(f1.width, f2.width + dx)
    bottom = max(f1.height, f2.height + dy)
    width = right - left
    height = bottom - top
    r = T(width, height)
    over(r) do ctx
        rect(ctx, Point(0, 0), Point(width, height); fillcolor = windowbackgroundcolor)
        paint(ctx, f1, Point(-left, -top))
        paint(ctx, f2, Point(dx - left, dy - top))
    end
    return r
end





vbox(f, g::Missing) = f
vbox(f::Missing, g) = g
hbox(f, g::Missing) = f
hbox(f::Missing, g) = g


vbox(fs::Array) = reduce(vbox, fs)
hbox(fs::Array) = reduce(hbox, fs)

function hvbox(farray)
    rows = [hbox(collect(r)) for r in eachrow(farray)]
    return vbox(collect(rows))
end

function stack(x, ncols)
    nrows = Int(ceil(length(x)/ncols))
    A = Array{Any,2}(missing, ncols, nrows)
    for i=1:length(x)
        A[i] = x[i]
    end
    B = permutedims(A, (2,1))
    return B
end

# modifies bot
#over(top::Drawable, bot::Drawable; kwargs...) = over(top.fn, bot; kwargs...)


