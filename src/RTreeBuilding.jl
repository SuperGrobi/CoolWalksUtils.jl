"""
    rect_from_geom(geom; buffer=0.0)

builds `SpatialIndexing.Rect` with the extent of the geometry `geom` and a `buffer` of `buffer` added to each edge of the `Rect`.
Ideally, `SpatialIndexing.jl` would integrate with `GeoInterface.jl` or at least `Extents.jl`, making this function obsolete.
"""
function rect_from_geom(geom; buffer=0.0)
    extent = GeoInterface.extent(geom)
    x, y = values(extent)
    ll = (x[1] - buffer, y[1] - buffer)  # less beautiful, but typestable
    ur = (x[2] + buffer, y[2] + buffer)
    return SpatialIndexing.Rect(ll, ur)
end

"""
    build_rtree(geom_arr::AbstractArray, data_arr=[nothing])

builds `SpatialIndexing.RTree{Float64, 2}` from an array containing `ArchGDAL.IGeometry`s. The value of an entry in the RTree is a named tuple with:
`(orig=original_geometry,prep=prepared_geometry, data=data_entry)`. `orig` is the original object, an element from `geom_arr`. `prep` is the prepared geometry,
derived from `orig`. The latter one can be used in a few `ArchGDAL` functions to get higher performance, for example in intersection testing, because
relevant values get precomputed and cashed in the prepared geometry, rather than recomputed on every test. `data` holds the entry in `data_arr` at the index of
`orig` in `geom_arr`.

The type of the `val` tuple is determined by the `eltype` of `geom_arr` and `data_arr`. For performance sake, make sure they are concrete.
"""
function build_rtree(geom_arr::AbstractArray, data_arr=[nothing])
    @assert length(data_arr) in [1, length(geom_arr)] "data has to be the same length as geom_arr"
    rt = RTree{Float64,2}(Int, NamedTuple{(:orig, :prep, :data),Tuple{eltype(geom_arr),ArchGDAL.IPreparedGeometry,eltype(data_arr)}})
    for (i, (geom, data)) in enumerate(zip(geom_arr, Iterators.cycle(data_arr)))
        bbox = rect_from_geom(geom)

        insert!(rt, bbox, i, (orig=geom, prep=ArchGDAL.preparegeom(geom), data=data))
    end
    return rt
end

"""
    build_rtree(df::DataFrame)

builds `SpatialIndexing.RTree{Float64, 2}` from a `DataFrame` containing at least a column named `geometry`. The value of an entry in the RTree is a named tuple with:
`(orig=original_geometry, prep=prepared_geometry, data=dataframe_row)`. `orig` is the same geometry as in `row.geometry`, and `prep` is the prepared geometry, derived from `orig`.
It can be used in a few `ArchGDAL` functions to get higher performance, for example in intersection testing, because relevant values get precomputed and
cashed in the prepared geometry, rather than recomputed on every test.

Note that only the first element in these tests can be a prepared geometry, for example `ArchGDAL.intersects(normal_geom, prepared_geom)`
is a highway to segfault-town, while `ArchGDAL.intersects(prepared_geom, normal_geom)` is fine and great.

The `data` entry is a reference to the row of the original dataframe `df`, providing access to all relevant data.
"""
build_rtree(df::DataFrame) = build_rtree(df.geometry, eachrow(df))