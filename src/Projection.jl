"""
    project_local!(geo_array, center_lon, center_lat)

projects iterable of `ArchGDAL.jl` geometries from the coordinate system of `first(geo_array)`
to the `transverse mercator` projection centered at `center_lon`, `center_lat`. Returns the projected `geo_array`.
"""
function project_local!(geo_array, center_lon, center_lat)
    projstring = "+proj=tmerc +lon_0=$center_lon +lat_0=$center_lat"
    src = ArchGDAL.getspatialref(first(geo_array))
    dest = ArchGDAL.importPROJ4(projstring)
    ArchGDAL.createcoordtrans(trans -> project_geo_array!(geo_array, trans), src, dest)
    return geo_array
end

"""
    project_back!(geo_array)

projects iterable of `ArchGDAL.jl` geometries from the coordinate system of `first(geo_array)`
to the coordinate reference system given in `OSM_ref` (`EPSG4326`). Returns the projected `geo_array`.
"""
function project_back!(geo_array)
    src = ArchGDAL.getspatialref(first(geo_array))
    ArchGDAL.createcoordtrans(trans -> project_geo_array!(geo_array, trans), src, OSM_ref[])
    return geo_array
end

"""
    project_geo_array!(geo_array, trans)

applies the `ArchGDAL` transformation to every element in `geo_array`.
"""
function project_geo_array!(geo_array, trans)
    for geom in geo_array
        ArchGDAL.transform!(geom, trans)
    end
end

"""
    reinterp_crs!(geom, crs)

reinterprets the coordinates of `ArchGDAL.jl` geometry `geom` to be in the
coordinate reference system `crs`. Returns the reinterpreted `geom`.
"""
function reinterp_crs!(geom, crs)
    ArchGDAL.createcoordtrans(crs, crs) do trans
        ArchGDAL.transform!(geom, trans)
    end
    return geom
end

"""
    apply_wsg_84!(geom)

reinterprets the coordinates of `ArchGDAL.jl` geometry `geom` to be in `OSM_ref` (`EPSG4326`). Returns the reinterpreted `geom`.
"""
apply_wsg_84!(geom) = reinterp_crs!(geom, OSM_ref[])