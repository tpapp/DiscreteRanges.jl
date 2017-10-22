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
    @test 7 ∉ A
    @test minimum(A) == 1
    @test maximum(A) == 5
    @test extrema(A) == (1,5)
    @test A ∩ (2..7) == 2..5
    @test A ∪ (6..10) == 1..10
    @test_throws ArgumentError A ∪ (7..10)
    @test length(A) == 5
    @test collect(A) == collect(1:5)
    @test eltype(A) == Int
    @test convert(StepRange, A) == 1:1:5
end

@testset "discrete range Date" begin
    d1 = Date(1980,1,1)
    d2 = Date(1980,12,31)
    A = d1..d2
    A2 = DiscreteRange(d1, d2)
    @test A == A2
    @test isequal(A, A2)
    @test A ≠ d1..Date(1980,1,2)
    @test Date(1980,1,1) ∈ A
    @test Date(1980,1,12) ∈ A
    @test Date(1980,5,1) ∈ A
    @test Date(1970,1,1) ∉ A
    @test minimum(A) == d1
    @test maximum(A) == d2
    @test extrema(A) == (d1,d2)
    d3 = Date(1980, 2, 7)
    d4 = Date(1981, 3, 19)
    d5 = Date(1981, 1, 1)
    @test A ∩ (d3..d4) == d3..d2
    @test A ∪ (d3..d4) == d1..d4
    @test A ∪ (d5..d4) == d1..d4
    @test_throws ArgumentError A ∪ (d4..(d4+Dates.Day(5)))
    @test length(A) == 366                                 # 1980 is a leap year
    @test collect(A) == collect(d1:d2)
    @test eltype(A) == Date
    @test convert(StepRange, A) == d1:Dates.Day(1):d2
end
