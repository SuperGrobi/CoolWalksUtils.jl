@testset "rerun" begin
    function throwerror_prob(p)
        rand() <= p ? throw(ArgumentError("this is a test error")) : "everything ran fine"
    end

    tries = 10

    @test_throws ArgumentError @rerun tries throwerror_prob(1)
    @rerun tries rand(5)
    @test true
end