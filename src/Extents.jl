"""
    geoiter_extent(geo_iter)

constructs the `Extent` from an iterable with `GeoInterface` compatible elements.


"""
geoiter_extent(geo_iter) = mapreduce(GeoInterface.extent, Extents.union, geo_iter)

"""
    geoiter_extent(X, Y)

constructs the `Extent` from two iterables representing x and y coordinates.
(Note that Numbers are iterable: `geoiter_extent(3.5, 3)` works.)
"""
geoiter_extent(X, Y) = Extent(X=extrema(X), Y=extrema(Y))


"""
    extent_center(extent)

calculates the centerpoint of `extent`. Return a `NamedTuple` with the same keys as `extent`.
"""
extent_center(extent) = (; zip(keys(extent), [mean(i) for i in bounds(extent)])...)


"""
    extent_contains(a::Extent, X, Y)

Checks if the extent `a` contains the point given by `X` and `Y`.
"""
extent_contains(a::Extent, X, Y) = extent_contains(a, geoiter_extent(X, Y))

"""
    extent_contains(a::Extent, b::Extent)

Checks if the extent `b` is fully contained in extent `a`.
"""
extent_contains(a::Extent, b::Extent) = Extents.union(a, b) == a

"""
    extent_contains(a::Extent, geometry)

Checks if the `GeoInterface.extent` of `geometry` is fully contained in extent `a`.
"""
extent_contains(a::Extent, geometry) = extent_contains(a, GeoInterface.extent(geometry))

"""
    apply_extent!(df, extent; source=[:lon, :lat])

trim `df` to only contain rows where `extent_contains(extent, source...)` is true.
"""
function apply_extent!(df, extent; source=[:lon, :lat])
    # trim dataframe to given size
    if extent !== nothing
        filter!(source => (g...) -> extent_contains(extent, g...), df)
    end
end