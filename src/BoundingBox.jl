"""
Type alias for
    
    NamedTuple{(:minlon, :minlat, :maxlon, :maxlat), NTuple{4, Float64}}
"""
const BoundingBoxType = @NamedTuple begin
    minlon::Float64
    minlat::Float64
    maxlon::Float64
    maxlat::Float64
end

"""
    BoundingBox(unsort_bb::NamedTuple)
    BoundingBox(minlon, minlat, maxlon, maxlat)
    BoundingBox(geo_array)
    BoundingBox(lons, lats)

builds the Bounding Box from the given input. Returns a `BoundingBoxType`.
"""
function BoundingBox(unsort_bb::NamedTuple)
    return BoundingBoxType((unsort_bb.minlon, unsort_bb.minlat, unsort_bb.maxlon, unsort_bb.maxlat))
end

function BoundingBox(minlon, minlat, maxlon, maxlat)
    return BoundingBoxType((minlon, minlat, maxlon, maxlat))
end

function BoundingBox(geo_array)
    boxes = ArchGDAL.boundingbox.(geo_array)
    min_lat = Inf
    min_lon = Inf
    max_lat = -Inf
    max_lon = -Inf
    for box in boxes
        line = ArchGDAL.getgeom(box, 0)
        for i in 0:ArchGDAL.ngeom(line)-1
            point = ArchGDAL.getgeom(line, i)
            lat = ArchGDAL.gety(point, 0)
            lon = ArchGDAL.getx(point, 0)
            min_lat > lat && (min_lat = lat)
            max_lat < lat && (max_lat = lat)
            min_lon > lon && (min_lon = lon)
            max_lon < lon && (max_lon = lon)
        end
    end
    return BoundingBox(min_lon, min_lat, max_lon, max_lat)
end

function BoundingBox(lons, lats)
    min_lat = Inf
    min_lon = Inf
    max_lat = -Inf
    max_lon = -Inf
    for (lon, lat) in zip(lons, lats)
        min_lat > lat && (min_lat = lat)
        max_lat < lat && (max_lat = lat)
        min_lon > lon && (min_lon = lon)
        max_lon < lon && (max_lon = lon)
    end
    return BoundingBox(min_lon, min_lat, max_lon, max_lat)
end

"""
    in_BoundingBox(lon, lat, bbox::BoundingBoxType)

tests whether the point given by `lon` and `lat` is in `bbox`.
"""
function in_BoundingBox(lon, lat, bbox::BoundingBoxType)
    lon_in = bbox.minlon <= lon <= bbox.maxlon
    lat_in = bbox.minlat <= lat <= bbox.maxlat
    return lon_in && lat_in
end