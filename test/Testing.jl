@testset "rerun" begin
    function throwerror_prob(p)
        rand() <= p ? throw(ArgumentError("this is a test error")) : "everything ran fine"
    end

    @test_throws ErrorException @rerun 10 throwerror_prob(1)
    @rerun 10 rand(5)
    @test true
end