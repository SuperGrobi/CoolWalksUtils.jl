@testset "Bounding Box" begin

    basic_bbox = CoolWalksUtils.BoundingBoxType((0.0, 1.0, 5.0, 1.4))
    @test basic_bbox.minlon == 0.0
    @test basic_bbox.minlat == 1.0
    @test basic_bbox.maxlon == 5.0
    @test basic_bbox.maxlat == 1.4

    unsorted_bbox = BoundingBox((maxlon=10.0, minlon=0.4, maxlat=8.4, minlat=0.2))
    @test unsorted_bbox.minlon == 0.4
    @test unsorted_bbox.minlat == 0.2
    @test unsorted_bbox.maxlon == 10.0
    @test unsorted_bbox.maxlat == 8.4

    fourargs_bbox = BoundingBox(0.5, 0.2, 10.0, 8.4)
    @test fourargs_bbox.minlon == 0.5
    @test fourargs_bbox.minlat == 0.2
    @test fourargs_bbox.maxlon == 10.0
    @test fourargs_bbox.maxlat == 8.4

    point1 = ArchGDAL.createpoint(1.0, 1.0)
    point2 = ArchGDAL.createpoint(3.5, 1.2)
    line1 = ArchGDAL.createlinestring([(0.0, 0.0), (1.0, 1.0), (2.0, 1.0)])
    line2 = ArchGDAL.createlinestring([(1.0, 0.0), (1.0, 1.0), (0.0, 2.4)])

    geomlist = [point1, point2, line1, line2]
    geom_bbox = BoundingBox(geomlist)
    @test geom_bbox.minlon == 0.0
    @test geom_bbox.minlat == 0.0
    @test geom_bbox.maxlon == 3.5
    @test geom_bbox.maxlat == 2.4

    lons = [8.5, 9.3, 0.2, 5, 6, 1, 6.3, 1.2, 7.3, 5, 3.9, 5.1]
    lats = [1, 2, 3, 8, 4, 5, 9, 2, 4, 3, 0.3, 1.5]

    point_bbox = BoundingBox(lons, lats)
    @test point_bbox.minlon == minimum(lons)
    @test point_bbox.minlat == minimum(lats)
    @test point_bbox.maxlon == maximum(lons)
    @test point_bbox.maxlat == maximum(lats)

    lon = 0.4
    lat = 1.5
    @test !in_BoundingBox(lon, lat, basic_bbox)
    @test in_BoundingBox(lon, lat, unsorted_bbox)
    @test !in_BoundingBox(lon, lat, fourargs_bbox)
    @test in_BoundingBox(lon, lat, geom_bbox)
    @test in_BoundingBox(lon, lat, point_bbox)

    @warn "no tests for bounding box yet implemented"
end