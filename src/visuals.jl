rectangle(x, y, w, h) = Shape(x .+ [0, w, w, 0], y .+ [0, 0, h, h])

function plot_area(area)
    xu, yu = size(area)

    p = plot(
        aspect_ratio = :equal, size = (400, 400),
        xlims = (0.5, yu + 0.5), ylims = (0.5, xu + 0.5),
        xtick = 0:5:yu, ytick = 0:5:xu, tickfontsize = 4,
        legend = nothing, yflip = true, palette = :Pastel1,
    )

    for ci in CartesianIndices(area)
        (x, y), w, h = ci.I, 1, 1
        r = rectangle(y - 0.5, x - 0.5, h, w)
        plot!(p, r, color = Int(area[ci]), line = :white, linewidth = 0.5)
    end

    p
end

export plot_area
