"""
    is_ccw(a, b, c)

tests if the 2D points `a, b, c` form a counterclockwise triangle.

```jldoctest
julia> is_ccw([0,0], [1,0], [1,1])
true

julia> is_ccw([0,0], [0,1], [1.4, 0.5])
false
```
"""
function is_ccw(a, b, c)
    return (a[1] * b[2] - a[2] * b[1] + a[2] * c[1] - a[1] * c[2] + b[1]c[2] - c[1]b[2]) > 0
end

"""
    switches_side(a, b, c, d)

tests if the line defined by the 2D points `a, b` intersects the line segment defined by the 2D points `c,d`.

```@jldoctest
julia> switches_side([0,0], [1,1], [5,0], [0,5])
true

julia> switches_side([0,0], [1,1], [0.4, 0.2], [10.5, 2.0])
false
```
"""
switches_side(a, b, c, d) = is_ccw(a, b, c) ⊻ is_ccw(a, b, d)

"""
    intersection_distances(a, b, c, d)

returns the solution to `a * (1-x1) + b * x1 == c * (1-x2) + d * x2`.

```@jldoctest
julia> intersection_distances([0,0], [1,1], [5,0], [0,5])
2-element Vector{Float64}:
 2.5
 0.5

julia> intersection_distances([0,0.0], [1,1], [4.0, 0.0], [10.0, 2.0])
2-element Vector{Float64}:
 -2.0
 -1.0
```
"""
function intersection_distances(a, b, c, d)
    A = [b - a c - d]
    # left division
    return (A \ (c - a))
end

"""
    is_convex(polygon)

tests if the exterior of the `GeoInterface` compatible `polygon` is convex.

    is_convex(points::AbstractVector)

tests if vector of 2D points `points` describes a convex polygon.

Assumes that `points[1] == points[end]`.

```jldoctest
julia> square = [[0, 0], [1, 0], [1, 1], [0, 1], [0, 0]];

julia> is_convex(square)
true

julia> thing = [[0.6, 0.6], [1.0, 0.0], [1.0, 1.0], [0.0, 1.0], [0.6, 0.6]];

julia> is_convex(thing)
false
```
"""
function is_convex(points::AbstractVector)
    # turning direction where polygon closes
    direction = is_ccw(points[end-1], points[1], points[2])
    for i in 1:length(points)-2
        current_direction = is_ccw(points[i], points[i+1], points[i+2])
        if current_direction != direction
            return false
        end
    end
    return true
end

is_convex(polygon) = GeoInterface.getexterior(polygon) |> GeoInterface.coordinates |> is_convex

"""
checks if `test_point` is left of the line going through `center_point` in the direction of `-sunpos`.
(`sunpos` points AT the sun, has three entries. The last on will be set to 0.)

# Signatures

    is_left(center_point, test_point, sunpos::AbstractVector)

`center_point` and `test_point` can be any `GeoInterface` compatible points.

    is_left(center_point::AbstractVector, test_point::AbstractVector, sunpos::AbstractVector)

`center_point` and `test_point` can be eiter 3 or 2 entry long vectors. In the later case, we add a third entry `==0`.

# Examples
```@jldoctest
julia> is_left([0, 0], [1, 1], [-1, 0, 0])
true

julia> is_left([0.5, 0.5, 0.0], [1, 1, 0.0], [1, 0, 0])
false
```
"""
function is_left(center_point, test_point, sunpos::AbstractVector)
    center_point = GeoInterface.coordinates(center_point)
    test_point = GeoInterface.coordinates(test_point)
    return is_left(center_point, test_point, sunpos)
end
function is_left(center_point::AbstractVector, test_point::AbstractVector, sunpos::AbstractVector)
    Δtest = test_point - center_point

    # pad last dimension
    length(Δtest) == 2 && push!(Δtest, 0.0)

    direction = -sunpos
    direction[end] = 0.0

    cross(direction, Δtest)[end] > 0
end