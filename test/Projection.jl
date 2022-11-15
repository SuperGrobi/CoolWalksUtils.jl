@testset "Projection" begin
    point1 = ArchGDAL.createpoint(1.0, 1.0)
    point2 = ArchGDAL.createpoint(3.5, 1.2)
    line1 = ArchGDAL.createlinestring([(0.0, 0.0), (1.0, 1.0), (2.0, 1.0)])
    line2 = ArchGDAL.createlinestring([(1.0, 0.0), (1.0, 1.0), (0.0, 2.4)])
    
    pointlist = [point1, point2]
    linelist = [line1, line2]
    geomlist = [pointlist; linelist]

    #local transformation needs a crs
    try
        project_local!(pointlist, 1, 1)
        @test false
    catch
        @test true
    end

    # test application of wsg84 (and apply wsg84)
    for geom in geomlist
        # check if crs is NULL
        @test repr(ArchGDAL.getspatialref(geom)) == "NULL Spatial Reference System"
        # apply wsg 84
        apply_wsg_84!(geom)
        # test if new crs was applied
        @test repr(ArchGDAL.getspatialref(geom)) == "Spatial Reference System: +proj=longlat +datum=WGS84 +no_defs"
    end

    try
        project_local!(pointlist, 1, 1)
        @test true
        project_local!(linelist, 1, 1)
        @test true
    catch
        @test false
        @test false
    end

    for geom in geomlist
        @test contains(repr(ArchGDAL.getspatialref(geom)), "Spatial Reference System: +proj=tmerc +lat_0=1 +lon_0=1")
    end

    # check if (1.0, 1.0) => (0.0, 0.0)
    @test ArchGDAL.getx(point1, 0) == 0.0
    @test ArchGDAL.gety(point1, 0) == 0.0

    @test ArchGDAL.getx(line1, 1) == 0.0
    @test ArchGDAL.gety(line1, 1) == 0.0

    @test ArchGDAL.getx(line2, 1) == 0.0
    @test ArchGDAL.gety(line2, 1) == 0.0

    try
        project_back!(geomlist)
        @test true
    catch
        @test false
    end

    for geom in geomlist
        # test if default crs was applied
        @test repr(ArchGDAL.getspatialref(geom)) == "Spatial Reference System: +proj=longlat +datum=WGS84 +no_defs"
    end

    # check if (0.0, 0.0) => (1.0, 1.0)
    @test ArchGDAL.getx(point1, 0) == 1.0
    @test ArchGDAL.gety(point1, 0) == 1.0

    @test ArchGDAL.getx(line1, 1) == 1.0
    @test ArchGDAL.gety(line1, 1) == 1.0

    @test ArchGDAL.getx(line2, 1) == 1.0
    @test ArchGDAL.gety(line2, 1) == 1.0
end