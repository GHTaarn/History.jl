using Dates: now

"""
    histsave(fname::AbstractString, itemspec::Symbol=:all; sessionseparator=row->contains(row[3],"exit()"))
    histsave(fname::AbstractString, nitems::Integer)
    histsave(fname::AbstractString, indices::AbstractVector{<:Integer})

Save the REPL history in a file named `fname`.

In the first variant, `itemspec` may be either `:all` or `:session`.
In the latter case `histsave` attempts to determine what part of the history
belongs to the current Julia session and saves this, but it is advisable to
check the output as it is heuristically determined using the `sessionseparator`
keyword and deviations are especially common if several Julia sessions have
been running concurrently with the current session.

The second variant saves only the `nitems` most recent items in the REPL history
(including the current line).

In the third variant `indices` is the specific indices of the items to be saved.

In all variants, an error is thrown if the file `fname` exists and is non-empty.
Also, `fname` may be omitted, in which case the history will be written to the
file `"\$(Dates.now()).jl"`.

See also [`history`](@ref).
"""
function histsave(fname::AbstractString, itemspec::Union{Symbol,AbstractVector{<:Integer},Integer}; sessionseparator=row->contains(row[3],"exit()"))
    @assert itemspec in (:all, :session) || itemspec isa AbstractVector{<:Integer} || itemspec >= 0
    n = 0
    open(fname, "a+") do f
        seek(f, 0)
        length(read(f, 1)) > 0 && error("Refusing to overwrite non-empty file \"$fname\"")
        histry = history()
        lhistry = size(histry, 1)
        idxs = if itemspec isa AbstractVector
            itemspec
        elseif itemspec == :all
            1:lhistry
        elseif itemspec isa Integer
            lhistry+1-itemspec:lhistry
        elseif itemspec == :session
            idx = findlast(sessionseparator, eachrow(histry))
            if isnothing(idx) || idx == lhistry
                @warn "No usable match for sessionseparator was found, so all history will be saved"
                idx = 1
            else
                idx += 1
            end
            idx:lhistry
        end
        foreach(histry[idxs,3]) do str
            n += write(f, str * "\n")
        end
    end
    "$n bytes written to $fname"
end

function histsave(itemspec::Union{Symbol,AbstractVector{<:Integer},Integer}; kwargs...)
    fname = "$(now()).jl"
    histsave(fname, itemspec; kwargs...)
end

