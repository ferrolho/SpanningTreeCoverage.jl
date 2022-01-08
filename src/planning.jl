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

"""
Given an MST, compute a "guide" path that the robot shall circumnavigate.
"""
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

function calculate_flow_direction(robot, new_area, guide)
    # The order of the elements in `steps` is important to ensure
    # the robot circumnavigates the "guide" on its right hand side.
    steps = (
        SVector( 0,  1),
        SVector(-1,  0),
        SVector( 0, -1),
        SVector( 1,  0),
    )

    for step in steps
        ci = CartesianIndex((robot + step)...)
        half_step = robot + step / 2
        if checkbounds(Bool, new_area, ci) &&
           new_area[ci] == 0 &&
           half_step ∉ guide
            return step
        end
    end

    # The control flow should never reach this point.
    @error "Circumnavigation flow not found."
end

"""
    rotate_vector(v, θ)

Rotate a 2D vector `v` by `θ` (in radians).
"""
function rotate_vector(v, θ)
    R = @SMatrix [ cos(θ) -sin(θ) ;
                   sin(θ)  cos(θ) ]
    return R * v
end

"""
Return a `Tuple{Bool, Bool, Bool}`, representing whether a part of
`guide` is to the _left_, _front_, and _right_ of the robot, respectively.
"""
function scan_around(robot, heading, guide)
    v = 0.5 * heading
    left, front, right = rotate_vector(v, π/2), v, rotate_vector(v, -π/2)
    map(x -> robot + x ∈ guide, (left, front, right))
end

"""
Find the actual path for the robot to follow, by circumnavigating `guide`.
"""
function calculate_circumnavigation_path(new_area, guide)
    ci_robots = findall(==(2), new_area)
    starting_point = SVector(only(ci_robots).I)  # SCPP

    step = calculate_flow_direction(starting_point, new_area, guide)
    current_point = starting_point .+ step
    path = [starting_point, current_point]

    while current_point != starting_point
        left, front, right = scan_around(current_point, step, guide)
        # @show current_point, left, front, right

        if !right
            step = rotate_vector(step, -π/2)
            step = SVector{2,Int}(round.(step))
        elseif !front
            # No need to change the stepping direction.
        elseif !left
            step = rotate_vector(step, π/2)
            step = SVector{2,Int}(round.(step))
        end

        current_point = current_point .+ step

        push!(path, current_point)
    end

    path
end

export subdivide_area, calculate_obstacle_nodes, calculate_mst, calculate_guide, calculate_circumnavigation_path
