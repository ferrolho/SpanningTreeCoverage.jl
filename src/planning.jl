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

export subdivide_area, calculate_obstacle_nodes, calculate_mst
