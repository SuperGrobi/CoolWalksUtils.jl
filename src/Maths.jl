"""
    unit(vector)

returns the vector scaled to unity (using L2 norm).
"""
unit(vec) = vec / sqrt(sum(vec.^2))

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
    [a2*b3-a3*b2, a3*b1-a1*b3, a1*b2-a2*b1]
end