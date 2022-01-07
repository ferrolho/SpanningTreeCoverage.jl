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

export subdivide_area
