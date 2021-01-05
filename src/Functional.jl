module Functional

using Lazy

export constant, getter, complement, relates, equals, isin,
    partial, rpartial, apply, juxt, compose, rcompose, vectorize,
    apply_keys, map_keys, filter_keys, select_keys, omit_keys,
    apply_values, map_values, filter_values, take_indices

# Functors
partial(f, args...; kwargs...) =
    (cargs...; ckwargs...) -> f(args..., cargs...; kwargs..., ckwargs...)
rpartial(f, args...; kwargs...) =
    (cargs...; ckwargs...) -> f(cargs..., args...; kwargs..., ckwargs...)
apply(f, args...; kwargs...) = f(args...; kwargs...)
juxt(fs...) = (args...; kwargs...) -> map(rpartial(apply, args...; kwargs...), fs)
compose(fs...) = x -> reduce(apply, fs; init=x)
rcompose(fs...) = compose(reverse(fs))
vectorize(f) = l -> map(f, l)

# Utility functions
constant(x) = (args...; kwargs...) -> x
getter(k) = coll -> getindex(coll, k, default)
getter(k, default) = coll -> get(coll, k, default)
complement(f) = x -> !f(x)

relates(relation, y) = x -> relation(x, y)
equals = partial(relates, ==)
isin = partial(relates, in)

# Dictionaries
apply_keys(ff, f, d) = Dict(zip(ff(f, keys(d)), values(d)))
map_keys(f, d) = apply_keys(map, f, d)
filter_keys(f, d) = apply_keys(filter, f, d)

apply_values(ff, f, d) = Dict(zip(keys(d), ff(f, values(d))))
map_values(f, d) = apply_values(map, f, d)
filter_values(f, d) = apply_values(filter, f, d)

select_keys(d, ks) = filter_keys(k -> k in keys, d)
omit_keys(d, ks) = filter_keys(complement(k -> k in keys), d)

# Sequences
take_indices(indices::Array{Int}, l::List) =
    take_indices((@lazy indices), l)
take_indices(indices::List, l::List) =
    @lazy take_intervals(map(-, indices, 0:indices), l)
take_intervals(intervals, l::List) =
    (@lazy isempty(l) || isempty(intervals) ? [] :
     first(drop(first(intervals) - 1, l)):take_intervals(
         tail(intervals), drop(first(intervals), l)))
end
