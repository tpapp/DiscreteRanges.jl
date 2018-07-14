using DiscreteRanges

using Dates: Date, Day, days
using Test

@testset "general" begin
    @test !DiscreteRanges.isdiscrete(Float64)
    @test DiscreteRanges.isdiscrete(Int)
    @test DiscreteRanges.isdiscrete(Date)
end

@testset "discrete range Int" begin
    A = 1..5
    @test repr(A) == "1..5"
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
    @test (2..3) ⊆ A
    @test_throws ArgumentError A ∪ (7..10)
    @test length(A) == 5
    @test collect(A) == collect(1:5)
    @test eltype(A) == Int
    @test convert(StepRange, A) == 1:1:5
    B = DiscreteRange(3)
    @test length(B) == 1
    @test B ⊆ A
    C = DiscreteRange(-7)
    @test !(C ⊆ A)
    @test isempty(C ∩ A)
    E = DiscreteRange(3,-3)     # empty
    @test isempty(E)
    @test repr(E) == "empty DiscreteRange{Int64}"
end

@testset "discrete range Date" begin
    d1 = Date(1980,1,1)
    d2 = Date(1980,12,31)
    A = d1..d2
    @test repr(A) == "1980-01-01..1980-12-31"
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
    @test_throws ArgumentError A ∪ (d4..(d4 + Day(5)))
    @test length(A) == 366                                 # 1980 is a leap year
    @test collect(A) == collect(d1:Day(1):d2)
    @test eltype(A) == Date
    @test convert(StepRange, A) == d1:Day(1):d2
    B = DiscreteRange(Date(1980, 5, 7))
    @test length(B) == 1
    @test B ⊆ A
    C = DiscreteRange(Date(1960, 1, 1))
    @test !(C ⊆ A)
    @test isempty(C ∩ A)
    @test repr(C ∩ A) == "empty DiscreteRange{Date}"
end

@testset "promotions" begin
    A = 1..10
    @test Int32(3) ∈ A
    @test 3.0 ∈ A
    @test_throws InexactError 3.1 ∈ A
    @test (Int32(2)..Int32(3)) ⊆ A
    @test_throws ArgumentError DiscreteRange(3.0, 4.0)
end

@testset "hashing" begin
    d1 = 1..2
    d2 = 1..2
    @test hash(d1) == hash(d2)
end

@testset "iteration" begin
    itr = 3..7
    @test [i^2 for i in itr] == [9, 16, 25, 36, 49]
    @test Base.IteratorSize(typeof(itr)) == Base.HasLength()
    @test Base.IteratorEltype(typeof(itr)) == Base.HasEltype()
    @test eltype(itr) == Int
    @test length(itr) == 5
    d1 = Date(1980,1,1)
    d2 = Date(1980,4,1)
    A = d1..d2
    @test [i for i in A] == collect(convert(StepRange, A))
    @test Base.IteratorSize(typeof(A)) == Base.HasLength()
    @test Base.IteratorEltype(typeof(A)) == Base.HasEltype()
    @test eltype(A) == Date
    @test length(A) == days(d2 - d1) + 1
end

######################################################################
# example: custom type
######################################################################

struct WrapInt{T <: Integer}
    i::T
end

DiscreteRanges.isdiscrete(::Type{<:WrapInt}) = true
DiscreteRanges.discrete_gap(x::WrapInt, y::WrapInt) = x.i - y.i
DiscreteRanges.discrete_next(x::WrapInt, Δ) = WrapInt(x.i + Δ)
Base.isless(x::WrapInt, y::WrapInt) = isless(x.i, y.i)
Base.:(==)(x::WrapInt, y::WrapInt) = x.i == y.i

@testset "custom type" begin
    A = WrapInt(1)..WrapInt(7)
    @test WrapInt(5) ∈ A
    @test WrapInt(-3) ∉ A
    @test (WrapInt(2)..WrapInt(3)) ⊆ A
    @test !((WrapInt(-11)..WrapInt(3)) ⊆ A)
    @test length(A) == 7
    @test A[3] == WrapInt(3)
    @test [i for i in A] == [WrapInt(i) for i in 1:7]
    for i in A
        println(i)
    end
end
