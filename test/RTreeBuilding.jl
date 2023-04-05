@testset "rect_from_geom" begin
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

@testset "build_rtree" begin
    function triangle(x, y, w, h)
        return ArchGDAL.createpolygon([x, x + w, x + 0.3w, x], [y, y, y + h, y])
    end

    trigs = [triangle(i...) for i in zip([0, 1, 3, 7, 6], [0.2, 4.9, 5, 1], [1, 3, 5.2, 0.4, 1.0], [0.4, 7, 3.2, 1, 9.1])]
    tree = build_rtree(trigs)
    @test tree isa RTree
    @test length(collect(contained_in(tree, SpatialIndexing.Rect((0.4, 0.2), (9.3, 10.6))))) == 2
    @test length(collect(intersects_with(tree, SpatialIndexing.Rect((0.4, 0.2), (9.3, 10.6))))) == 4


    @test_throws TypeError build_rtree([ArchGDAL.createpoint(1.2, 4.5)])
    @test_throws TypeError build_rtree([ArchGDAL.createpoint(1.2, 4.5), ArchGDAL.createlinestring([0.0, 1.5, 0.6], [1.4, 3.5, 9.8])])
    @test_throws TypeError build_rtree([ArchGDAL.createlinestring([0.0, 1.5, 0.6], [1.4, 3.5, 9.8])])
end

@testset "build_point_rtree" begin
    x = [10, 0, 8, 4, 0, 5, 7, 7, 5, 5] .|> Float64
    y = [8, 0, 10, 4, 5, 3, 1, 2, 9, 2] .|> Float64
    points = ArchGDAL.createpoint.(x, y)
    buffered = ArchGDAL.buffer.(points, 1)
    tree = build_point_rtree(points, "id" .* string.(1:10), true)

    @test tree isa RTree
    @test length(collect(contained_in(tree, SpatialIndexing.Rect((2.5, 0.2), (7.5, 4.8))))) == 5
    @test length(collect(intersects_with(tree, rect_from_geom(points[10], buffer=2.1)))) == 5
end

@testset "build_rtree from dataframe" begin
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
        @test inter.val.row.info isa String
    end
end