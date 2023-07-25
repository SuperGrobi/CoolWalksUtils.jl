module CoolWalksUtils

using StatsBase

using GeoInterface
using Extents

using ArchGDAL
using SpatialIndexing
using DataFrames

using AstroLib
using Dates
using TimeZones


"""
Reference which holds the WSG84 (EPSG4326) `ArchGDAL` Spatial Reference System
with lon-lat order.
"""
const OSM_ref = Ref{ArchGDAL.ISpatialRef}()

function __init__()
    OSM_ref[] = ArchGDAL.importEPSG(4326; order=:trad)
    nothing
end

export OSM_ref

export local_sunpos, ShadowObservatory
include("SunPosition.jl")

export project_local!,
    project_back!,
    reinterp_crs!,
    apply_wsg_84!
include("Projection.jl")

export geoiter_extent, extent_center, extent_contains
include("Extents.jl")

export unit, cross, is_ccw, intersection_distance, switches_side, is_convex, is_left
include("Maths.jl")

export build_rtree, rect_from_geom, build_point_rtree
include("RTreeBuilding.jl")

export @rerun
include("Testing.jl")

# TODO: Rework Extents
# TODO: Rework Maths
# TODO: Rework Projection
# TODO: Rework RTreeBuilding
# TODO: Rework Testing
end