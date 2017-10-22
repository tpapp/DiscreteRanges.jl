# DiscreteRanges

[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/latest/wip.svg)](http://www.repostatus.org/#wip)
[![Build Status](https://travis-ci.org/tpapp/DiscreteRanges.jl.svg?branch=master)](https://travis-ci.org/tpapp/DiscreteRanges.jl)
[![Coverage Status](https://coveralls.io/repos/github/tpapp/DiscreteRanges.jl/badge.svg?branch=master)](https://coveralls.io/github/tpapp/DiscreteRanges.jl?branch=master)
[![codecov.io](http://codecov.io/github/tpapp/DiscreteRanges.jl/coverage.svg?branch=master)](http://codecov.io/github/tpapp/DiscreteRanges.jl?branch=master)

## Introduction

This package provides a type `DiscreteRange{T}` for types `T` which
are isomorphic to integers, in the sense that elements of `T` can be
thought of as evenly spaced values using some relevant arithmetic
operations. All subtypes of `Integer` satisfy this, and also `Date`.

`DiscreteRange(left::T, right::T)` is meant to represent all values
`x::T` such that `a ≤ x ≤ b`. In this sense it is very similar to a
`UnitRange`, except that it can be defined for types other than `<:
Real`, and extended easily (see below). Iteration, indexing and array
interfaces are supported, and so are basic set operations (`∪`, `∩`,
`⊆`, `∈`, etc).

## Comparison and conflict with `IntervalSets.jl`

[`IntervalSets.jl`](https://github.com/JuliaMath/IntervalSets.jl) is a similar library serving a different purpose. Both export `..`, you can avoid conflicts by importing only `DiscreteRange` and optionally using another infix operator:

```julia
using DiscreteRanges: DiscreteRange
const ∷ = DiscreteRanges.:(..) # or pick your favorite operator
1∷2                            # DiscreteRange{Int}(1, 2)
```

Then comparing the two packages, keep in mind that `IntervalSets.jl`
is better for representing intervals of *real numbers*, while a
`DiscreteRange` is a collection of a finite number of objects.

The following table summarizes the differences:

|   | `DiscreteRange` | `IntervalSets.ClosedInterval` |
|---|---|---|
| `3 ∈ 1..3` | `true` | `true` |
| `3.0 ∈ 1..3` | `true` (converted first) | `true` (compared as is) |
| `3.1 ∈ 1..3` | throws `InexactError` | `true` |
| `1.0..3.0` | throws `ArgumentError` (non-discrete type) | valid |
| `(1..2) ∪ (3..4)` | `1..4` | throws `ArgumentError` (disjoint) |
| `length(1..3)` | `3` | `3` **(this may change)** |
| `width(1..3)` | throws `MethorError` | `2` |
| `(1..2) ∈ (0..10)` | throws `MethorError` | `true` |

## Extending for custom types

To make `DiscreteRange` work for a type `T`, define `isdiscrete`,
`discrete_gap`, and `discrete_next`. See their docstring for further
information. There is an example in the unit tests.
