function slices(x; dims=1, reducedimensions=false)
    dims != 1 && error("dims!=1 not implemented")
    [x[(reducedimensions ? i : i:i),:] for i in axes(x,dims)]
end

function filterslices(f, x; dims=1)
    cat(filter(f, slices(x))...; dims=dims)
end

"""
    histsearch(str::AbstractString)
    histsearch(regexp::Regex)
    histsearch(f)

Return history entries that match a string, regular expression or function.

See also [`history`](@ref).

# Examples

```julia
histsearch("using ")
histsearch(r"[0-9]+")
histsearch(isascii)
histsearch("[0-9]+")
```
"""
function histsearch(f)
    filterslices(x->f(x[1,end]), history())
end

function histsearch(regexp::Regex)
    histsearch(s -> (match(regexp, s) != nothing))
end

function histsearch(str::AbstractString)
    histsearch(s -> occursin(str, s))
end

