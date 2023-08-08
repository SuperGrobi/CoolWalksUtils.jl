@testitem "apply wsg84" begin
    using ArchGDAL
    function setup()
        point1 = ArchGDAL.createpoint(1.0, 1.0)
        point2 = ArchGDAL.createpoint(3.5, 1.2)
        line1 = ArchGDAL.createlinestring([(0.0, 0.0), (1.0, 1.0), (2.0, 1.0)])
        line2 = ArchGDAL.createlinestring([(1.0, 0.0), (1.0, 1.0), (0.0, 2.4)])
        pointlist = [point1, point2]
        linelist = [line1, line2]
        geomlist = [pointlist; linelist]
    end

    # test application of wsg84 for single elements
    geomlist = setup()
    for geom in geomlist
        @test repr(ArchGDAL.getspatialref(geom)) == "NULL Spatial Reference System"
        geom_reinterp = apply_wsg_84!(geom)

        @test geom_reinterp === geom
        @test repr(ArchGDAL.getspatialref(geom)) == "Spatial Reference System: +proj=longlat +datum=WGS84 +no_defs"
    end

    # test application for arrays
    geomlist = setup()
    for geom in geomlist
        @test repr(ArchGDAL.getspatialref(geom)) == "NULL Spatial Reference System"
    end
    geom_reinterp = apply_wsg_84!(geomlist)
    @test geom_reinterp === geomlist
    @test repr(ArchGDAL.getspatialref(geomlist[1])) == "Spatial Reference System: +proj=longlat +datum=WGS84 +no_defs"

    # test application for generators
    geomgenerator = (i for i in setup())
    for geom in geomgenerator
        @test repr(ArchGDAL.getspatialref(geom)) == "NULL Spatial Reference System"
    end
    geom_reinterp = apply_wsg_84!(geomgenerator)
    @test geom_reinterp === geomgenerator
    @test repr(ArchGDAL.getspatialref(first(geomgenerator))) == "Spatial Reference System: +proj=longlat +datum=WGS84 +no_defs"
end


@testitem "Project geometries" begin
    using ArchGDAL, TimeZones
    point1 = ArchGDAL.createpoint(1.0, 1.0)
    point2 = ArchGDAL.createpoint(3.5, 1.2)
    line1 = ArchGDAL.createlinestring([(0.0, 0.0), (1.0, 1.0), (2.0, 1.0)])
    line2 = ArchGDAL.createlinestring([(1.0, 0.0), (1.0, 1.0), (0.0, 2.4)])
    pointlist = [point1, point2]
    linelist = [line1, line2]

    geomlist = [pointlist; linelist]

    obs = ShadowObservatory("test observatory", 1, 1, tz"Europe/London")

    #local transformation needs a crs
    for g in geomlist
        try
            project_local!(g, obs)
            @test false
        catch
            @test true
        end
    end

    apply_wsg_84!(geomlist)

    # project local, but individually
    for g in geomlist
        local_g = project_local!(g, obs)
        @test local_g == g
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

    # project back, but individually
    for g in geomlist
        global_g = project_back!(g)
        @test global_g == g
    end

    for geom in geomlist
        # test if default crs is back
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

@testitem "Project geometry vectors" begin
    using ArchGDAL, TimeZones

    point1 = ArchGDAL.createpoint(1.0, 1.0)
    point2 = ArchGDAL.createpoint(3.5, 1.2)
    line1 = ArchGDAL.createlinestring([(0.0, 0.0), (1.0, 1.0), (2.0, 1.0)])
    line2 = ArchGDAL.createlinestring([(1.0, 0.0), (1.0, 1.0), (0.0, 2.4)])

    pointlist = [point1, point2]
    linelist = [line1, line2]
    geomlist = [pointlist; linelist]

    obs = ShadowObservatory("test observatory", 1, 1, tz"Europe/London")

    #local transformation needs a crs
    try
        project_local!(pointlist, obs)
        @test false
    catch
        @test true
    end

    # empty list is trivially transformed
    @test project_local!([], obs) == []
    @test project_back!([]) == []

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

    local_pointlist = project_local!(pointlist, obs)
    @test all(local_pointlist .=== pointlist)
    local_linelist = project_local!(linelist, obs)
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
end


