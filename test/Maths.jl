@testset "Maths" begin
    v1 = [1, 1, 1]
    v2 = [1, -1, 0]
    v3 = [1, 0, -1]

    @test unit(v1) == v1 ./ sqrt(3)
    @test unit(v2) == v2 ./ sqrt(2)
    @test unit(v3) == v3 ./ sqrt(2)

    @test cross(v1, v2) == [1, 1, -2]
    @test cross(v2, v2) == [0, 0, 0]
    @test cross(v2, v3) == -cross(v3, v2)
    @test cross(v2, v3) == [1, 1, 1]
end