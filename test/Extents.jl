@testitem "Extent construction" begin
    using ArchGDAL

    point1 = ArchGDAL.createpoint(1.0, 1.0)
    point2 = ArchGDAL.createpoint(3.5, 1.2)
    line1 = ArchGDAL.createlinestring([(0.0, 0.0), (1.0, 1.0), (2.0, 1.0)])
    line2 = ArchGDAL.createlinestring([(1.0, 0.0), (1.0, 1.0), (0.0, 2.4)])

    geomlist = [point1, point2, line1, line2]
    geom_extent = geoiter_extent(geomlist)

    @test geom_extent.X[1] == 0.0
    @test geom_extent.Y[1] == 0.0
    @test geom_extent.X[end] == 3.5
    @test geom_extent.Y[end] == 2.4

    lons = [8.5, 9.3, 0.2, 5, 6, 1, 6.3, 1.2, 7.3, 5, 3.9, 5.1]
    lats = [1, 2, 3, 8, 4, 5, 9, 2, 4, 3, 0.3, 1.5]

    point_extent = geoiter_extent(lons, lats)
    @test point_extent.X[1] == minimum(lons)
    @test point_extent.Y[1] == minimum(lats)
    @test point_extent.X[end] == maximum(lons)
    @test point_extent.Y[end] == maximum(lats)
end
@testitem "Extent center" begin
    using Extents
    basic_extent = Extent(X=(0.0, 5.0), Y=(1.0, 1.4))

    @test extent_center(basic_extent) == (X=2.5, Y=1.2)
end

@testitem "Extent contains" begin
    using Extents, ArchGDAL

    e1 = Extent(X=(0.0, 2.0), Y=(0.0, 2.0))
    e2 = Extent(X=(1.0, 3.0), Y=(1.0, 3.0))
    e3 = Extent(X=(1.0, 2.0), Y=(1.3, 1.9))

    @test !extent_contains(e1, e2)
    @test !extent_contains(e2, e1)

    @test extent_contains(e1, e3)
    @test extent_contains(e2, e3)

    @test !extent_contains(e3, e1)
    @test !extent_contains(e3, e2)

    @test extent_contains(e1, e1)
    @test extent_contains(e2, e2)
    @test extent_contains(e3, e3)

    @test extent_contains(e1, 1.0, 1.6)
    @test !extent_contains(e1, 20.0, 1.6)
    @test extent_contains(e1, 2.0, 1.0)


    @test extent_contains(e1, ArchGDAL.createpoint(1.0, 1.4))
    @test extent_contains(e1, ArchGDAL.buffer(ArchGDAL.createpoint(1.0, 1.0), 0.5))
    @test !extent_contains(e1, ArchGDAL.buffer(ArchGDAL.createpoint(1.0, 1.0), 2.0))
    @test !extent_contains(e1, ArchGDAL.buffer(ArchGDAL.createpoint(3.0, 1.0), 1.0))
end

@testitem "apply_extent!" begin
    using ArchGDAL, Extents, DataFrames

    e = Extent(X=(0.0, 2.0), Y=(0.0, 2.0))
    lon = [1.0, 1.6, 2.6, 5.0]
    lat = [1.0, 1.2, 3.5, 5.2]

    p1 = ArchGDAL.createpoint(lon[1], lat[1])
    p2 = ArchGDAL.buffer(ArchGDAL.createpoint(lon[2], lat[2]), 1.4)
    p3 = ArchGDAL.createpoint(lon[3], lat[3])
    p4 = ArchGDAL.buffer(ArchGDAL.createpoint(lon[4], lat[4]), 0.3)
    geometry = [p1, p2, p3, p4]

    df = DataFrame(lon=lon, lat=lat, geometry=geometry)
    apply_extent!(df, e)
    @test nrow(df) == 2
    @test df.lon == [1.0, 1.6]
    @test df.lat == [1.0, 1.2]

    df = DataFrame(lon=lon, lat=lat, geometry=geometry)
    apply_extent!(df, e; source=[:geometry])
    @test nrow(df) == 1
    @test df.lon == [1.0]
    @test df.lat == [1.0]
end