"""
    crs_local(lon, lat)

builds Transverse Mercator `ArchGDAL` coordinate reference system centered around `lon` and `lat`.
"""
crs_local(lon, lat) = ArchGDAL.importPROJ4("+proj=tmerc +lon_0=$lon +lat_0=$lat")


"""
    _execute_projection!(geometry::ArchGDAL.IGeometry, src, dst)
    _execute_projection!(geometry_array::AbstractArray, src, dst)

Applies the transformation from `src` to `dst` to `geometry` or the elements of `geometry_array`.
"""
function _execute_projection!(geometry::ArchGDAL.IGeometry, src, dst)
    ArchGDAL.createcoordtrans(trans -> ArchGDAL.transform!(geometry, trans), src, dst)
    return geometry
end

function _execute_projection!(geometry_array::AbstractArray, src, dst)
    ArchGDAL.createcoordtrans(src, dst) do trans
        for g in geometry_array
            ArchGDAL.transform!(g, trans)
        end
    end
    return geometry_array
end


"""
    project_local!(geometry_container, observatory::ShadowObservatory)
    project_local!(df::DataFrame, observatory::ShadowObservatory=metadata(df, "observatory"))

Projects geometry or containers of geometry to transverse mercator centered at `(lon, lat)` in `observatory`.

In the case of arrays, we assume all the entries to be in the same `crs` as the first entry.
For `DataFrames` each colum containing geometry (determined by `isgeometry(first(column))`) is assumed to be in the same `crs` as the first entry.

Returns the passed geometry container.

    project_local!(container, lon, lat)

Same as above, but allows to specify the center of the projection via `lon` and `lat` in degrees.
"""
function project_local! end

# dispatches to lon lat methods
project_local!(geometry_container, observatory::ShadowObservatory) = project_local!(geometry_container, observatory.lon, observatory.lat)
project_local!(df::DataFrame, observatory::ShadowObservatory=metadata(df, "observatory")) = project_local!(df, observatory.lon, observatory.lat)


# lat lon versions
function project_local!(geometry::ArchGDAL.IGeometry, lon, lat)
    src = ArchGDAL.getspatialref(geometry)
    dst = crs_local(lon, lat)
    _execute_projection!(geometry, src, dst)
    return geometry
end

function project_local!(df::DataFrame, lon, lat)
    if nrow(df) > 0
        for c in eachcol(df)
            if isgeometry(first(c))
                # treat each column as its own vector
                project_local!(c, lon, lat)
            end
        end
    end
    return df
end

function project_local!(geometry_array::AbstractArray, lon, lat)
    if length(geometry_array) > 0
        src = ArchGDAL.getspatialref(first(geometry_array))
        dst = crs_local(lon, lat)
        _execute_projection!(geometry_array, src, dst)
    end
    return geometry_array
end

"""
    project_back!(geometry_container)

Projects geometry or containers of geometry from their respective local system back to `WSG84`.

In the case of arrays, we assume all the entries to be in the same `crs` as the first entry.
For `DataFrames` each colum containing geometry (`isgeometry(first(column))`) is assumed to be in the same `crs` as the first entry.

Returns the passed in geometry container.
"""
function project_back! end

function project_back!(geometry::ArchGDAL.IGeometry)
    src = ArchGDAL.getspatialref(geometry)
    _execute_projection!(geometry, src, OSM_ref[])
    return geometry
end

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

function project_back!(geometry_array::AbstractArray)
    if length(geometry_array) > 0
        src = ArchGDAL.getspatialref(first(geometry_array))
        _execute_projection!(geometry_array, src, OSM_ref[])
    end
    return geometry_array
end

"""
    reinterp_crs!(geometry_container, crs)

reinterprets the coordinates of `geometry_container` (either `ArchGDAL.IGeometry` or `AbstractArray` of the same) to be in `crs`.
"""
reinterp_crs!(geometry_container, crs) = _execute_projection!(geometry_container, crs, crs)


"""
    apply_wsg_84!(geometry_container)

reinterprets the coordinates of `geometry_container` (either `ArchGDAL.IGeometry` or `AbstractArray` of the same) to be in `WSG84`.
"""
apply_wsg_84!(geometry_container) = reinterp_crs!(geometry_container, OSM_ref[])