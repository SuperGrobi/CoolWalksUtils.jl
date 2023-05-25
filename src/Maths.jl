"""
    unit(vector)

returns the vector scaled to unity (using L2 norm).
"""
unit(vec) = vec / sqrt(sum(vec .^ 2))

# stolen from LinearAlgebra
"""
    cross(v1, v2)

cross product of the two input vectors. Stolen from `LinearAlgebra.jl`.
"""
function cross(a, b)
    if !(length(a) == length(b) == 3)
        throw(DimensionMismatch("cross product is only defined for vectors of length 3"))
    end
    a1, a2, a3 = a
    b1, b2, b3 = b
    [a2 * b3 - a3 * b2, a3 * b1 - a1 * b3, a1 * b2 - a2 * b1]
end

function is_ccw(a, b, c)
    return (a[1] * b[2] - a[2] * b[1] + a[2] * c[1] - a[1] * c[2] + b[1]c[2] - c[1]b[2]) > 0
end

switches_side(a, b, c, d) = is_ccw(a, b, c) ⊻ is_ccw(a, b, d)

function intersection_distance(a, b, c, d)
    A = [b - a c - d]
    # left division
    return (A \ (c - a))
end

function is_convex(points)
    # turning direction where polygon closes
    direction = is_ccw(points[:, end-1], points[:, 1], points[:, 2])
    for i in 1:size(points, 2)-2
        current_direction = is_ccw(points[:, i], points[:, i+1], points[:, i+2])
        if current_direction != direction
            return false
        end
    end
    return true
end