@testitem "Project geometry generators" begin
    using ArchGDAL, TimeZones

    point1 = ArchGDAL.createpoint(1.0, 1.0)
    point2 = ArchGDAL.createpoint(3.5, 1.2)
    line1 = ArchGDAL.createlinestring([(0.0, 0.0), (1.0, 1.0), (2.0, 1.0)])
    line2 = ArchGDAL.createlinestring([(1.0, 0.0), (1.0, 1.0), (0.0, 2.4)])

    pointgen = (i for i in [point1, point2])
    linegen = (i for i in [line1, line2])
    geomgen = (i for i in [point1, point2, line1, line2])

    obs = ShadowObservatory("test observatory", 1, 1, tz"Europe/London")

    #local transformation needs a crs
    try
        project_local!(pointgen, obs)
        @test false
    catch
        @test true
    end

    # empty list is trivially transformed
    @test project_local!((i for i in []), obs) |> collect == []
    @test project_back!((i for i in [])) |> collect == []

    # test application of wsg84 (and apply wsg84)
    for geom in geomgen
        # check if crs is NULL
        @test repr(ArchGDAL.getspatialref(geom)) == "NULL Spatial Reference System"
        # apply wsg 84
        geom_reinterp = apply_wsg_84!(geom)
        @test geom_reinterp === geom
        # test if new crs was applied
        @test repr(ArchGDAL.getspatialref(geom)) == "Spatial Reference System: +proj=longlat +datum=WGS84 +no_defs"
    end

    local_pointgen = project_local!(pointgen, obs)
    @test all(local_pointgen .=== pointgen)
    local_linegen = project_local!(linegen, obs)
    @test all(local_linegen .=== linegen)

    for geom in geomgen
        @test contains(repr(ArchGDAL.getspatialref(geom)), "Spatial Reference System: +proj=tmerc +lat_0=1 +lon_0=1")
    end

    # check if (1.0, 1.0) => (0.0, 0.0)
    @test ArchGDAL.getx(point1, 0) == 0.0
    @test ArchGDAL.gety(point1, 0) == 0.0

    @test ArchGDAL.getx(line1, 1) == 0.0
    @test ArchGDAL.gety(line1, 1) == 0.0

    @test ArchGDAL.getx(line2, 1) == 0.0
    @test ArchGDAL.gety(line2, 1) == 0.0

    global_geomgen = project_back!(geomgen)
    @test all(global_geomgen .=== geomgen)

    for geom in geomgen
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


