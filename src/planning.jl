function subdivide_area(area)
    obstacles = findall(==(1), area)
    robots = findall(==(2), area)

    CI1 = CartesianIndex(1, 1)
    f(ci) = (ci - CI1) * 2 + CI1
    map!(f, obstacles, obstacles)
    map!(f, robots, robots)

    new_area = zeros(Int8, size(area) .* 2)

    foreach(obstacles) do ci
        x, y = ci.I
        cis = CartesianIndices((x:x+1, y:y+1))
        new_area[cis] .= 1
    end

    new_area[robots] .= 2

    new_area
end

function calculate_obstacle_nodes(area)
    area_nodes = reshape(1:length(area), size(area))
    obstacles_ci = findall(==(1), area)
    obstacle_nodes = area_nodes[obstacles_ci]
end

"""
    calculate_mst(dims, obstacle_nodes; algorithm_mst = kruskal_mst)

Return a vector of edges representing the Minimum Spanning Tree (MST) of `area`.

The algorithm used to calculate the MST can be either `kruskal_mst` or `prim_mst`.
"""
function calculate_mst(dims, obstacle_nodes; algorithm_mst = kruskal_mst)
    g = Graphs.grid(dims)
    rem_vertices!(g, obstacle_nodes, keep_order = true)
    algorithm_mst(g)
end

function calculate_guide(dims, obstacle_nodes, mst)
    xu, yu = dims
    cis = CartesianIndices((1:xu, 1:yu))

    xs = [ci[1] * 2 - 0.5 for (i, ci) in enumerate(cis) if i ∉ obstacle_nodes]
    ys = [ci[2] * 2 - 0.5 for (i, ci) in enumerate(cis) if i ∉ obstacle_nodes]

    guide = Set(SVector{2,Float64}[])

    for e in mst
        v1, v2 = e.src, e.dst
        p1 = SVector(xs[v1], ys[v1])
        p2 = SVector(xs[v2], ys[v2])
        v = (p2 - p1) / 4
        for i = 0:4
            x = p1 + i * v
            push!(guide, x)
        end
    end

    guide
end

export subdivide_area, calculate_obstacle_nodes, calculate_mst, calculate_guide
