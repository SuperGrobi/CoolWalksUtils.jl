"""
    geoiter_extent(geo_iter)

constructs the `Extent` from an iterable with `GeoInterface` compatible elements.

    geoiter_extent(X, Y)

constructs the `Extent` from two iterables representing x and y coordinates.
(Note that Numbers are iterable: `geoiter_extent(3.5, 3)` works.)
"""
geoiter_extent(geo_iter) = mapreduce(GeoInterface.extent, Extents.union, geo_iter)
geoiter_extent(X, Y) = Extent(X=extrema(X), Y=extrema(Y))

"""

    extent_center(extent)

calculates the centerpoint of `extent`. Return a `NamedTuple` with the same keys as `extent`.
"""
extent_center(extent) = (; zip(keys(extent), [mean(i) for i in bounds(extent)])...)

"""

extent_contains(a::Extent, X, Y)

Checks if the extent `a` contains the point given by `X` and `Y`.

extent_contains(a::Extent, b::Extent)

Checks if the extent `b` is fully contained in extent `a`.
"""
extent_contains(a::Extent, X, Y) = extent_contains(a, geoarray_extent(X, Y))
extent_contains(a::Extent, b::Extent) = Extents.union(a, b) == a