@testitem "Project dataframes" begin
    using ArchGDAL, DataFrames, TimeZones
    point1 = ArchGDAL.createpoint(1.0, 1.0)
    point2 = ArchGDAL.createpoint(3.5, 1.2)
    line1 = ArchGDAL.createlinestring([(0.0, 0.0), (1.0, 1.0), (2.0, 1.0)])
    line2 = ArchGDAL.createlinestring([(1.0, 0.0), (1.0, 1.0), (0.0, 2.4)])

    pointlist = [point1, point2]
    linelist = [line1, line2]
    geomlist = [pointlist; linelist]
    apply_wsg_84!(geomlist)

    obs = ShadowObservatory("test observatory", 1, 1, tz"Europe/London")
    df = DataFrame(points=pointlist, lines=linelist, info=["row 1", "row 2"])

    @test_throws ArgumentError project_local!(df)
    df_local = project_local!(df, obs)

    @test df_local == df
    for geom in df.points
        @test contains(repr(ArchGDAL.getspatialref(geom)), "Spatial Reference System: +proj=tmerc +lat_0=1 +lon_0=1")
    end
    for geom in df.lines
        @test contains(repr(ArchGDAL.getspatialref(geom)), "Spatial Reference System: +proj=tmerc +lat_0=1 +lon_0=1")
    end
    df_global = project_back!(df)
    @test df_global == df

    set_observatory!(df, "pointobservatory", tz"Europe/London"; source=[:points])
    setobs = metadata(df, "observatory")
    @test setobs.name == "pointobservatory"
    @test setobs.lon ≈ 2.25
    @test setobs.lat ≈ 1.1

    set_observatory!(df, "lineobservatory", tz"Europe/London"; source=[:lines])
    setobs = metadata(df, "observatory")
    @test setobs.name == "lineobservatory"
    @test setobs.lon ≈ 1.0
    @test setobs.lat ≈ 1.2


    metadata!(df, "observatory", ShadowObservatory("test obs", 1.3, 1.5, tz"Europe/London"), style=:note)
    df_local = project_local!(df)
    for geom in df.points
        @test contains(repr(ArchGDAL.getspatialref(geom)), "Spatial Reference System: +proj=tmerc +lat_0=1.5 +lon_0=1.3")
    end
    for geom in df.lines
        @test contains(repr(ArchGDAL.getspatialref(geom)), "Spatial Reference System: +proj=tmerc +lat_0=1.5 +lon_0=1.3")
    end

    # empty dataframe ist trivially transformed
    df = DataFrame(:geometry => [], :id => [], :height => [])
    @test project_local!(df, obs) == df
    @test project_back!(df) == df
end

@testitem "reinterpret in coordinates" begin
    using ArchGDAL
    function setup()
        point1 = ArchGDAL.createpoint(1.0, 1.0)
        point2 = ArchGDAL.createpoint(3.5, 1.2)
        line1 = ArchGDAL.createlinestring([(0.0, 0.0), (1.0, 1.0), (2.0, 1.0)])
        line2 = ArchGDAL.createlinestring([(1.0, 0.0), (1.0, 1.0), (0.0, 2.4)])
        pointlist = [point1, point2]
        linelist = [line1, line2]
        geomlist = [pointlist; linelist]
    end

    dst = CoolWalksUtils.crs_local(1, 1)

    # test application of wsg84 for single elements
    geomlist = setup()
    for geom in geomlist
        @test repr(ArchGDAL.getspatialref(geom)) == "NULL Spatial Reference System"
        geom_reinterp = reinterp_crs!(geom, dst)

        @test geom_reinterp === geom
        @test contains(repr(ArchGDAL.getspatialref(geom)), "Spatial Reference System: +proj=tmerc +lat_0=1 +lon_0=1")
    end

    # test application for arrays
    geomlist = setup()
    for geom in geomlist
        @test repr(ArchGDAL.getspatialref(geom)) == "NULL Spatial Reference System"
    end
    geom_reinterp = reinterp_crs!(geomlist, dst)
    @test geom_reinterp === geomlist
    @test contains(repr(ArchGDAL.getspatialref(geomlist[1])), "Spatial Reference System: +proj=tmerc +lat_0=1 +lon_0=1")

    # test application for generators
    geomgenerator = (i for i in setup())
    for geom in geomgenerator
        @test repr(ArchGDAL.getspatialref(geom)) == "NULL Spatial Reference System"
    end
    geom_reinterp = reinterp_crs!(geomgenerator, dst)
    @test geom_reinterp === geomgenerator
    @test contains(repr(ArchGDAL.getspatialref(first(geomgenerator))), "Spatial Reference System: +proj=tmerc +lat_0=1 +lon_0=1")
end

