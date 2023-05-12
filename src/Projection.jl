"""
    project_local!(geo_array, center_lon, center_lat)

projects iterable of `ArchGDAL.jl` geometries from the coordinate system of `first(geo_array)`
to the `transverse mercator` projection centered at `center_lon`, `center_lat`. Returns the projected `geo_array`.
"""
function project_local!(geo_array, center_lon, center_lat)
    if length(geo_array) > 0
        projstring = "+proj=tmerc +lon_0=$center_lon +lat_0=$center_lat"
        src = ArchGDAL.getspatialref(first(geo_array))
        dest = ArchGDAL.importPROJ4(projstring)
        ArchGDAL.createcoordtrans(trans -> project_geo_array!(geo_array, trans), src, dest)
    end
    return geo_array
end

"""

    project_local!(df::DataFrame, center_lon=metadata(df, "center_lon"), center_lat=metadata(df, "center_lat"))

projects each colum of `df` where the first entry is `GeoInterface.geometry()` to the `transverse mercator` projection
centered at `center_lon`, `center_lat`. Returns the projected `df`.
"""
function project_local!(df::DataFrame, center_lon=metadata(df, "center_lon"), center_lat=metadata(df, "center_lat"))
    if nrow(df) > 0
        for c in eachcol(df)
            if isgeometry(first(c))
                project_local!(c, center_lon, center_lat)
            end
        end
    end
    return df
end

"""
    project_back!(geo_array)

projects iterable of `ArchGDAL.jl` geometries from the coordinate system of `first(geo_array)`
to the coordinate reference system given in `OSM_ref` (`EPSG4326`). Returns the projected `geo_array`.
"""
function project_back!(geo_array)
    if length(geo_array) > 0
        src = ArchGDAL.getspatialref(first(geo_array))
        ArchGDAL.createcoordtrans(trans -> project_geo_array!(geo_array, trans), src, OSM_ref[])
    end
    return geo_array
end

"""

    project_back!(df::DataFrame)
    
projects each column of `df` where the first entry is `GeoInterface.geometry()` back to `OSM_ref[]`. Return the `df`.
"""
function project_back!(df::DataFrame)
    if nrow(df) > 0
        for c in eachcol(df)
            if isgeometry(first(c))
                project_back!(c)
            end
        end
    end
    return df
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