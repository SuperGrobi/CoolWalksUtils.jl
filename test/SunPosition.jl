@testitem "SunPosition" begin
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