@testitem "SunPosition cartesian" begin
    using Dates
    using TimeZones

    obs = CoolWalksUtils.ShadowObservatory("denmark", 12, 55, tz"Europe/Berlin")

    t1 = DateTime(2022, 9, 5, 7, 31)
    t2 = DateTime(2022, 9, 5, 13, 12)
    t3 = DateTime(2022, 9, 5, 18, 53, 30)

    pos1 = local_sunpos(t1, obs)
    @test pos1[1] > 0
    @test pos1[2] ≈ 0 atol = 0.01
    @test pos1[3] > 0

    pos2 = local_sunpos(t2, obs)
    @test pos2[1] ≈ 0 atol = 0.01
    @test pos2[2] < 0
    @test pos2[3] > 0

    pos3 = local_sunpos(t3, obs)
    @test pos3[1] < 0
    @test pos3[2] ≈ 0 atol = 0.01
    @test pos3[3] > 0
end

@testitem "SunPosition altaz" begin
    using Dates
    using TimeZones

    obs = CoolWalksUtils.ShadowObservatory("denmark", 12, 55, tz"Europe/Berlin")

    t1 = DateTime(2022, 9, 5, 7, 31)
    t2 = DateTime(2022, 9, 5, 13, 12)
    t3 = DateTime(2022, 9, 5, 18, 53, 30)

    pos1 = local_sunpos(t1, obs; cartesian=false)
    @test pos1[1] > 0
    @test pos1[2] ≈ 90 atol = 0.05

    pos2 = local_sunpos(t2, obs; cartesian=false)
    @test pos2[1] > 0
    @test pos2[2] ≈ 180 atol = 0.05

    pos3 = local_sunpos(t3, obs; cartesian=false)
    @test pos3[1] > 0
    @test pos3[2] ≈ 270 atol = 0.05
end

@testitem "set_observatory!" begin
    using ArchGDAL, DataFrames, TimeZones

    lon = [1.0, 1.6, 2.6, 5.0]
    lat = [1.0, 1.2, 3.5, 5.2]

    p1 = ArchGDAL.createpoint(lon[1], lat[1])
    p2 = ArchGDAL.buffer(ArchGDAL.createpoint(lon[2], lat[2]), 1.4)
    p3 = ArchGDAL.createpoint(lon[3], lat[3])
    p4 = ArchGDAL.buffer(ArchGDAL.createpoint(lon[4], lat[4]), 0.3)
    geometry = [p1, p2, p3, p4]

    df = DataFrame(lon=lon, lat=lat, geometry=geometry)
    set_observatory!(df, "latlonobs", tz"Europe/Berlin")
    setobs = metadata(df, "observatory")

    @test setobs.name == "latlonobs"
    @test setobs.lon ≈ 3.0
    @test setobs.lat ≈ 3.1

    set_observatory!(df, "geomobs", tz"Europe/Berlin"; source=[:geometry])
    setobs = metadata(df, "observatory")

    @test setobs.name == "geomobs"
    @test setobs.lon ≈ 2.75
    @test setobs.lat ≈ 2.65
end