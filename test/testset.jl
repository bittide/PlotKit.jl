
plotpath(x) = joinpath(ENV["HOME"], "plots/", x)

function main()
    @testset "PlotKitGL" begin
        @test main1()
    end
end

pzip(a,b) = Point.(zip(a,b))

function plot(data; kw...)
    ad = AxisDrawable(data; kw...)
    drawaxis(ad)
    line(ad, data; linestyle = LineStyle(Color(:red),1))
    return ad # close handled by caller
end


function main1()
    x = collect(0:0.01:10)
    p1(t) = pzip(x, sin.(x *(1+t)))
    f1(t) = plot(p1(t); ymin =-2, ymax = 2,
                     windowbackgroundcolor=Color(1-exp(-t),0.8,0.8))
    p2(t) = pzip(x, exp(-t)*sin.(x *(1+t)))
    f2(t) = plot(p2(t); ymin =-2, ymax = 2)

    f(t) = hbox(f1(t),f2(t))
    anim = Anim(f)
    anim.tmax = 1
    see(anim)
    return true
end
