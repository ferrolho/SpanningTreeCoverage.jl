function plot_area(area)
    area_w, area_h = size(area)
    plot_w, plot_h = 600, 600
    marker_w = 0.5 * plot_w / area_w

    p = plot(
        aspect_ratio = :equal, size = (plot_w, plot_h),
        xlims = (0.5, area_h + 0.5), ylims = (0.5, area_w + 0.5),
        xtick = 0:5:area_h, ytick = 0:5:area_w, tickfontsize = 4,
        legend = nothing, yflip = true, palette = :Pastel1,
    )

    points = mapreduce(ci -> [ci.I...], hcat, CartesianIndices(area))
    colors = map(ci -> Int(area[ci]), CartesianIndices(area)) |> vec

    scatter!(
        p, points[2, :], points[1, :], color = colors,
        markershape = :rect, markerstrokecolor = :white,
        markersize = marker_w, markerstrokewidth = 0.5,
    )

    p
end

function plot_mst!(p, dims, obstacle_nodes, mst)
    xu, yu = dims
    cis = CartesianIndices((1:xu, 1:yu))

    xs = [ci[1] * 2 - 0.5 for (i, ci) in enumerate(cis) if i ∉ obstacle_nodes]
    ys = [ci[2] * 2 - 0.5 for (i, ci) in enumerate(cis) if i ∉ obstacle_nodes]

    g_mst = SimpleGraph(mst)

    graphplot!(p, g_mst, x = ys, y = xs, curves = false,
        nodecolor = 3, nodeshape = :circle,
        nodesize = 2, nodestrokewidth = 0.01
    )

    p
end

function plot_guide!(p, guide)
    points = mapreduce(x -> [x...], hcat, guide)
    scatter!(p, points[2, :], points[1, :], markercolor = :black,
        markershape = :rect, markersize = 1, markerstrokewidth = 0.01)
end

export plot_area, plot_mst!, plot_guide!
