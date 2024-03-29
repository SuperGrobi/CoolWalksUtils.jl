@testitem "rect_from_geom" begin
    using ArchGDAL
    pointrect = CoolWalksUtils.rect_from_geom(ArchGDAL.createpoint(1.0, 1.0))
    @test pointrect.low == (1.0, 1.0)
    @test pointrect.high == (1.0, 1.0)

    linerect = CoolWalksUtils.rect_from_geom(ArchGDAL.createlinestring([0.0, 1.5, 0.6], [1.4, 3.5, 9.8]))
    @test linerect.low == (0.0, 1.4)
    @test linerect.high == (1.5, 9.8)

    polyrect = CoolWalksUtils.rect_from_geom(ArchGDAL.createpolygon([0.0, 0.4, 0.2, 0.0], [0.0, 0.0, 0.6, 0.0]))
    @test polyrect.low == (0.0, 0.0)
    @test polyrect.high == (0.4, 0.6)

    pointrect = CoolWalksUtils.rect_from_geom(ArchGDAL.createpoint(1.0, 1.0), buffer=1.0)
    @test pointrect.low == (0.0, 0.0)
    @test pointrect.high == (2.0, 2.0)

    linerect = CoolWalksUtils.rect_from_geom(ArchGDAL.createlinestring([0.0, 1.5, 0.6], [1.4, 3.5, 9.8]), buffer=-0.3)
    @test linerect.low == (0.3, 1.7)
    @test linerect.high == (1.2, 9.5)

    polyrect = CoolWalksUtils.rect_from_geom(ArchGDAL.createpolygon([0.0, 0.4, 0.2, 0.0], [0.0, 0.0, 0.6, 0.0]), buffer=1.8)
    @test polyrect.low == (-1.8, -1.8)
    @test polyrect.high == (2.2, 2.4)
end

@testitem "build_rtree" begin
    using ArchGDAL, SpatialIndexing
    function triangle(x, y, w, h)
        return ArchGDAL.createpolygon([x, x + w, x + 0.3w, x], [y, y, y + h, y])
    end

    trigs = [triangle(i...) for i in zip([0, 1, 3, 7, 6], [0.2, 4.9, 5, 1], [1, 3, 5.2, 0.4, 1.0], [0.4, 7, 3.2, 1, 9.1])]
    tree = @inferred build_rtree(trigs)
    @test tree isa RTree
    @test length(tree) == 4
    @test length(collect(contained_in(tree, SpatialIndexing.Rect((0.4, 0.2), (9.3, 10.6))))) == 2
    @test length(collect(intersects_with(tree, SpatialIndexing.Rect((0.4, 0.2), (9.3, 10.6))))) == 4
    for inter in intersects_with(tree, SpatialIndexing.Rect((0.4, 0.2), (9.3, 10.6)))
        @test haskey(inter.val, :prep)
        @test haskey(inter.val, :orig)
        @test haskey(inter.val, :data)
        @test length(inter.val) == 3
        @test isnothing(inter.val.data)
    end


    pointtree = @inferred build_rtree([ArchGDAL.createpoint(1.2, 4.5)], ["testdata"])
    for i in pointtree
        @test i.val.data == "testdata"
    end
    @test_throws AssertionError build_rtree([ArchGDAL.createpoint(1.2, 4.5)], ["testdata", "too much data"])

    mixedtree = @inferred build_rtree(
        [[ArchGDAL.createpoint(1.2, 4.5),
                ArchGDAL.createlinestring([0.0, 1.5, 0.6], [1.4, 3.5, 9.8]),
                ArchGDAL.createlinestring([0.0, 1.5, 0.6], [1.4, 3.5, 9.8])]
            trigs])
    @test length(mixedtree) == 7
end

@testitem "build_rtree from points" begin
    using ArchGDAL, SpatialIndexing
    x = [10, 0, 8, 4, 0, 5, 7, 7, 5, 5] .|> Float64
    y = [8, 0, 10, 4, 5, 3, 1, 2, 9, 2] .|> Float64
    points = ArchGDAL.createpoint.(x, y)
    buffered = ArchGDAL.buffer.(points, 1)
    tree = @inferred build_rtree(points, "id" .* string.(1:10))

    @test tree isa RTree
    @test length(collect(contained_in(tree, SpatialIndexing.Rect((2.5, 0.2), (7.5, 4.8))))) == 5
    @test length(collect(intersects_with(tree, rect_from_geom(points[10], buffer=2.1)))) == 5
end

@testitem "build_rtree from dataframe" begin
    using DataFrames, ArchGDAL, SpatialIndexing
    function triangle(x, y, w, h)
        return ArchGDAL.createpolygon([x, x + w, x + 0.3w, x], [y, y, y + h, y])
    end

    trigs = [triangle(i...) for i in zip([0, 1, 3, 7, 6], [0.2, 4.9, 5, 1], [1, 3, 5.2, 0.4, 1.0], [0.4, 7, 3.2, 1, 9.1])]
    df = DataFrame(geometry=trigs, info=ArchGDAL.toWKT.(ArchGDAL.centroid.(trigs)))
    tree = build_rtree(df)
    @test tree isa RTree
    @test length(collect(contained_in(tree, SpatialIndexing.Rect((0.4, 0.2), (9.3, 10.6))))) == 2
    @test length(collect(intersects_with(tree, SpatialIndexing.Rect((0.4, 0.2), (9.3, 10.6))))) == 4
    for inter in intersects_with(tree, SpatialIndexing.Rect((0.4, 0.2), (9.3, 10.6)))
        @test inter.val.data.info isa String
        @test length(inter.val) == 3
        @test haskey(inter.val, :orig)
        @test haskey(inter.val, :prep)
        @test haskey(inter.val, :data)
    end
end