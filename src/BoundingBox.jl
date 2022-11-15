const BoundingBoxType = @NamedTuple begin
    minlon::Float64
    minlat::Float64
    maxlon::Float64
    maxlat::Float64
end

function BoundingBox(unsort_bb::NamedTuple)
    return BoundingBoxType((unsort_bb.minlon, unsort_bb.minlat, unsort_bb.maxlon, unsort_bb.maxlat))
end

function BoundingBox(minlon, minlat, maxlon, maxlat)
    return BoundingBoxType((minlon, minlat, maxlon, maxlat))
end

function BoundingBox(geo_colunm)
    boxes = ArchGDAL.boundingbox.(geo_colunm)
    min_lat = Inf
    min_lon = Inf
    max_lat = -Inf
    max_lon = -Inf
    for box in boxes
        for point in GeoInterface.getpoint(box)
            lat = getcoord(point, 2)
            lon = getcoord(point, 1)
            min_lat > lat && (min_lat = lat)
            max_lat < lat && (max_lat = lat)
            min_lon > lon && (min_lon = lon)
            max_lon < lon && (max_lon = lon)
        end
    end
    return BoundingBox(min_lon, min_lat, max_lon, max_lat)
end

function BoundingBox(lon, lat)
    min_lat = Inf
    min_lon = Inf
    max_lat = -Inf
    max_lon = -Inf
    for (lon, lat) in zip(lon, lat)
        min_lat > lat && (min_lat = lat)
        max_lat < lat && (max_lat = lat)
        min_lon > lon && (min_lon = lon)
        max_lon < lon && (max_lon = lon)
    end
    return BoundingBox(min_lon, min_lat, max_lon, max_lat)
end

function in_BoundingBox(lon, lat, bbox::BoundingBoxType)
    lon_in = bbox.minlon <= lon <= bbox.maxlon
    lat_in = bbox.minlat <= lat <= bbox.maxlat
    return lon_in && lat_in
end