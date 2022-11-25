var documenterSearchIndex = {"docs":
[{"location":"Maths/#Maths","page":"Maths","title":"Maths","text":"","category":"section"},{"location":"Maths/#Introduction","page":"Maths","title":"Introduction","text":"","category":"section"},{"location":"Maths/","page":"Maths","title":"Maths","text":"These are just a few pure maths functions used all over the place.","category":"page"},{"location":"Maths/#API","page":"Maths","title":"API","text":"","category":"section"},{"location":"Maths/","page":"Maths","title":"Maths","text":"Pages = [\"Maths.md\"]","category":"page"},{"location":"Maths/","page":"Maths","title":"Maths","text":"Modules = [CoolWalksUtils]\nPages = [\"Maths.jl\"]","category":"page"},{"location":"Maths/#CoolWalksUtils.cross-Tuple{Any, Any}","page":"Maths","title":"CoolWalksUtils.cross","text":"cross(v1, v2)\n\ncross product of the two input vectors. Stolen from LinearAlgebra.jl.\n\n\n\n\n\n","category":"method"},{"location":"Maths/#CoolWalksUtils.unit-Tuple{Any}","page":"Maths","title":"CoolWalksUtils.unit","text":"unit(vector)\n\nreturns the vector scaled to unity (using L2 norm).\n\n\n\n\n\n","category":"method"},{"location":"Testing/#Testing","page":"Testing","title":"Testing","text":"","category":"section"},{"location":"Testing/#Introduction","page":"Testing","title":"Introduction","text":"","category":"section"},{"location":"Testing/","page":"Testing","title":"Testing","text":"Here we have a little macro to rerun arbitrary code multiple times in case it failes for some reason. It is used to retry testing of downloading from osm, since the server often is not willing to serve a request on the first try.","category":"page"},{"location":"Testing/#API","page":"Testing","title":"API","text":"","category":"section"},{"location":"Testing/","page":"Testing","title":"Testing","text":"Pages = [\"Testing.md\"]","category":"page"},{"location":"Testing/","page":"Testing","title":"Testing","text":"Modules = [CoolWalksUtils]\nPages = [\"Testing.jl\"]","category":"page"},{"location":"Testing/#CoolWalksUtils.@rerun-Tuple{Any, Any}","page":"Testing","title":"CoolWalksUtils.@rerun","text":"@rerun(number, code)\n\nruns the input code at most number times or until it does not throw an error. Used to test code which talks to a server which may not respond on every call.\n\n\n\n\n\n","category":"macro"},{"location":"BoundingBox/#Bounding-Box-Utilities","page":"Bounding Box","title":"Bounding Box Utilities","text":"","category":"section"},{"location":"BoundingBox/#Introduction","page":"Bounding Box","title":"Introduction","text":"","category":"section"},{"location":"BoundingBox/","page":"Bounding Box","title":"Bounding Box","text":"These are a few functions intended to generate bounding boxes from different input types","category":"page"},{"location":"BoundingBox/#API","page":"Bounding Box","title":"API","text":"","category":"section"},{"location":"BoundingBox/","page":"Bounding Box","title":"Bounding Box","text":"Pages = [\"BoundingBox.md\"]","category":"page"},{"location":"BoundingBox/","page":"Bounding Box","title":"Bounding Box","text":"Modules = [CoolWalksUtils]\nPages = [\"BoundingBox.jl\"]","category":"page"},{"location":"BoundingBox/#CoolWalksUtils.BoundingBoxType","page":"Bounding Box","title":"CoolWalksUtils.BoundingBoxType","text":"Type alias for\n\nNamedTuple{(:minlon, :minlat, :maxlon, :maxlat), NTuple{4, Float64}}\n\n\n\n\n\n","category":"type"},{"location":"BoundingBox/#CoolWalksUtils.BoundingBox-Tuple{NamedTuple}","page":"Bounding Box","title":"CoolWalksUtils.BoundingBox","text":"BoundingBox(unsort_bb::NamedTuple)\nBoundingBox(minlon, minlat, maxlon, maxlat)\nBoundingBox(geo_array)\nBoundingBox(lons, lats)\n\nbuilds the Bounding Box from the given input. Returns a BoundingBoxType.\n\n\n\n\n\n","category":"method"},{"location":"BoundingBox/#CoolWalksUtils.in_BoundingBox-Tuple{Any, Any, NamedTuple{(:minlon, :minlat, :maxlon, :maxlat), NTuple{4, Float64}}}","page":"Bounding Box","title":"CoolWalksUtils.in_BoundingBox","text":"in_BoundingBox(lon, lat, bbox::BoundingBoxType)\n\ntests whether the point given by lon and lat is in bbox.\n\n\n\n\n\n","category":"method"},{"location":"SunPosition/#Sun-Position","page":"Sun Position","title":"Sun Position","text":"","category":"section"},{"location":"SunPosition/#Introduction","page":"Sun Position","title":"Introduction","text":"","category":"section"},{"location":"SunPosition/","page":"Sun Position","title":"Sun Position","text":"Roberto Grena,\nFive new algorithms for the computation of sun position from 2010 to 2110,\nSolar Energy,\nVolume 86, Issue 5,\n2012,\nPages 1323-1337,\nISSN 0038-092X,\nhttps://doi.org/10.1016/j.solener.2012.01.024.\n(https://www.sciencedirect.com/science/article/pii/S0038092X12000400)","category":"page"},{"location":"SunPosition/#API","page":"Sun Position","title":"API","text":"","category":"section"},{"location":"SunPosition/","page":"Sun Position","title":"Sun Position","text":"Pages = [\"SunPosition.md\"]","category":"page"},{"location":"SunPosition/","page":"Sun Position","title":"Sun Position","text":"Modules = [CoolWalksUtils]\nPages = [\"SunPosition.jl\"]","category":"page"},{"location":"SunPosition/#CoolWalksUtils.algorithm_1-Tuple{Any, Any}","page":"Sun Position","title":"CoolWalksUtils.algorithm_1","text":"algorithm_1(t_2060, longitude)\n\nalgorithm 1 to calculate the sun position as described by Roberto Grena (2012), Five new algorithms for the computation of sun position from 2010 to 2110, Solar Energy, 86(5):1323–1337, doi:10.1016/j.solener.2012.01.024. Simplified to not use TT-UT, pressure and temperature.\n\n\n\n\n\n","category":"method"},{"location":"SunPosition/#CoolWalksUtils.get_local_sun_pos-Tuple{Any, Any, Any}","page":"Sun Position","title":"CoolWalksUtils.get_local_sun_pos","text":"get_local_sun_pos(latitude, declination, hour_angle)\n\ntransform the location of the sun in the sky from global coordinates into spherical coordinates local to latitude and longitude used to calculate the inputs.\n\nReturns\n\n(elevation, azimuth) The elevation is the heigth of the sun above the horizon, in radians. The azimuth is the horizontal position of the sun in a polar coordinate system, where azimuth=0 points to the south pole. negative angles point to the east, positive to the west. again, in radians.\n\n\n\n\n\n","category":"method"},{"location":"SunPosition/#CoolWalksUtils.sunposition","page":"Sun Position","title":"CoolWalksUtils.sunposition","text":"Functions to calculate the sun position, adapted from Roberto Grena (2012), Five new algorithms for the computation of sun position from 2010 to 2110, Solar Energy, 86(5):1323–1337, doi:10.1016/j.solener.2012.01.024.\n\nwe use only algorithm 1 and omit the inputs of TT-UT, pressure and temperature, since we do not need the precision to launch satellites\n\nNotes on Arguments\n\nlongitude has to be in radians from 0 to 2π, starting from Greenwitch going east\nlatitude has to be in radians from -π to -π, starting from south pole, going north\n\nReturn\n\nArray with 3 entries [x,y,z], representing vector pointing towards sun in local, cartesian coordinate system, centered at longitude, latitude with x pointing east, y pointing north and z pointing up.\n\n\n\nsunposition(date::DateTime, longitude, latitude, timezone::Int=1, daylight_saving::Bool=true)\n\nNotes on Arguments\n\ndate is assumed to be in local time. \ntimezone and daylight_saving are used to convert to gmt. If the time is allready gmt, set timezone=0 and daylight_saving=false\n\n\n\nsunposition(time, day::Int, month::Int, year::Int, longitude, latitude, timezone::Int=1, daylight_saving::Bool=true)\n\nNotes on Arguments\n\ntime is local time in hours. Convert minutes and seconds... to fractions of hours. (13:30 becomes 13.5) range from 0 to 24.\ntimezone and daylight_saving are used to convert to gmt. If the time is allready gmt, set timezone=0 and daylight_saving=false.\n\n\n\n\n\n","category":"function"},{"location":"Projection/#Projection-utilities","page":"Projection","title":"Projection utilities","text":"","category":"section"},{"location":"Projection/#Introduction","page":"Projection","title":"Introduction","text":"","category":"section"},{"location":"Projection/","page":"Projection","title":"Projection","text":"CoolWalkUtils.jl specifies a few convenient functions to interpret and reproject different datastructures revolving around ArchGDAL.jl types. (most of this behaviour should probably be part of ArchGDAL.jl, but it is not, as of the time of writing.)","category":"page"},{"location":"Projection/#API","page":"Projection","title":"API","text":"","category":"section"},{"location":"Projection/","page":"Projection","title":"Projection","text":"Pages = [\"Projection.md\"]","category":"page"},{"location":"Projection/","page":"Projection","title":"Projection","text":"OSM_ref","category":"page"},{"location":"Projection/#CoolWalksUtils.OSM_ref","page":"Projection","title":"CoolWalksUtils.OSM_ref","text":"Reference which holds the WSG84 (EPSG4326) ArchGDAL Spatial Reference System with lon-lat order.\n\n\n\n\n\n","category":"constant"},{"location":"Projection/","page":"Projection","title":"Projection","text":"Modules = [CoolWalksUtils]\nPages = [\"Projection.jl\"]","category":"page"},{"location":"Projection/#CoolWalksUtils.apply_wsg_84!-Tuple{Any}","page":"Projection","title":"CoolWalksUtils.apply_wsg_84!","text":"apply_wsg_84!(geom)\n\nreinterprets the coordinates of ArchGDAL.jl geometry geom to be in OSM_ref (EPSG4326).\n\n\n\n\n\n","category":"method"},{"location":"Projection/#CoolWalksUtils.project_back!-Tuple{Any}","page":"Projection","title":"CoolWalksUtils.project_back!","text":"project_back!(geo_array)\n\nprojects iterable of ArchGDAL.jl geometries from the coordinate system of first(geo_array) to the coordinate reference system given in OSM_ref (EPSG4326).\n\n\n\n\n\n","category":"method"},{"location":"Projection/#CoolWalksUtils.project_geo_array!-Tuple{Any, Any}","page":"Projection","title":"CoolWalksUtils.project_geo_array!","text":"project_geo_array!(geo_array, trans)\n\napplies the ArchGDAL transformation to every element in geo_array.\n\n\n\n\n\n","category":"method"},{"location":"Projection/#CoolWalksUtils.project_local!-Tuple{Any, Any, Any}","page":"Projection","title":"CoolWalksUtils.project_local!","text":"project_local!(geo_array, center_lon, center_lat)\n\nprojects iterable of ArchGDAL.jl geometries from the coordinate system of first(geo_array) to the transverse mercator projection centered at center_lon, center_lat.\n\n\n\n\n\n","category":"method"},{"location":"Projection/#CoolWalksUtils.reinterp_crs!-Tuple{Any, Any}","page":"Projection","title":"CoolWalksUtils.reinterp_crs!","text":"reinterp_crs!(geom, crs)\n\nreinterprets the coordinates of ArchGDAL.jl geometry geom to be in the coordinate reference system crs.\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = CoolWalksUtils","category":"page"},{"location":"#CoolWalksUtils","page":"Home","title":"CoolWalksUtils","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for CoolWalksUtils.","category":"page"}]
}
