module CoolWalksUtils

using ArchGDAL
using Dates
using SpatialIndexing
using GeoInterface
using DataFrames

"""
Reference which holds the WSG84 (EPSG4326) `ArchGDAL` Spatial Reference System
with lon-lat order.
"""
const OSM_ref = Ref{ArchGDAL.ISpatialRef}()

function __init__()
    OSM_ref[] = ArchGDAL.importEPSG(4326; order=:trad)
    nothing
end

#=
    toWKT(geom::ArchGDAL.AbstractPreparedGeometry)

temporary function to prevent segfault when trying to print prepared geometry
=#
ArchGDAL.toWKT(geom::ArchGDAL.AbstractPreparedGeometry) = "PreparedGeometry"

export OSM_ref

export sunposition, sunposition_deg, is_daylight_saving
include("SunPosition.jl")

export project_local!,
    project_back!,
    reinterp_crs!,
    apply_wsg_84!
include("Projection.jl")

export BoundingBox, in_BoundingBox, center_BoundingBox
include("BoundingBox.jl")

export unit, cross
include("Maths.jl")

export build_rtree, rect_from_geom, build_point_rtree
include("RTreeBuilding.jl")

export @rerun
include("Testing.jl")

# TODO: convex hull for dataframes and graphs
# TODO: polygon to coordstring?
# TODO: spatial dataset-intersections
end