@testitem "Maths is_ccw" begin
    @test is_ccw([0, 0], [1, 0], [1, 1])
    @test !is_ccw([0, 0], [0, 1], [1.4, 0.5])
end

@testitem "Maths switches_side" begin
    @test switches_side([0, 0], [1, 1], [5, 0], [0, 5])
    @test !switches_side([0, 0], [1, 1], [0.4, 0.2], [10.5, 2.0])
end

@testitem "Maths intersection_distance" begin
    @test intersection_distances([0, 0], [1, 1], [5, 0], [0, 5]) == [2.5, 0.5]
    @test intersection_distances([0, 0.0], [1, 1], [4.0, 0.0], [10.0, 2.0]) == [-2.0, -1.0]
end

@testitem "Maths is_convex" begin
    using ArchGDAL
    square = [[0, 0], [1, 0], [1, 1], [0, 1], [0, 0]]
    @test is_convex(square)
    thing = [[0.6, 0.6], [1.0, 0.0], [1.0, 1.0], [0.0, 1.0], [0.6, 0.6]]
    @test !is_convex(thing)

    a1 = ArchGDAL.buffer(ArchGDAL.createpoint(0, 0), 1)
    a2 = ArchGDAL.buffer(ArchGDAL.createpoint(1, 0), 1)
    a3 = ArchGDAL.buffer(ArchGDAL.createpoint(0, 0), 0.4)

    a4 = ArchGDAL.difference(a1, a2)
    a5 = ArchGDAL.difference(a1, a3)

    @test is_convex(a1)
    @test !is_convex(a4)
    @test is_convex(a5)
end

@testitem "Maths is_left" begin
    using ArchGDAL

    @test is_left([0, 0], [1, 1], [-1, 0, 0])
    @test is_left(ArchGDAL.createpoint([0, 0]), ArchGDAL.createpoint([1, 1]), [-1, 0, 0])

    @test !is_left([0.5, 0.5, 0.0], [1, 1, 0.0], [1, 0, 0])
end