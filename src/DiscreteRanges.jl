module DiscreteRanges

using ArgCheck

import Base:
    show, isequal, ==, hash, convert,
    in, isempty, issubset, union, intersect,
    minimum, maximum, extrema,
    length, size, IndexStyle, getindex, start, next, done, iteratorsize, iteratoreltype

export DiscreteRange, ..

"""
    DiscreteRange(left::T, right::T) where T
    DiscreteRange(singleton)

An object representing all values `x::T` such that `left ≤ x ≤ right`. Supports
`∈`, `⊆`, indexing, iteration, and (immutable) array interfaces. For integers,
it is equivalent to `UnitRange{T}`. With a single argument, `left == right`.

## Definition for custom types

The package defines methods for `<: Integer` and `Date`. To extend this, define
the following: [`isdiscrete`](@ref), [`discrete_gap`](@ref),
[`discrete_next`](@ref), [`Base.isless`](@ref).

The methods for [`Base.==`](@ref), [`Base.isequal`](@ref) and
[`Base.hash`](@ref) only work for `DiscreteRange{T}` when they are defined for
`T`. The unit tests of the
"""
struct DiscreteRange{T} <: AbstractVector{T}
    left::T
    right::T
    function DiscreteRange(left::T, right::T) where T
        @argcheck isdiscrete(T) "Only discrete types are supported. Define `isdiscrete($T)`."
        new{T}(left, right)
    end
end

convert(::Type{DiscreteRange{T}}, D::DiscreteRange{T}) where T = D

convert(::Type{DiscreteRange{T}}, D::DiscreteRange) where T =
    DiscreteRange(T(D.left), T(D.right))

..(left, right) = DiscreteRange(left, right)

"""
    isdiscrete(T)

Creation of `DiscreteRange{T}` objects is only allowed when this returns `true`.

Needs to be defined for valid `DiscreteRange` type parameters.
"""
isdiscrete(::Type) = false
isdiscrete(::Type{<:Integer}) = true
isdiscrete(::Type{Date}) = true

"""
    discrete_gap(x::T, y::T)

Return the difference `y - x` as an *integer*.

Needs to be defined for valid `DiscreteRange` type parameters.
"""
discrete_gap(x::Integer, y::Integer) = x - y
discrete_gap(x::Date, y::Date) = Dates.days(x - y)

"""
    discrete_next(x::T, Δ::Integer)

Return `y::T` such that `discrete_gap(y, x) == Δ`.

Needs to be defined for valid `DiscreteRange` type parameters.
"""
discrete_next(x) = discrete_next(x, 1)
discrete_next(x::T, Δ) where {T <: Integer} = x + T(Δ)
discrete_next(x::Date, Δ) = x + Dates.Day(Δ)

DiscreteRange(x) = DiscreteRange(x, x) # single value

isempty(D::DiscreteRange) = D.left > D.right

function show(io::IO, D::DiscreteRange{T}) where T
    if isempty(D)
        print(io, "empty DiscreteRange{$(T)}")
    else
        print(io, D.left, "..", D.right)
    end
end

show(io::IO, ::MIME"text/plain", D::DiscreteRange) =
    show(io, D) # fallback to prevent AbstractArray printing

in(x::T, D::DiscreteRange{T}) where T = D.left ≤ x ≤ D.right

in(x, D::DiscreteRange{T}) where T = T(x) ∈ D

isequal(A::DiscreteRange, B::DiscreteRange) =
    (isequal(A.left, B.left) & isequal(A.right, B.right)) | (isempty(A) & isempty(B))

==(A::DiscreteRange, B::DiscreteRange) =
    (A.left == B.left) & (A.right == B.right) | (isempty(A) & isempty(B))

const _DISCRETERANGE_HASH = UInt === UInt64 ? 0x3c467b76e5939730 : 0xff9d6b2d

hash(A::DiscreteRange, h::UInt) = hash(A.left, hash(A.right, hash(_DISCRETERANGE_HASH, h)))

function minimum(D::DiscreteRange)
    @argcheck !isempty(D)
    D.left
end

function maximum(D::DiscreteRange)
    @argcheck !isempty(D)
    D.right
end

function extrema(D::DiscreteRange)
    @argcheck !isempty(D)
    D.left, D.right
end

intersect(A::DiscreteRange, B::DiscreteRange) =
    DiscreteRange(max(A.left, B.left), min(A.right, B.right))

function union(A::DiscreteRange, B::DiscreteRange)
    @argcheck(discrete_gap(max(A.left, B.left), min(A.right, B.right)) ≤ 1,
              "Disjoint discrete ranges.")
    DiscreteRange(min(A.left, B.left), max(A.right, B.right))
end

issubset(A::DiscreteRange{T}, B::DiscreteRange{T}) where {T} =
    isempty(A) || (B.left ≤ A.left ≤ A.right ≤ B.right)

issubset(A::DiscreteRange, B::DiscreteRange) = issubset(oftype(B, A), B)

length(D::DiscreteRange) = isempty(D) ? 0 : Int(discrete_gap(D.right, D.left)) + 1

size(D::DiscreteRange) = (length(D),)

IndexStyle(::Type{<:DiscreteRange}) = IndexLinear()

function getindex(D::DiscreteRange, i)
    i ≥ 1 || throw(BoundsError(D, i))
    elt = discrete_next(D.left, i-1)
    elt ≤ D.right || throw(BoundsError(D, i))
    elt
end

start(D::DiscreteRange) = D.left

next(D::DiscreteRange, state) = state, discrete_next(state)

done(D::DiscreteRange, state) = state > D.right

iteratorsize(::Type{DiscreteRange{T}}) where T = Base.HasLength()

iteratoreltype(::Type{DiscreteRange{T}}) where T = Base.HasEltype()

convert(::Type{R}, D::DiscreteRange) where {R <: StepRange} =
    R(D.left, discrete_next(D.left) - D.left, D.right)

end # module