@testitem "in local coordinates" begin
    using ArchGDAL, DataFrames, TimeZones

    point1 = ArchGDAL.createpoint(1.0, 1.0)
    point2 = ArchGDAL.createpoint(3.5, 1.2)
    line1 = ArchGDAL.createlinestring([(0.0, 0.0), (1.0, 1.0), (2.0, 1.0)])
    line2 = ArchGDAL.createlinestring([(1.0, 0.0), (1.0, 1.0), (0.0, 2.4)])

    pointlist = [point1, point2]
    linelist = [line1, line2]
    geomlist = [pointlist; linelist]
    apply_wsg_84!(geomlist)

    obs = ShadowObservatory("test observatory", 1, 1, tz"Europe/London")
    df = DataFrame(points=ArchGDAL.clone.(pointlist), lines=ArchGDAL.clone.(linelist), info=["row 1", "row 2"])
    metadata!(df, "observatory", obs, style=:note)

    for geom in geomlist
        @test repr(ArchGDAL.getspatialref(geom)) == "Spatial Reference System: +proj=longlat +datum=WGS84 +no_defs"
    end

    global_lengths = ArchGDAL.geomlength.(linelist)

    local_results = in_local_coordinates(obs, pointlist, df, linelist) do pl, df, ll
        for ls in [pl, ll, df.points, df.lines]
            for geom in ls
                @test contains(repr(ArchGDAL.getspatialref(geom)), "Spatial Reference System: +proj=tmerc +lat_0=1 +lon_0=1")
            end
        end
        for (pl, ll) in ((pl, ll), (df.points, df.lines))
            @test ArchGDAL.getx(pl[1], 0) == 0.0
            @test ArchGDAL.gety(pl[1], 0) == 0.0

            @test ArchGDAL.getx(ll[1], 1) == 0.0
            @test ArchGDAL.gety(ll[1], 1) == 0.0

            @test ArchGDAL.getx(ll[2], 1) == 0.0
            @test ArchGDAL.gety(ll[2], 1) == 0.0
        end
        return ArchGDAL.geomlength.(ll)
    end
    for geom in geomlist
        @test repr(ArchGDAL.getspatialref(geom)) == "Spatial Reference System: +proj=longlat +datum=WGS84 +no_defs"
    end
    for (pl, ll) in ((pointlist, linelist), (df.points, df.lines))
        # check if (0.0, 0.0) => (1.0, 1.0)
        @test ArchGDAL.getx(pl[1], 0) == 1.0
        @test ArchGDAL.gety(pl[1], 0) == 1.0

        @test ArchGDAL.getx(ll[1], 1) == 1.0
        @test ArchGDAL.gety(ll[1], 1) == 1.0

        @test ArchGDAL.getx(ll[2], 1) == 1.0
        @test ArchGDAL.gety(ll[2], 1) == 1.0
    end

    @test all(local_results .> global_lengths)

    # projection with observatory from df
    local_results = in_local_coordinates(df, pointlist, linelist) do df, pl, ll
        for ls in [pl, ll, df.points, df.lines]
            for geom in ls
                @test contains(repr(ArchGDAL.getspatialref(geom)), "Spatial Reference System: +proj=tmerc +lat_0=1 +lon_0=1")
            end
        end
        for (pl, ll) in ((pl, ll), (df.points, df.lines))
            @test ArchGDAL.getx(pl[1], 0) == 0.0
            @test ArchGDAL.gety(pl[1], 0) == 0.0

            @test ArchGDAL.getx(ll[1], 1) == 0.0
            @test ArchGDAL.gety(ll[1], 1) == 0.0

            @test ArchGDAL.getx(ll[2], 1) == 0.0
            @test ArchGDAL.gety(ll[2], 1) == 0.0
        end
        return ArchGDAL.geomlength.(ll)
    end
    for geom in geomlist
        @test repr(ArchGDAL.getspatialref(geom)) == "Spatial Reference System: +proj=longlat +datum=WGS84 +no_defs"
    end
    for (pl, ll) in ((pointlist, linelist), (df.points, df.lines))
        # check if (0.0, 0.0) => (1.0, 1.0)
        @test ArchGDAL.getx(pl[1], 0) == 1.0
        @test ArchGDAL.gety(pl[1], 0) == 1.0

        @test ArchGDAL.getx(ll[1], 1) == 1.0
        @test ArchGDAL.gety(ll[1], 1) == 1.0

        @test ArchGDAL.getx(ll[2], 1) == 1.0
        @test ArchGDAL.gety(ll[2], 1) == 1.0
    end

    @test all(local_results .> global_lengths)
end
