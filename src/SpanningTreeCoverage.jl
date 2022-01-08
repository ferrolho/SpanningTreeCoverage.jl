module SpanningTreeCoverage

using GraphRecipes
using Graphs
using Plots
using StaticArrays

include("io.jl")
include("planning.jl")
include("visuals.jl")

"""
Read an _area_ from `filename`, solve the
single-robot Coverage Path Planning (CPP), and
then plot the area and the optimal coverage path.
"""
function read_solve_plot(filename::AbstractString)
    area = read_area(filename)
    path = solve(area)
    new_area = subdivide_area(area)
    p = plot_area(new_area)
    plot_path!(p, path)
end

export read_solve_plot

end # module
