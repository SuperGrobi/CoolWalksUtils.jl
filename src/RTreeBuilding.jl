"""
    rect_from_geom(geom; buffer=0.0)

builds `SpatialIndexing.Rect` with the extent of the geometry `geom` and a `buffer` of `buffer` added to each edge of the `Rect`. This is for example
useful when we want to query around points, since them having a zero area extend might mess with numerical stuff.
"""
function rect_from_geom(geom; buffer=0.0)
    extent = GeoInterface.extent(geom)
    x, y = values(extent)
    ll = (x[1] - buffer, y[1] - buffer)  # less beautiful, but typestable
    ur = (x[2] + buffer, y[2] + buffer)
    return SpatialIndexing.Rect(ll, ur)
end

"""
    build_rtree(geo_arr)

builds `SpatialIndexing.RTree{Float64, 2}` from an array containing `ArchGDAL.wkbPolygon`s. The value of an entry in the RTree is a named tuple with:
`(orig=original_geometry,prep=prepared_geometry)`. `orig` is just the original object, an element from `geo_arr`, where `prep` is the prepared geometry,
derived from `orig`. The latter one can be used in a few `ArchGDAL` functions to get higher performance, for example in intersection testing, because
relevant values get precomputed and cashed in the prepared geometry, rather than precomputed on every test.
"""
function build_rtree(geo_arr)
    rt = RTree{Float64,2}(Int, NamedTuple{(:orig, :prep),Tuple{ArchGDAL.IGeometry{ArchGDAL.wkbPolygon},ArchGDAL.IPreparedGeometry}})
    for (i, geom) in enumerate(geo_arr)
        bbox = rect_from_geom(geom)
        insert!(rt, bbox, i, (orig=geom, prep=ArchGDAL.preparegeom(geom)))
    end
    return rt
end


"""

    build_point_rtree(points, data, include_orig_point=false)

builds `SpatialIndexing.RTree{Float64, 2}` from an array containing `ArchGDAL.wkbPoint`s. If `include_orig_point` is false, the `val` of an entry in the tree
is just the corresponding element in the `data` array. If `include_orig_point` is true, it will be a `NamedTuple` with keys of `:data` and `:pointgeom`.
"""
function build_point_rtree(points, data, include_orig_point=false)
    valtype = include_orig_point ? NamedTuple{(:data, :pointgeom),Tuple{eltype(data),eltype(points)}} : eltype(data)
    rt = RTree{Float64,2}(Int, valtype)
    for (id, (point, datum)) in enumerate(zip(points, data))
        x = ArchGDAL.getx(point, 0)
        y = ArchGDAL.gety(point, 0)
        if include_orig_point
            attached_data = (data=datum, pointgeom=point)
        else
            attached_data = datum
        end
        insert!(rt, SpatialIndexing.Rect((x, y), (x, y)), id, attached_data)
    end
    return rt
end
