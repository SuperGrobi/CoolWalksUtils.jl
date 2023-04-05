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
        geom_reinterp = apply_wsg_84!(geom)
        @test geom_reinterp === geom
        # test if new crs was applied
        @test repr(ArchGDAL.getspatialref(geom)) == "Spatial Reference System: +proj=longlat +datum=WGS84 +no_defs"
    end

    local_pointlist = project_local!(pointlist, 1, 1)
    @test all(local_pointlist .=== pointlist)
    local_linelist = project_local!(linelist, 1, 1)
    @test all(local_linelist .=== linelist)

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

    global_geomlist = project_back!(geomlist)
    @test all(global_geomlist .=== geomlist)

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

    df = DataFrame(points=pointlist, lines=linelist, info=["row 1", "row 2"])
    df_local = project_local!(df, 1, 1)
    @test df_local == df
    for geom in df.points
        @test contains(repr(ArchGDAL.getspatialref(geom)), "Spatial Reference System: +proj=tmerc +lat_0=1 +lon_0=1")
    end
    for geom in df.lines
        @test contains(repr(ArchGDAL.getspatialref(geom)), "Spatial Reference System: +proj=tmerc +lat_0=1 +lon_0=1")
    end
    df_global = project_back!(df)
    @test df_global == df

    metadata!(df, "center_lon", 1.3)
    metadata!(df, "center_lat", 1.5)
    df_local = project_local!(df)
    for geom in df.points
        @test contains(repr(ArchGDAL.getspatialref(geom)), "Spatial Reference System: +proj=tmerc +lat_0=1.5 +lon_0=1.3")
    end
    for geom in df.lines
        @test contains(repr(ArchGDAL.getspatialref(geom)), "Spatial Reference System: +proj=tmerc +lat_0=1.5 +lon_0=1.3")
    end
end