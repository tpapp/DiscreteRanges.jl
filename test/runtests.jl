using DiscreteRanges
using Base.Test

@testset "discrete range Int" begin
    A = 1..5
    @test A == DiscreteRange(1, 5)
    @test isequal(A, DiscreteRange(1, 5))
    @test A ≠ 3..7
    @test 1 ∈ A
    @test 5 ∈ A
    @test 3 ∈ A
    @test minimum(A) == 1
    @test maximum(A) == 5
    @test extrema(A) == (1,5)
    @test A ∩ (2..7) == 2..5
    @test A ∪ (6..10) == 1..10
    @test_throws ArgumentError A ∪ (c7..10)
    @test length(A) == 5
    @test collect(A) == collect(1:5)
    @test eltype(A) == Int
    @test convert(StepRange, A) == 1:1:5
end
