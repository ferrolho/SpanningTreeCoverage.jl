"""
    read_area(filename::AbstractString)

Read an _area_ from a file.

# Examples
```jldoctest
julia> read_area("empty5x5")
5×5 Matrix{Int8}:
 2  0  0  0  0
 0  0  0  0  0
 0  0  0  0  0
 0  0  0  0  0
 0  0  0  0  0
```
"""
function read_area(filename::AbstractString)
    input = read(joinpath(@__DIR__, "..", "data", filename), String)

    lines = split(input, "\n", keepempty = false)
    filter!(x -> first(x) != '#', lines)

    mapreduce(hcat, lines) do line
        parse.(Int8, split(line))
    end |> permutedims
end

"""
    read_areas(filenames)
    read_areas(filenames...)

Read _areas_ from multiple files.
"""
read_areas(filenames) = map(read_area, filenames)
read_areas(filenames...) = map(read_area, filenames)

export read_area, read_areas
